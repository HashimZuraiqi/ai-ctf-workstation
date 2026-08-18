#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
log "Installing crypto/math toolkit"
apt_install_available pari-gp libpari-dev libgmp-dev libmpfr-dev libmpc-dev hashid name-that-hash hash-identifier john hashcat openssl ccrypt aesfix aeskeyfind stegsnow

VENV="$HOME/.venvs/ctf-core"
if [[ -x "$VENV/bin/python" ]]; then
  uv pip install --python "$VENV/bin/python" gmpy2 fpylll cysignals ecdsa cryptography pyasn1 base58 bitarray
else
  warn "CTF Python venv missing; run 30-python.sh first"
fi

command -v xortool >/dev/null 2>&1 || uv tool install xortool || warn "xortool install failed"

RSADIR="$HOME/tools/RsaCtfTool"
if [[ ! -d "$RSADIR/.git" ]]; then
  mkdir -p "$HOME/tools"
  git clone --depth 1 https://github.com/RsaCtfTool/RsaCtfTool.git "$RSADIR" || warn "RsaCtfTool clone failed"
fi
if [[ -d "$RSADIR" ]]; then
  [[ -x "$RSADIR/.venv/bin/python" ]] || uv venv --python 3.12 "$RSADIR/.venv"
  uv pip install --python "$RSADIR/.venv/bin/python" -e "$RSADIR" || warn "RsaCtfTool Python install failed"
  cat > "$HOME/.local/bin/RsaCtfTool" <<WRAP
#!/usr/bin/env bash
if [[ -x "$RSADIR/.venv/bin/RsaCtfTool" ]]; then
  exec "$RSADIR/.venv/bin/RsaCtfTool" "\$@"
fi
exec "$RSADIR/.venv/bin/python" "$RSADIR/RsaCtfTool.py" "\$@"
WRAP
  chmod +x "$HOME/.local/bin/RsaCtfTool"
fi

# Sage is intentionally isolated in Miniforge so Kali's system Python stays untouched.
if [[ "${CTF_SKIP_SAGE:-0}" != "1" ]] && ! command -v sage >/dev/null 2>&1; then
  MINIFORGE="$HOME/miniforge3"
  if [[ ! -x "$MINIFORGE/bin/conda" ]]; then
    log "Installing Miniforge for isolated SageMath (large download/install)"
    arch="$(uname -m)"
    case "$arch" in x86_64) mfarch=x86_64 ;; aarch64|arm64) mfarch=aarch64 ;; *) warn "Unsupported Miniforge arch: $arch; skipping Sage"; mfarch="" ;; esac
    if [[ -n "$mfarch" ]]; then
      tmp="$(mktemp)"
      curl -LfsS "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${mfarch}.sh" -o "$tmp"
      bash "$tmp" -b -p "$MINIFORGE"
      rm -f "$tmp"
    fi
  fi
  if [[ -x "$MINIFORGE/bin/conda" ]]; then
    if ! "$MINIFORGE/bin/conda" env list | awk '{print $1}' | grep -qx sage; then
      "$MINIFORGE/bin/conda" create -y -n sage -c conda-forge sage
    fi
    [[ -x "$MINIFORGE/envs/sage/bin/sage" ]] && ln -sfn "$MINIFORGE/envs/sage/bin/sage" "$HOME/.local/bin/sage"
  fi
else
  [[ "${CTF_SKIP_SAGE:-0}" == "1" ]] && warn "Skipping Sage because CTF_SKIP_SAGE=1"
fi
ok "Crypto/math phase complete"
