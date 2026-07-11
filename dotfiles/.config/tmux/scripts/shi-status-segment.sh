#!/usr/bin/env bash
# shi-status-segment.sh — single-segment helper for tmux status-right.
#
# Called from tmux as #(bash ~/.config/tmux/scripts/shi-status-segment.sh <segment>)
# where <segment> is one of: mini, project, git.
#
# Why this wrapper exists (Phase 0 proof-point of the TUI self-improvement
# loop, 2026-04-21):
#   1. tmux 3.6 does NOT expand #{pane_current_path} inside #() format
#      commands — we must query the pane path ourselves via
#      `tmux display-message`.
#   2. `shi status` emits raw ANSI escape codes which tmux renders as
#      literal text ("[38;2;...m"). We pass --plain to strip ANSI.
#
# Timeout: 400ms per call. Zero stderr leak. Empty on failure.
# Arrow rendering: the U+E0B2 glyph at the START of shi's output is
# preserved — it creates the powerline transition when wrapped by the
# appropriate #[fg=...] style blocks in the tmux.conf.

set -u

SEGMENT="${1:-}"
[ -n "$SEGMENT" ] || exit 0

# Query the current pane path from the status-line's target pane.
# If none is known (e.g. during early init), fall back to the server's cwd.
PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}" 2>/dev/null || true)
[ -n "$PANE_PATH" ] || PANE_PATH="$PWD"

# Fast-bail if shi is not on PATH. Keep PATH explicit in case tmux server
# has a minimal env.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
command -v shi >/dev/null 2>&1 || exit 0

run_with_timeout() {
  if command -v timeout >/dev/null 2>&1; then
    timeout 0.4s "$@" 2>/dev/null
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout 0.4s "$@" 2>/dev/null
  else
    "$@" 2>/dev/null
  fi
}

case "$SEGMENT" in
  mini)
    run_with_timeout shi status --mini --plain ;;
  project)
    run_with_timeout shi status --project --plain --path "$PANE_PATH" ;;
  git)
    run_with_timeout shi status --git --plain --path "$PANE_PATH" ;;
  *)
    exit 0 ;;
esac
