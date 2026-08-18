#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
log "Installing extended forensics toolkit"
packages=(
  foremost yara sleuthkit testdisk scalpel bulk-extractor hashdeep ssdeep
  dc3dd dcfldd gddrescue ewf-tools xmount ext4magic extundelete recoverjpeg
  magicrescue pdfid pdf-parser sqlitebrowser forensic-artifacts tcpflow
  tcpreplay steghide stegseek pngcheck oletools autopsy plaso cabextract unar
  p7zip-full libhivex-bin regripper rifiuti2 dumpzilla grokevt afflib-tools
  zbar-tools ruby ruby-dev
)
apt_install_available "${packages[@]}"

if command -v uv >/dev/null 2>&1 && ! command -v vol >/dev/null 2>&1; then
  log "Installing Volatility 3 as an isolated uv tool"
  uv tool install --force volatility3 || warn "Volatility3 uv install failed; retry later with: uv tool install --force volatility3"
fi

if ! command -v zsteg >/dev/null 2>&1 && command -v gem >/dev/null 2>&1; then
  log "Installing zsteg with RubyGems"
  gem install --user-install zsteg --no-document || warn "zsteg gem install failed"
  if command -v ruby >/dev/null 2>&1; then
    GEMBIN="$(ruby -e 'print Gem.user_dir')/bin/zsteg"
    [[ -x "$GEMBIN" ]] && ln -sfn "$GEMBIN" "$HOME/.local/bin/zsteg"
  fi
fi
ok "Extended forensics phase complete"
