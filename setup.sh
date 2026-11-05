#!/usr/bin/env bash
# AI CTF Workstation: one-shot setup from zero on a fresh Kali Linux install.
#
# Paste this into a terminal on Kali (as your normal user, not root):
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/HashimZuraiqi/ai-ctf-workstation/main/setup.sh)
#
# or, from a clone:   ./setup.sh
#
# What it does (safe to re-run; finished steps are skipped or refreshed):
#   1. checks you are a normal sudo user on Kali/Debian, keeps sudo alive
#   2. repairs APT metadata if `apt-get update` fails, installs git/curl/zsh
#   3. clones or updates the repo into ~/tools/ai-ctf-workstation
#   4. runs every install phase (system packages, Codex / Antigravity (agy) /
#      Claude CLIs, Python CTF venv, forensics/crypto/OSINT tools, pwndbg,
#      Ghidra + Ghidra MCP, custom MCP servers, Playwright, skills, helpers:
#      ctfhub, ctfstudio, ctftriage, ctfflag, ctfsolve, ctfmodel, ctfnew, ...)
#      A failing phase is logged and the rest still run.
#   5. wires the shell (cx/ag/cl aliases, PATH) into zsh and bash
#   6. runs ctfdoctor and prints a summary plus what to sign in to
#
# Options:
#   --dir DIR        local clone location (default: ~/tools/ai-ctf-workstation)
#   --ref REF        branch or tag to install (default: main)
#   --only LIST      run only these phases, e.g. --only 20,80  (prefix numbers)
#   --skip LIST      skip these phases, e.g. --skip 36,50
#   --no-update      do not touch an existing clone (use it as is)
#   --stop-on-error  abort at the first failing phase
#   -h, --help       show this help
#
# Environment knobs passed through to the phases:
#   CTF_SKIP_SAGE=1  skip the large SageMath/Miniforge install
#   SKIP_ANTIGRAVITY=1, SKIP_CLAUDE=1, INSTALL_LEGACY_GEMINI=1
#
# No API keys, tokens or logins are installed. Each person signs in afterwards.
set -uo pipefail

REPO_URL="https://github.com/HashimZuraiqi/ai-ctf-workstation.git"
DIR="$HOME/tools/ai-ctf-workstation"
REF="main"
ONLY=""
SKIP=""
NO_UPDATE=0
STOP_ON_ERROR=0

PHASES=(00-preflight 10-system 20-ai-clis 30-python 35-forensics 36-crypto 37-osint
        40-native 50-ghidra-mcp 55-category-mcps 60-browser 70-skills 80-helpers 90-mcp)

usage() {
  sed -n '2,/^set -uo/p' "${BASH_SOURCE[0]}" 2>/dev/null | grep '^#' | sed 's/^# \{0,1\}//' \
    || echo "Usage: setup.sh [--dir DIR] [--ref REF] [--only LIST] [--skip LIST] [--no-update] [--stop-on-error]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) DIR="$2"; shift 2;;
    --ref) REF="$2"; shift 2;;
    --only) ONLY="$2"; shift 2;;
    --skip) SKIP="$2"; shift 2;;
    --no-update) NO_UPDATE=1; shift;;
    --stop-on-error) STOP_ON_ERROR=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 2;;
  esac
done

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- 1. sanity
[[ "$(id -u)" -ne 0 ]] || die "Run this as your normal Kali user, not root (no sudo in front). It calls sudo itself."
command -v sudo >/dev/null 2>&1 || die "sudo is missing. As root run: apt-get install -y sudo && usermod -aG sudo $USER, then log out and back in."
command -v apt-get >/dev/null 2>&1 || die "apt-get not found. This script targets Kali Linux (Debian based)."

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ "${ID:-}" == "kali" ]] || warn "Detected ${PRETTY_NAME:-unknown}. Tested on Kali Rolling; some packages may be missing."
fi

