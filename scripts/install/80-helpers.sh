#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
for f in ctfnew ctf-mcp ctfdoctor ghidra-ai ctftriage ctfflag ctfsolve ctfmodel ctfhub ctfstudio; do install -m 0755 "$ROOT/scripts/bin/$f" "$HOME/.local/bin/$f"; done
mkdir -p "$HOME/.local/share/ctf-ai-workstation"
rm -rf "$HOME/.local/share/ctf-ai-workstation/challenge-template"
cp -a "$ROOT/templates/challenge" "$HOME/.local/share/ctf-ai-workstation/challenge-template"
mkdir -p "$HOME/.config/ctf-ai"
cp "$ROOT/config/shell.zsh" "$HOME/.config/ctf-ai/shell.zsh"
ZSHRC="$HOME/.zshrc"; touch "$ZSHRC"
source_line='[[ -f "$HOME/.config/ctf-ai/shell.zsh" ]] && source "$HOME/.config/ctf-ai/shell.zsh"'
if ! grep -Fqx "$source_line" "$ZSHRC"; then printf '\n# AI CTF Workstation\n%s\n' "$source_line" >> "$ZSHRC"; fi
# ctfstudio desktop GUI: needs Tk, plus a menu entry for the Kali desktop
if ! python3 -c 'import tkinter' >/dev/null 2>&1; then
  log "Installing python3-tk for the ctfstudio GUI"
  sudo apt-get install -y python3-tk || warn "Could not install python3-tk; run: sudo apt-get install -y python3-tk"
fi
apps="$HOME/.local/share/applications"; mkdir -p "$apps"
cat > "$apps/ctfstudio.desktop" <<EOF_DESKTOP
[Desktop Entry]
Type=Application
Name=CTF Studio
Comment=AI CTF workstation: challenges, files, prompts and agents
Exec=$HOME/.local/bin/ctfstudio
Icon=utilities-terminal
Terminal=false
Categories=Development;Security;
EOF_DESKTOP
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$apps" >/dev/null 2>&1 || true
ok "Helpers installed under $HOME/.local/bin"
