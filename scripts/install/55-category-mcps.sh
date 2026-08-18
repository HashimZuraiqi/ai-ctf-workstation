#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
command -v uv >/dev/null 2>&1 || die "uv is required; run 30-python.sh first"
mkdir -p "$HOME/tools"
for name in forensics crypto osint; do
  src="$ROOT/mcp_servers/$name"
  dst="$HOME/tools/ctf-$name-mcp"
  log "Installing custom $name MCP server -> $dst"
  rm -rf "$dst"
  cp -a "$src" "$dst"
  uv sync --project "$dst"
  python3 -m py_compile "$dst/server.py"
done
ok "Custom Forensics/Crypto/OSINT MCP servers installed"
