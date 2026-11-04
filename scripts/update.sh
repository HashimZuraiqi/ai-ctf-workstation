#!/usr/bin/env bash
# One-command updater for the AI CTF Workstation.
#
# Paste this on Kali to pull the latest workstation and (re)install the agent
# helpers, skills, playbooks and custom MCP servers. Safe to re-run anytime.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/HashimZuraiqi/ai-ctf-workstation/main/scripts/update.sh)
#
# Flags:
#   --full     run the complete bootstrap (installs/updates the whole toolchain)
#   --dir DIR  use DIR as the local clone (default: ~/tools/ai-ctf-workstation)
#   --ref REF  checkout a branch/tag (default: main)
set -euo pipefail

REPO="https://github.com/HashimZuraiqi/ai-ctf-workstation.git"
DIR="$HOME/tools/ai-ctf-workstation"
REF="main"
FULL=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --full) FULL=1; shift;;
    --dir) DIR="$2"; shift 2;;
    --ref) REF="$2"; shift 2;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) echo "unknown option: $1" >&2; exit 2;;
  esac
done

c_ok(){ printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
c_log(){ printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
c_warn(){ printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }

[[ "${EUID:-$(id -u)}" -ne 0 ]] || { echo "Run as your normal Kali user, not root." >&2; exit 1; }
command -v git >/dev/null || { echo "git is required. Install it: sudo apt-get install -y git" >&2; exit 1; }

c_log "Syncing workstation into $DIR (ref: $REF)"
mkdir -p "$(dirname "$DIR")"
if [[ -d "$DIR/.git" ]]; then
  # Fetch the ref and hard-reset to it. Works even on a single-branch clone made
  # for a different ref (FETCH_HEAD is what we just fetched), so switching --ref
  # or moving to main always lands on the right commit.
  git -C "$DIR" fetch --depth 1 origin "$REF"
  git -C "$DIR" reset -q --hard FETCH_HEAD
else
  git clone --depth 1 --branch "$REF" "$REPO" "$DIR" 2>/dev/null || git clone --depth 1 "$REPO" "$DIR"
fi
c_ok "Repository up to date ($(git -C "$DIR" rev-parse --short HEAD))"

if [[ "$FULL" -eq 1 ]]; then
  c_log "Running the full bootstrap (this can take a while)"
  bash "$DIR/scripts/bootstrap.sh"
else
  # Fast path: just refresh the agent brain (helpers, skills, template, MCP sources).
  c_log "Updating agent helpers, skills, playbooks and challenge template"
  bash "$DIR/scripts/install/70-skills.sh"  || c_warn "skills step reported issues"
  bash "$DIR/scripts/install/80-helpers.sh" || c_warn "helpers step reported issues"
  if command -v uv >/dev/null 2>&1; then
    bash "$DIR/scripts/install/55-category-mcps.sh" || c_warn "custom MCP update reported issues"
  else
    c_warn "uv not found; skipped custom MCP refresh. Run with --full to install everything."
  fi
fi

hash -r 2>/dev/null || true
c_log "Verifying"
if command -v ctfflag >/dev/null 2>&1; then
  ctfflag decode "ZmxhZ3t1cGRhdGVkfQ==" | grep -q "flag{updated}" && c_ok "ctfflag works" || c_warn "ctfflag self-test failed"
else
  c_warn "ctfflag not on PATH yet. Open a new shell or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
command -v ctftriage >/dev/null 2>&1 && c_ok "ctftriage installed" || c_warn "ctftriage not on PATH yet"
command -v ctfsolve  >/dev/null 2>&1 && c_ok "ctfsolve installed"  || c_warn "ctfsolve not on PATH yet"

cat <<EOF

$(c_ok "Update complete.")
New / updated agent tools:
  ctftriage   - automatic first-pass analysis (writes notes/triage.md)
  ctfflag     - find / decode / verify flags  (ctfflag scan | decode | verify)
  ctfsolve    - any-model plan/act/verify autosolver (set CTFSOLVE_API_BASE + CTFSOLVE_MODEL)
  deeper ctf-* skill playbooks for every category

Next:
  exec zsh            # reload your shell (or: export PATH="\$HOME/.local/bin:\$PATH")
  ctfdoctor           # health check
  ctfnew demo misc && cd ~/ctf/demo && ctftriage

Run with --full once in a while to update the entire toolchain.
EOF
