#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
if ! command -v pwndbg >/dev/null 2>&1; then
  log "Installing Pwndbg portable for GDB"
  curl --proto '=https' --tlsv1.2 -LsSf 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb
else ok "Pwndbg already present"; fi
for cmd in gdb gdb-multiarch checksec rz-bin qemu-x86_64 jadx apktool; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd: $(command -v "$cmd")"; else warn "$cmd not found"; fi
done
