#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
log "Refreshing Kali package indexes"
if ! sudo apt-get update; then warn "APT update failed. If you see many 404s, run: $ROOT/scripts/repair-kali-apt.sh"; exit 1; fi
base=(ca-certificates curl wget git jq unzip zip xz-utils file build-essential pkg-config gcc g++ make cmake python3 python3-venv python3-dev nodejs npm openjdk-21-jdk maven)
native=(gdb gdb-multiarch gdbserver patchelf strace ltrace checksec rizin cutter qemu-user qemu-user-static jadx apktool)
web=(nmap ffuf gobuster feroxbuster whatweb sqlmap nuclei amass)
forensics=(tshark wireshark binwalk libimage-exiftool-perl john hashcat foremost yara sleuthkit testdisk pngcheck steghide)
containers=(docker.io docker-compose docker-compose-plugin)
apt_install_available "${base[@]}"
apt_install_available "${native[@]}"
apt_install_available "${web[@]}"
apt_install_available "${forensics[@]}"
apt_install_available "${containers[@]}"
if command -v docker >/dev/null 2>&1; then
  sudo systemctl enable --now docker 2>/dev/null || true
  if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then sudo usermod -aG docker "$USER" || true; warn "Docker group change may require logout/login."; fi
fi
ok "System packages installed"
