#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
[[ "${EUID}" -ne 0 ]] || die "Run as a normal user, not root."
command -v sudo >/dev/null || die "sudo is required"
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  log "Detected: ${PRETTY_NAME:-unknown Linux}"
  if [[ "${ID:-}" != "kali" && "${ID_LIKE:-}" != *debian* ]]; then warn "Tested on Kali Rolling; package changes may be needed here."; fi
fi
avail_kb=$(df -Pk "$HOME" | awk 'NR==2 {print $4}')
if (( avail_kb < 15*1024*1024 )); then warn "Less than 15 GiB free under $HOME."; fi
mkdir -p "$HOME/tools" "$HOME/ctf" "$HOME/.config/ctf-ai"
ok "Preflight passed"
