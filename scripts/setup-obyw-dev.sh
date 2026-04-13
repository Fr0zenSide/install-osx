#!/bin/bash
# ─────────────────────────────────────────────────────────────
# setup-obyw-dev.sh — Setup OBYW.one agency dev environment
#
# Run this on a fresh Mac after install-osx.sh.
# Installs tools, copies configs, starts local dev stack.
#
# Usage:
#   ./scripts/setup-obyw-dev.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOTFILES="$DIR/dotfiles/.config"
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}▸${NC} $1"; }
warn() { echo -e "${YELLOW}▸${NC} $1"; }
step() { echo -e "\n${BOLD}═══ $1${NC}\n"; }

step "1/7 — Brew tools"
TOOLS=(caddy ntfy dnsmasq pyright bash-language-server)
for tool in "${TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    log "Installing $tool..."
    brew install "$tool"
  else
    log "$tool: already installed"
  fi
done

step "2/7 — Shikki config"
mkdir -p ~/.config/shikki/keys
if [ ! -f ~/.config/shikki/.env ]; then
  cp "$DOTFILES/shikki/.env.template" ~/.config/shikki/.env
  chmod 600 ~/.config/shikki/.env
  warn ".env created from template — fill values: nano ~/.config/shikki/.env"
else
  log ".env already exists"
fi

# Copy ASC keys if they exist in dotfiles
if ls "$DOTFILES/shikki/keys/"*.p8 &>/dev/null; then
  cp -n "$DOTFILES/shikki/keys/"*.p8 ~/.config/shikki/keys/ 2>/dev/null || true
  chmod 600 ~/.config/shikki/keys/*.p8 2>/dev/null || true
  log "ASC keys copied"
else
  warn "No .p8 keys in dotfiles — copy manually to ~/.config/shikki/keys/"
fi

step "3/7 — Python venv (PyJWT for ASC)"
bash "$DOTFILES/shikki/setup-venv.sh"

step "4/7 — SSH key for VPS"
if [ ! -f ~/.ssh/id_ed25519 ]; then
  warn "No SSH key found. Generate one:"
  warn "  ssh-keygen -t ed25519 -C \"$(whoami)@$(hostname)\""
  warn "  ssh-copy-id jeo@92.134.242.73"
else
  log "SSH key exists"
  if ! ssh -o BatchMode=yes -o ConnectTimeout=3 jeo@92.134.242.73 "echo ok" &>/dev/null; then
    warn "SSH key not on VPS yet. Run: ssh-copy-id jeo@92.134.242.73"
  else
    log "VPS SSH: connected"
  fi
fi

step "5/7 — ASC altool key symlink"
mkdir -p ~/.appstoreconnect/private_keys
for key in ~/.config/shikki/keys/AuthKey_*.p8; do
  [ -f "$key" ] || continue
  ln -sf "$key" ~/.appstoreconnect/private_keys/"$(basename "$key")" 2>/dev/null
done
log "altool keys symlinked"

step "6/7 — Caddy local CA trust"
sudo caddy trust 2>/dev/null || warn "Caddy trust failed — run: sudo caddy trust"

step "7/7 — LaunchAgent"
AGENT_SRC="$DIR/dotfiles/LaunchAgents/one.obyw.local-dev.plist"
AGENT_DST="$HOME/Library/LaunchAgents/one.obyw.local-dev.plist"
if [ -f "$AGENT_SRC" ]; then
  # Update paths for this user
  sed "s|/Users/jeoffrey|$HOME|g" "$AGENT_SRC" > "$AGENT_DST"
  launchctl unload "$AGENT_DST" 2>/dev/null || true
  launchctl load "$AGENT_DST"
  log "LaunchAgent installed — local dev starts on login"
else
  warn "LaunchAgent plist not found in dotfiles"
fi

step "Done"
echo ""
log "OBYW.one dev environment ready."
echo ""
echo "  Next steps:"
echo "    1. Fill secrets:    nano ~/.config/shikki/.env"
echo "    2. Clone repos:     git clone ... obyw-one && git clone ... shiki"
echo "    3. Start dev:       cd obyw-one && ./obyw dev start"
echo "    4. Open:            ./obyw dev open"
echo "    5. iPhone setup:    ./obyw dev lan"
echo ""
