#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
if ! command -v uv >/dev/null 2>&1; then log "Installing uv"; curl -LsSf https://astral.sh/uv/install.sh | sh; export PATH="$HOME/.local/bin:$PATH"; fi
uv python install 3.12
VENV="$HOME/.venvs/ctf-core"
mkdir -p "$HOME/.venvs"
[[ -x "$VENV/bin/python" ]] || uv venv --python 3.12 "$VENV"
packages=(pwntools z3-solver pycryptodome sympy capstone unicorn keystone-engine lief ropper ROPGadget requests beautifulsoup4 lxml pillow ipython angr)
uv pip install --python "$VENV/bin/python" "${packages[@]}"
"$VENV/bin/python" - <<'PY_IMPORTS'
mods = ['pwn','z3','Crypto','sympy','capstone','unicorn','keystone','lief','ropper','requests','bs4','lxml','PIL','angr']
failed=[]
for m in mods:
    try: __import__(m)
    except Exception as e: failed.append((m,repr(e)))
if failed: raise SystemExit('Import failures: '+repr(failed))
print('Python CTF environment imports: OK')
PY_IMPORTS
ok "Python CTF environment ready: $VENV"
