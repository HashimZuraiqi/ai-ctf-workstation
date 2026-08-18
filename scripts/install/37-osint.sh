#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
ensure_local_path
log "Installing OSINT toolkit"
packages=(whois dnsutils dnsrecon dnsenum massdns amass subfinder assetfinder theharvester sherlock spiderfoot recon-ng metagoofil waybackpy instaloader photon jq curl wget libimage-exiftool-perl)
apt_install_available "${packages[@]}"
if command -v uv >/dev/null 2>&1 && ! command -v maigret >/dev/null 2>&1; then
  uv tool install --python 3.12 --force maigret || warn "Maigret install failed"
fi
ok "OSINT phase complete"
