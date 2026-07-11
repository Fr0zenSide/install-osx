#!/bin/bash
# Grep project content and open at line in emacs

TARGET_PANE="$1"

selected=$(rg --color=always --line-number --no-heading --smart-case "" | fzf \
    --ansi \
    --layout reverse \
    --delimiter : \
    --preview 'bat --style=numbers,changes --color=always --highlight-line {2} --line-range {2}: {1}' \
    --preview-window 'right:60%:border-left:+{2}-10' \
    --header '⏎ open at line')

[ -z "$selected" ] && exit 0

file=$(echo "$selected" | cut -d: -f1)
line=$(echo "$selected" | cut -d: -f2)
tmux send-keys -t "$TARGET_PANE" "emacs +${line} '${file}'" Enter
