#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
GHIDRA_VERSION="12.1.2"
GHIDRA_BUILD="20260605"
GHIDRA_DIR="$HOME/tools/ghidra_${GHIDRA_VERSION}_PUBLIC"
GHIDRA_ZIP="ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_BUILD}.zip"
GHIDRA_URL="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/${GHIDRA_ZIP}"
GHIDRA_SHA256="b62e81a0390618466c019c60d8c2f796ced2509c4c1aea4a37644a77272cf99d"
MCP_DIR="$HOME/tools/ghidra-mcp"
JAVA21="/usr/lib/jvm/java-21-openjdk-amd64"
[[ -x "$JAVA21/bin/java" ]] || die "Java 21 not found at $JAVA21. Run 10-system.sh first."
command -v uv >/dev/null || die "uv missing; run 30-python.sh first"
mkdir -p "$HOME/tools"
if [[ ! -d "$GHIDRA_DIR" ]]; then
  log "Downloading official Ghidra $GHIDRA_VERSION"
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  curl -fL "$GHIDRA_URL" -o "$tmp/$GHIDRA_ZIP"
  printf '%s  %s\n' "$GHIDRA_SHA256" "$tmp/$GHIDRA_ZIP" | sha256sum -c -
  unzip -q "$tmp/$GHIDRA_ZIP" -d "$HOME/tools"
  chmod +x "$GHIDRA_DIR/ghidraRun" 2>/dev/null || true
else ok "Ghidra already present: $GHIDRA_DIR"; fi
if [[ ! -d "$MCP_DIR/.git" ]]; then git clone https://github.com/bethington/ghidra-mcp.git "$MCP_DIR"; else git -C "$MCP_DIR" pull --ff-only || warn "Keeping current Ghidra MCP checkout"; fi
export JAVA_HOME="$JAVA21"
export PATH="$JAVA_HOME/bin:$HOME/.local/bin:$PATH"
hash -r
(
  cd "$MCP_DIR"
  uv run python -m tools.setup preflight --ghidra-path "$GHIDRA_DIR"
  uv run python -m tools.setup build
  uv run python -m tools.setup deploy --ghidra-path "$GHIDRA_DIR"
)
ok "Ghidra $GHIDRA_VERSION + Ghidra MCP deployed"
