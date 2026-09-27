#!/usr/bin/env bash
#
# sync-folders.sh — one-way mirror sync with SOFT delete
#
# Makes DEST match SOURCE, but nothing is ever permanently removed by
# this script. Anything that would be deleted or overwritten in DEST is
# moved into a dated folder under TRASH first, so you can review and
# purge manually:
#   - new files/folders in SOURCE       -> added to DEST
#   - changed files/folders in SOURCE   -> DEST updated, OLD version moved to TRASH
#   - files/folders removed from SOURCE -> moved out of DEST into TRASH (not deleted)
#
# Mechanism: rsync's --backup / --backup-dir. Whenever rsync would delete
# or overwrite a file in DEST, it moves the existing DEST copy into
# --backup-dir first, preserving its relative path. Each run gets its own
# timestamped subfolder under TRASH so you can see what happened per-run.
#
# Usage:
#   ./sync-folders.sh                                 # uses config below
#   ./sync-folders.sh /path/B /path/A                 # override source/dest
#   ./sync-folders.sh /path/B /path/A /path/trash     # override trash location too
#   ./sync-folders.sh --dry-run                       # preview only, changes nothing
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Config — edit these, or pass source/dest/trash as arguments
# ---------------------------------------------------------------------------
DEFAULT_SOURCE="/path/to/folderB"
DEFAULT_DEST="/path/to/folderA"
LOG_DIR="${LOG_DIR:-$HOME/sync-logs}"
LOCK_FILE="/tmp/folder_sync.lock"
MIN_SOURCE_ITEMS=1   # abort if source has fewer items than this (empty-source guard)

# ---------------------------------------------------------------------------
# Resolve a path to absolute form without requiring it to exist yet.
# Portable stand-in for GNU `realpath -m`: macOS/BSD's realpath doesn't
# have -m (its whole flag set is just -q), so this is done by hand with
# cd/pwd/dirname/basename, which behave identically on Linux and macOS.
# ---------------------------------------------------------------------------
abspath() {
    local target="$1" dir suffix
    if [ -d "$target" ]; then
        (cd "$target" && pwd)
        return
    fi
    dir="$(dirname -- "$target")"
    suffix="$(basename -- "$target")"
    while [ ! -d "$dir" ]; do
        suffix="$(basename -- "$dir")/$suffix"
        dir="$(dirname -- "$dir")"
    done
    printf '%s/%s\n' "$(cd "$dir" && pwd)" "$suffix"
}

# ---------------------------------------------------------------------------
# Parse args: pull --dry-run/-n out, remaining positionals are SOURCE DEST TRASH
# ---------------------------------------------------------------------------
DRY_RUN=false
POSITIONAL=()
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=true ;;
        *) POSITIONAL+=("$arg") ;;
    esac
done

SOURCE="${POSITIONAL[0]:-$DEFAULT_SOURCE}"
DEST="${POSITIONAL[1]:-$DEFAULT_DEST}"
TRASH="${POSITIONAL[2]:-${DEST}_trash}"   # sibling of DEST by default, e.g. folderA_trash

# Normalize paths (resolves relative paths / trailing slashes) so the
# "trash must not be inside dest" check below is reliable.
SOURCE="$(abspath "$SOURCE")"
DEST="$(abspath "$DEST")"
TRASH="$(abspath "$TRASH")"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/sync_$(date +%Y%m%d_%H%M%S).log"
RUN_STAMP="$(date +%Y%m%d_%H%M%S)_$$"
RUN_TRASH_DIR="$TRASH/$RUN_STAMP"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

# ---------------------------------------------------------------------------
# Prevent overlapping runs (matters once this is on a cron schedule).
# Uses flock where available (Linux); falls back to a portable mkdir-based
# lock where it isn't (e.g. macOS, which doesn't ship flock at all). mkdir
# is atomic on every filesystem that matters, so it works as a lock too.
# ---------------------------------------------------------------------------
LOCK_ACQUIRED=false
if command -v flock >/dev/null 2>&1; then
    exec 200>"$LOCK_FILE"
    if flock -n 200; then
        LOCK_ACQUIRED=true
    fi
else
    if mkdir "${LOCK_FILE}.d" 2>/dev/null; then
        LOCK_ACQUIRED=true
        trap 'rmdir "${LOCK_FILE}.d" 2>/dev/null' EXIT
    fi
fi

if [ "$LOCK_ACQUIRED" != true ]; then
    log "Another sync is already running (lock held) — exiting."
    exit 1
fi

# ---------------------------------------------------------------------------
# Safety checks
# ---------------------------------------------------------------------------
command -v rsync >/dev/null 2>&1 || { log "ERROR: rsync is not installed."; exit 1; }

if [ ! -d "$SOURCE" ]; then
    log "ERROR: Source '$SOURCE' does not exist. Aborting — not touching DEST."
    exit 1
fi

ITEM_COUNT=$(find "$SOURCE" -mindepth 1 | wc -l | tr -d ' ')
if [ "$ITEM_COUNT" -lt "$MIN_SOURCE_ITEMS" ]; then
    log "ERROR: Source '$SOURCE' looks empty ($ITEM_COUNT items). Aborting — not touching DEST."
    exit 1
fi

# TRASH must live outside DEST — otherwise rsync's --delete would see the
# trash folder itself as "extra" (it doesn't exist in SOURCE) and try to
# wipe it on the next run.
case "$TRASH" in
    "$DEST"/*|"$DEST")
        log "ERROR: TRASH ('$TRASH') is inside DEST ('$DEST'). Pick a location outside DEST."
        exit 1
        ;;
esac

mkdir -p "$DEST"
mkdir -p "$TRASH"

# ---------------------------------------------------------------------------
# Sync
# ---------------------------------------------------------------------------
RSYNC_OPTS=(-a -h -v --delete --delete-during --itemize-changes
            --backup --backup-dir="$RUN_TRASH_DIR")

if [ "$DRY_RUN" = true ]; then
    RSYNC_OPTS+=(--dry-run)
    log "DRY RUN — previewing only, nothing will actually change."
fi

log "Syncing: $SOURCE -> $DEST  (replaced/removed items -> $RUN_TRASH_DIR)"

set +e
rsync "${RSYNC_OPTS[@]}" "$SOURCE"/ "$DEST"/ | tee -a "$LOG_FILE"
RSYNC_EXIT=${PIPESTATUS[0]}
set -e

if [ "$RSYNC_EXIT" -eq 0 ]; then
    if [ "$DRY_RUN" = false ] && [ -d "$RUN_TRASH_DIR" ]; then
        # something was actually replaced/removed this run — keep a copy of
        # this run's log right alongside what got trashed, for easy review
        cp "$LOG_FILE" "$RUN_TRASH_DIR/CHANGES.log" 2>/dev/null || true
        log "Items moved to trash this run: $RUN_TRASH_DIR"
    else
        # nothing was trashed (or dry run) — don't leave an empty dated
        # folder behind
        rmdir "$RUN_TRASH_DIR" 2>/dev/null || true
    fi
    log "Sync completed successfully."
else
    log "Sync exited with code $RSYNC_EXIT — see $LOG_FILE"
fi

exit "$RSYNC_EXIT"
