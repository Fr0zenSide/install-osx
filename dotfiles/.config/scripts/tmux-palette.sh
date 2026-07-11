#!/bin/bash
# Command palette for tmux — file finder + tools

TARGET_PANE="$1"

# Build the list: tools first, then project files
items=$(printf "[flsh] Voice AI\n"; fd --type f --hidden --exclude .git 2>/dev/null)

# Run fzf
selected=$(echo "$items" | fzf \
    --layout reverse \
    --preview 'if [[ {} == \[flsh\]* ]]; then echo "Launch Flsh voice AI assistant"; else bat --style=numbers,changes --color=always --line-range :300 {} 2>/dev/null || echo "{}"; fi' \
    --preview-window 'right:60%:border-left' \
    --header '⏎ open · ⌃Y copy path' \
    --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)+abort')

[ -z "$selected" ] && exit 0

if [[ "$selected" == "[flsh]"* ]]; then
    tmux send-keys -t "$TARGET_PANE" '~/.local/share/flsh-cli' Enter
else
    tmux send-keys -t "$TARGET_PANE" "emacs '$selected'" Enter
fi
