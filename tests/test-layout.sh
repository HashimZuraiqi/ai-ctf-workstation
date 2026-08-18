#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
  README.md SECURITY.md LICENSE scripts/bootstrap.sh scripts/repair-kali-apt.sh scripts/publish-github.sh
  scripts/bin/ctfnew scripts/bin/ctf-mcp scripts/bin/ctfdoctor scripts/bin/ghidra-ai
  scripts/install/35-forensics.sh scripts/install/36-crypto.sh scripts/install/37-osint.sh scripts/install/55-category-mcps.sh
  config/shell.zsh templates/challenge/AGENTS.md
  mcp_servers/forensics/server.py mcp_servers/crypto/server.py mcp_servers/osint/server.py
  mcp_servers/forensics/pyproject.toml mcp_servers/crypto/pyproject.toml mcp_servers/osint/pyproject.toml
  docs/CHEATSHEET.md docs/COMPLETE_STACK.md docs/PUBLISHING.md docs/STATUS.md
  skills/ctf-triage/SKILL.md skills/ctf-reverse/SKILL.md skills/ctf-pwn/SKILL.md skills/ctf-web/SKILL.md
  skills/ctf-crypto/SKILL.md skills/ctf-forensics/SKILL.md skills/ctf-osint/SKILL.md skills/ctf-ai-security/SKILL.md
  skills/ctf-mobile/SKILL.md skills/ctf-misc/SKILL.md skills/ctf-report/SKILL.md
)
for f in "${required[@]}"; do [[ -e "$ROOT/$f" ]] || { echo "missing: $f" >&2; exit 1; }; done
while IFS= read -r -d '' f; do bash -n "$f"; done < <(find "$ROOT/scripts" "$ROOT/tests" -type f -name '*.sh' -print0)
for f in "$ROOT"/scripts/bin/*; do bash -n "$f"; done
python3 - <<PY_TEST
from pathlib import Path
import json, py_compile
root=Path(r'$ROOT')
for p in [root/'config/playwright-mcp.json.template',root/'config/playwright-cli.json.template',root/'templates/challenge/.playwright/cli.config.json']:
    json.loads(p.read_text().replace('__HOME__','/home/test'))
for p in root.glob('mcp_servers/*/server.py'):
    py_compile.compile(str(p), doraise=True)
print('JSON templates and custom MCP Python syntax: OK')
PY_TEST
count=$(find "$ROOT/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l)
[[ "$count" -eq 11 ]] || { echo "expected 11 skills, found $count" >&2; exit 1; }
echo "Repository layout and shell syntax: OK"
