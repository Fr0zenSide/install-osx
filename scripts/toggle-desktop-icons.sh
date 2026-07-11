#!/bin/bash
# toggle-desktop-icons.sh — show/hide all icons on the macOS Desktop in one click.
#
# Mechanism: Finder's `CreateDesktop` preference controls whether the Desktop
# layer draws icons at all. Toggling it + relaunching Finder is instant and
# non-destructive (files stay in ~/Desktop, only rendering is disabled).
#
# Installed as the executable of "~/Applications/Toggle Desktop Icons.app"
# so it can live in the Dock. Source of truth: install-osx/scripts/.

current=$(defaults read com.apple.finder CreateDesktop 2>/dev/null || echo "1")

if [[ "$current" == "1" || "$current" == "true" ]]; then
    defaults write com.apple.finder CreateDesktop -bool false
    msg="Desktop icons hidden"
else
    defaults write com.apple.finder CreateDesktop -bool true
    msg="Desktop icons shown"
fi

killall Finder

# Non-blocking toast so you get feedback from the Dock click.
osascript -e "display notification \"$msg\" with title \"Toggle Desktop Icons\"" >/dev/null 2>&1 &

exit 0