STATE_DIR="$HOME/.local/state/ctf-ai"
mkdir -p "$STATE_DIR" "$HOME/.local/bin" "$HOME/tools" "$HOME/ctf"
LOG_FILE="$STATE_DIR/setup-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

cat <<EOF
AI CTF Workstation setup
========================
Repo:   $REPO_URL ($REF)
Clone:  $DIR
Log:    $LOG_FILE
For authorized CTFs and labs only. No credentials are copied.
EOF

log "Asking for your sudo password once (kept alive while setup runs)"
sudo -v || die "sudo authentication failed"
( while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE=$!
trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT

# ---------------------------------------------------------------- 2. apt base
repair_apt() {
  warn "apt-get update failed; repairing Kali APT sources and metadata"
  sudo mkdir -p /etc/apt/sources.list.d
  if [[ "${ID:-}" == "kali" && -f /usr/share/keyrings/kali-archive-keyring.gpg ]]; then
    sudo tee /etc/apt/sources.list.d/kali.sources >/dev/null <<'EOF_KALI'
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
  fi
  sudo apt-get clean
  sudo rm -rf /var/lib/apt/lists/*
  sudo mkdir -p /var/lib/apt/lists/partial
  sudo apt-get update
}

log "Preparing APT"
sudo dpkg --configure -a || true
if ! sudo apt-get update; then repair_apt || die "APT is still broken. Check your network/mirror, then re-run this script."; fi
sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -y || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git curl wget ca-certificates zsh \
  || die "Could not install git/curl/zsh"
ok "Base tools ready"

# ---------------------------------------------------------------- 3. repo
log "Syncing the workstation repo into $DIR"
mkdir -p "$(dirname "$DIR")"
if [[ -d "$DIR/.git" ]]; then
  if [[ "$NO_UPDATE" -eq 1 ]]; then
    ok "Using existing clone as is (--no-update)"
  else
    if [[ -n "$(git -C "$DIR" status --porcelain 2>/dev/null)" ]]; then
      stash="$STATE_DIR/local-changes-$(date +%Y%m%d-%H%M%S).patch"
      git -C "$DIR" diff > "$stash" || true
      warn "Local edits in $DIR were saved to $stash and will be overwritten"
    fi
    git -C "$DIR" fetch --depth 1 origin "$REF" || die "git fetch failed"
    git -C "$DIR" checkout -q -B "$REF" FETCH_HEAD || git -C "$DIR" reset -q --hard FETCH_HEAD
    git -C "$DIR" reset -q --hard FETCH_HEAD
    git -C "$DIR" clean -fdq
  fi
elif [[ -e "$DIR" ]]; then
  die "$DIR exists but is not a git clone. Move it away or pass --dir somewhere else."
else
  git clone --depth 1 --branch "$REF" "$REPO_URL" "$DIR" || die "git clone failed"
fi
chmod +x "$DIR"/scripts/*.sh "$DIR"/scripts/install/*.sh "$DIR"/scripts/bin/* 2>/dev/null || true
ok "Repo at $(git -C "$DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"

# ---------------------------------------------------------------- 4. phases
in_list() { # in_list "20-ai-clis" "20,80"
  local phase="$1" list="$2" item
  IFS=', ' read -r -a items <<<"$list"
  for item in "${items[@]}"; do
    [[ -n "$item" ]] || continue
    [[ "$phase" == "$item" || "$phase" == "$item"-* ]] && return 0
  done
  return 1
}

declare -a DONE=() FAILED=() SKIPPED=()
for phase in "${PHASES[@]}"; do
  script="$DIR/scripts/install/$phase.sh"
  if [[ -n "$ONLY" ]] && ! in_list "$phase" "$ONLY"; then SKIPPED+=("$phase"); continue; fi
  if [[ -n "$SKIP" ]] && in_list "$phase" "$SKIP"; then SKIPPED+=("$phase"); continue; fi
  if [[ ! -f "$script" ]]; then warn "Missing $script"; FAILED+=("$phase"); continue; fi
  log "Phase $phase"
  start=$SECONDS
  if bash "$script"; then
    DONE+=("$phase"); ok "$phase finished in $((SECONDS - start))s"
  else
    FAILED+=("$phase"); warn "$phase FAILED (exit $?). Continuing with the rest."
    [[ "$STOP_ON_ERROR" -eq 1 ]] && die "Stopping because of --stop-on-error. Log: $LOG_FILE"
  fi
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"; hash -r
done

# ---------------------------------------------------------------- 5. shell
log "Wiring shell config (PATH, cx/ag/cl aliases, mcp-* profiles)"
if [[ ! -f "$HOME/.config/ctf-ai/shell.zsh" ]]; then
  mkdir -p "$HOME/.config/ctf-ai"; cp "$DIR/config/shell.zsh" "$HOME/.config/ctf-ai/shell.zsh"
fi
source_line='[[ -f "$HOME/.config/ctf-ai/shell.zsh" ]] && source "$HOME/.config/ctf-ai/shell.zsh"'
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  touch "$rc"
  grep -Fqx "$source_line" "$rc" || printf '\n# AI CTF Workstation\n%s\n' "$source_line" >> "$rc"
done
ok "Shell config hooked into ~/.zshrc and ~/.bashrc"

# ---------------------------------------------------------------- 6. verify
log "Checking installed commands"
check() { if command -v "$1" >/dev/null 2>&1; then ok "$1"; else warn "$1 not found"; MISSING+=("$1"); fi; }
declare -a MISSING=()
for c in codex agy claude uv ctfhub ctfstudio ctftriage ctfflag ctfsolve ctfmodel ctfnew ctf-mcp ctfdoctor ghidra-ai pwndbg gdb checksec docker; do check "$c"; done
if command -v ctfflag >/dev/null 2>&1; then
  ctfflag decode "ZmxhZ3tzZXR1cH0=" 2>/dev/null | grep -q "flag{setup}" && ok "ctfflag self-test" || warn "ctfflag self-test failed"
fi
if command -v ctfdoctor >/dev/null 2>&1; then
  log "Running ctfdoctor"
  ctfdoctor || warn "ctfdoctor reported problems (see above)"
fi

echo
echo "================================================================"
echo " Setup summary"
echo "================================================================"
echo " Done:    ${DONE[*]:-none}"
[[ ${#SKIPPED[@]} -gt 0 ]] && echo " Skipped: ${SKIPPED[*]}"
if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo " FAILED:  ${FAILED[*]}"
  echo
  echo " Re-run only the failed phases with:"
  failed_ids="$(IFS=,; echo "${FAILED[*]%%-*}")"
  if [[ -f "$DIR/setup.sh" ]]; then
    echo "   bash $DIR/setup.sh --no-update --only $failed_ids"
  else
    echo "   bash <(curl -fsSL https://raw.githubusercontent.com/HashimZuraiqi/ai-ctf-workstation/main/setup.sh) --ref $REF --no-update --only $failed_ids"
  fi
fi
[[ ${#MISSING[@]} -gt 0 ]] && echo " Missing commands: ${MISSING[*]}"
echo " Full log: $LOG_FILE"
cat <<'EOF'

Next steps
  1. Reload your shell:      exec zsh      (log out/in once for Docker group)
  2. Sign in to your own AI accounts:
       codex login           # OpenAI Codex  (alias: cx)
       agy                   # Google Antigravity, sign in inside the TUI (alias: ag)
       claude                # Claude Code, optional (alias: cl)
  3. Optional open-source model for the autosolver:
       ctfmodel use openrouter --key YOUR_KEY
  4. Start working:
       ctfhub                # terminal control panel
       ctfstudio             # desktop GUI (also in the app menu as "CTF Studio")
       ctfnew demo misc && cd ~/ctf/demo && ctftriage
EOF

[[ ${#FAILED[@]} -eq 0 ]]
