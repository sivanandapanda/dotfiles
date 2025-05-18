# Installation
- install tmux
- install tmux plugin manager (git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm)
- source into tmux as (tmux source ~/.tmux.conf)
- them press "Prefix + I" to install the plugin.
- thats it!

# commands

- "Prefix + ?" -> to check available key bindings

## panes
- "Prefix + %" -> vertical split
- 'Prefix + "' -> horizental split
- "Prefic + q" -> display pane numbers
- "Prefic + q + pane number" -> to navigate to the pane
- "Ctr + d" -> kill/close a pane

## window
- "Prefix + c" -> create a new window
- "Prefix + n" -> next window
- "Prefix + p" -> previous window
- "Prefix + window number" -> switch to particular window
- "Prefix + ," -> rename window
- "Prefix + &" -> kill current window

## window resize
- "Prefix + Alt + arrow key" -> resize pane
- "Prefix + Alt + h" -> resize left

### alternative way to resize
- To resize down, use: CtrlB:resize-p -D 2
- To resize up, use: CtrlB:resize-p -U 2
- To resize left, use: CtrlB:resize-p -L 2
- To resize right, use: CtrlB:resize-p -R 2

## copy paste
- "Prefix + [" -> enter copy mode
- "space" -> start selection
- "enter" -> copy selection
- "Prefix + ]" -> paste

## scroll
- "Prefix + [" -> enter copy mode
- "up arrow" -> scroll up
- "down arrow" -> scroll down

## list all tmux sessions
- "tmux list-sessions" or "tmux ls"
- "tmux attach-session -t session_name" or "tmux a -t session_name"
- "tmux kill-session -t session_name" or "tmux kill-ses -t session_name"

## list all windows inside a session
- "Prefix + w" -> list all windows inside a session
- "Prefix + w + window number" -> switch to particular window
- "Prefix + w + window number + pane number" -> switch to particular pane inside a window

