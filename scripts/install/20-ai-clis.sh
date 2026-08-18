#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
command -v npm >/dev/null || die "npm missing; run 10-system.sh first"
npm config set prefix "$HOME/.local"
export PATH="$HOME/.local/bin:$PATH"
log "Installing/updating OpenAI Codex CLI"
npm install -g @openai/codex
log "Installing/updating Playwright CLI"
npm install -g @playwright/cli@latest
if [[ "${SKIP_ANTIGRAVITY:-0}" != "1" ]]; then log "Installing/updating Google Antigravity CLI"; curl -fsSL https://antigravity.google/cli/install.sh | bash; fi
if [[ "${SKIP_CLAUDE:-0}" != "1" ]]; then log "Installing/updating Claude Code"; curl -fsSL https://claude.ai/install.sh | bash; fi
if [[ "${INSTALL_LEGACY_GEMINI:-0}" == "1" ]]; then log "Installing optional legacy Gemini CLI"; npm install -g @google/gemini-cli@latest; fi
hash -r || true
command -v codex >/dev/null && codex --version || true
command -v agy >/dev/null && agy --version || true
command -v claude >/dev/null && claude --version || true
ok "AI CLIs installed. Authenticate each teammate's own accounts later."
