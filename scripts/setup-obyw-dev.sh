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

step "1/8 — Brew tools"
TOOLS=(caddy ntfy dnsmasq pyright bash-language-server hcloud restic)
for tool in "${TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    log "Installing $tool..."
    brew install "$tool"
  else
    log "$tool: already installed"
  fi
done

step "1b/8 — Hetzner automation toolchain"
# hcloud: VPS provisioning (Tier-1 agency hosts per
# features/infra-progression-ansible-hetzner-2026-05-14.md). Already in TOOLS above.
log "hcloud: $(hcloud version 2>&1 | head -1)"
warn "  Token (first-use): https://console.hetzner.cloud/projects → API Tokens"
warn "  Save: hcloud context create obyw  (paste token at prompt)"

# Hetzner DNS — for *.obyw.one migration to Hetzner DNS
if ! command -v pipx &>/dev/null; then brew install pipx && pipx ensurepath; fi
if ! pipx list 2>&1 | grep -q hetzner-dns-tools; then
  log "Installing hetzner-dns-tools (DNS automation)..."
  pipx install hetzner-dns-tools || warn "hetzner-dns-tools install failed (network?)"
else
  log "hetzner-dns-tools: already installed"
fi
warn "  Token (first-use): https://dns.hetzner.com/settings/api-token"
warn "  Save: echo \"<token>\" > ~/.config/hetzner-dns/token && chmod 600 ~/.config/hetzner-dns/token"

# Hetzner Robot — Storage Box + dedicated server management
if ! pipx list 2>&1 | grep -q hetzner-robot; then
  log "Installing hetzner-robot (Robot API CLI)..."
  pipx install hetzner-robot || warn "hetzner-robot install failed (network?)"
else
  log "hetzner-robot: already installed"
fi
warn "  Auth (first-use): Robot username + password from https://robot.hetzner.com"
warn "  Save: ~/.config/hetzner-robot/credentials (chmod 600)"

# hetznercloud-mcp-server — Claude/agent direct Hetzner ops via MCP
if ! command -v node &>/dev/null; then
  warn "node not installed — skipping hetznercloud-mcp-server (install node first)"
elif ! npm list -g 2>&1 | grep -q hetznercloud-mcp-server; then
  log "Installing @hetznercloud/mcp-server (MCP server)..."
  npm install -g @hetznercloud/mcp-server 2>&1 | tail -3 || \
    warn "  npm install failed — fallback: docker pull hetznercloud/mcp-server"
else
  log "hetznercloud-mcp-server: already installed"
fi
warn "  Wire (post-install): add to ~/.claude.json mcpServers with HCLOUD_TOKEN env"

# Cred-dir layout
mkdir -p ~/.config/hcloud ~/.config/hetzner-dns ~/.config/hetzner-robot
chmod 700 ~/.config/hcloud ~/.config/hetzner-dns ~/.config/hetzner-robot 2>/dev/null || true
log "Hetzner cred dirs created (mode 700)."
warn "  Future: post-G-06 ceremony, all 3 tokens migrate into ShikkiSecrets broker"
warn "  → shi secret set hetzner/{cloud-token,dns-token,robot-creds} …"

step "2/8 — Shikki config"
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

step "3/8 — Python venv (PyJWT for ASC)"
bash "$DOTFILES/shikki/setup-venv.sh"

step "4/8 — SSH key for VPS"
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

step "5/8 — ASC altool key symlink"
mkdir -p ~/.appstoreconnect/private_keys
for key in ~/.config/shikki/keys/AuthKey_*.p8; do
  [ -f "$key" ] || continue
  ln -sf "$key" ~/.appstoreconnect/private_keys/"$(basename "$key")" 2>/dev/null
done
log "altool keys symlinked"

step "6/8 — Caddy local CA trust"
sudo caddy trust 2>/dev/null || warn "Caddy trust failed — run: sudo caddy trust"

step "7/8 — LaunchAgent"
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

step "8/8 — Restic offsite-sync launchd plist"
# Weekly Sunday 03:00 sync to nuc-dev primary + obyw-exit-de off-site
RESTIC_PLIST="$HOME/Library/LaunchAgents/one.obyw.shikki.restic-offsite-sync.plist"
if [ ! -f "$RESTIC_PLIST" ] && [ -f "$HOME/.shikki/scripts/restic-offsite-sync.sh" ]; then
  log "Loading weekly restic offsite-sync launchd plist..."
  launchctl load -w "$RESTIC_PLIST" 2>&1 | tail -2
elif [ -f "$RESTIC_PLIST" ]; then
  log "restic offsite-sync launchd plist: already loaded"
else
  warn "restic offsite-sync script not yet installed at ~/.shikki/scripts/restic-offsite-sync.sh"
fi

step "Done"
echo ""
log "OBYW.one dev environment ready."
echo ""
echo "  Next steps:"
echo "    1. Fill secrets:    nano ~/.config/shikki/.env"
echo "    2. Clone repos:     git clone ... obyw-one && git clone ... shikki"
echo "    3. Start dev:       cd obyw-one && ./obyw dev start"
echo "    4. Open:            ./obyw dev open"
echo "    5. iPhone setup:    ./obyw dev lan"
echo ""
