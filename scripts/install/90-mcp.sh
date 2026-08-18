#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
command -v ctf-mcp >/dev/null || die "ctf-mcp missing; run 80-helpers.sh first"
# Write/normalize the Antigravity entries but finish with the smallest tool surface.
# Codex servers are added on demand by the category profile commands.
ctf-mcp off
ok "MCP configuration initialized in OFF state. Enable a category with mcp-rev, mcp-web, mcp-forensics, etc."
