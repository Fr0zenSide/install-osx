#!/bin/bash
# Shikki tmux status-right segments — Dracula rainbow continuation
# Powerline LEFT arrow U+E0B2 (same as Dracula)
SEP=$(printf '\xee\x82\xb2')

# Segment 1: Shikki orchestrator (orange, arrow from cyan)
tmux set -ga status-right "#[fg=#ffb86c,bg=#8be9fd,nobold,nounderscore,noitalics]${SEP}#[fg=#282a36,bg=#ffb86c] #(shikki status --mini --plain 2>/dev/null || echo ?) "

# Segment 2: Project context (pink, arrow from orange)
tmux set -ga status-right "#[fg=#ff79c6,bg=#ffb86c,nobold,nounderscore,noitalics]${SEP}#[fg=#282a36,bg=#ff79c6] #(shikki status --project --plain --path #{pane_current_path} 2>/dev/null || echo ?) "

# Segment 3: Git status (purple, arrow from pink) — last segment, no trailing arrow
tmux set -ga status-right "#[fg=#bd93f9,bg=#ff79c6,nobold,nounderscore,noitalics]${SEP}#[fg=#282a36,bg=#bd93f9] #(shikki status --git --plain --path #{pane_current_path} 2>/dev/null || echo ?) #[default]"
