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

# window resize
To resize down, use: CtrlB:resize-p -D 2
To resize up, use: CtrlB:resize-p -U 2
To resize left, use: CtrlB:resize-p -L 2
To resize right, use: CtrlB:resize-p -R 2
