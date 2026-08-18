#!/usr/bin/env bash
set -euo pipefail
log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }
ensure_local_path() { export PATH="$HOME/.local/bin:$PATH"; mkdir -p "$HOME/.local/bin"; }
apt_install_available() {
  local pkgs=() p
  for p in "$@"; do
    if apt-cache show "$p" >/dev/null 2>&1; then pkgs+=("$p"); else warn "APT package not available in current indexes: $p"; fi
  done
  if ((${#pkgs[@]})); then sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"; fi
}
