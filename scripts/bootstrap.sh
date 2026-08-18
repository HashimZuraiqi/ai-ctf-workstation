#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
cat <<'EOF'
AI CTF Workstation bootstrap
============================
This installs a reproducible toolchain for authorized CTF/lab use.
No provider credentials or login tokens are copied by this repository.
EOF
[[ "${EUID}" -ne 0 ]] || die "Run this as your normal Kali user, not root. The scripts will call sudo when needed."
for phase in 00-preflight.sh 10-system.sh 20-ai-clis.sh 30-python.sh 35-forensics.sh 36-crypto.sh 37-osint.sh 40-native.sh 50-ghidra-mcp.sh 55-category-mcps.sh 60-browser.sh 70-skills.sh 80-helpers.sh 90-mcp.sh; do
  log "Running $phase"
  "$ROOT/scripts/install/$phase"
done
ok "Bootstrap complete. Run: exec zsh"
ok "Then authenticate your own providers and run: ctfdoctor"
