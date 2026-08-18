#!/usr/bin/env bash
set -euo pipefail
[[ "${EUID}" -ne 0 ]] || { echo "Run as your normal user; this calls sudo." >&2; exit 1; }
sudo mkdir -p /etc/apt/sources.list.d
cat <<'EOF_KALI' | sudo tee /etc/apt/sources.list.d/kali.sources >/dev/null
Types: deb
URIs: http://http.kali.org/kali/
Suites: kali-rolling
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/kali-archive-keyring.gpg
EOF_KALI
if [[ -f /etc/apt/sources.list ]]; then
  sudo cp /etc/apt/sources.list "/etc/apt/sources.list.backup.$(date +%Y%m%d%H%M%S)"
  sudo sed -i '/^[[:space:]]*deb .*kali-rolling/s/^/# disabled by ai-ctf-workstation: /' /etc/apt/sources.list
fi
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo mkdir -p /var/lib/apt/lists/partial
sudo apt-get update
sudo dpkg --configure -a
sudo apt-get -f install -y
echo "APT metadata repaired. If far behind, run: sudo apt full-upgrade -y && sudo reboot"
