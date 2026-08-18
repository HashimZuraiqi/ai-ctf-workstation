#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
mkdir -p "$HOME/.config/ctf-ai" "$HOME/ctf/browser-artifacts"
sed "s|__HOME__|$HOME|g" "$ROOT/config/playwright-mcp.json.template" > "$HOME/.config/ctf-ai/playwright-mcp.json"
cp "$ROOT/config/playwright-cli.json.template" "$HOME/.config/ctf-ai/playwright-cli.json"
log "Installing Playwright-managed Chromium"
npx playwright install chromium || warn "Chromium download failed now; retry on first use."
ok "Playwright configs written under $HOME/.config/ctf-ai"
