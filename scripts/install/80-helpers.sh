#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
for f in ctfnew ctf-mcp ctfdoctor ghidra-ai ctftriage ctfflag ctfsolve ctfmodel; do install -m 0755 "$ROOT/scripts/bin/$f" "$HOME/.local/bin/$f"; done
mkdir -p "$HOME/.local/share/ctf-ai-workstation"
rm -rf "$HOME/.local/share/ctf-ai-workstation/challenge-template"
cp -a "$ROOT/templates/challenge" "$HOME/.local/share/ctf-ai-workstation/challenge-template"
mkdir -p "$HOME/.config/ctf-ai"
cp "$ROOT/config/shell.zsh" "$HOME/.config/ctf-ai/shell.zsh"
ZSHRC="$HOME/.zshrc"; touch "$ZSHRC"
source_line='[[ -f "$HOME/.config/ctf-ai/shell.zsh" ]] && source "$HOME/.config/ctf-ai/shell.zsh"'
if ! grep -Fqx "$source_line" "$ZSHRC"; then printf '\n# AI CTF Workstation\n%s\n' "$source_line" >> "$ZSHRC"; fi
ok "Helpers installed under $HOME/.local/bin"
