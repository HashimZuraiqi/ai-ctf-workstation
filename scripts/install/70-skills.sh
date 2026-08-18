#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"
install_skill_tree() {
  local dest_root="$1" skill name
  mkdir -p "$dest_root"
  for skill in "$ROOT"/skills/*/SKILL.md; do
    name="$(basename "$(dirname "$skill")")"
    mkdir -p "$dest_root/$name"
    cp "$skill" "$dest_root/$name/SKILL.md"
  done
}
install_skill_tree "$HOME/.agents/skills"
install_skill_tree "$HOME/.claude/skills"
install_skill_tree "$HOME/.gemini/antigravity-cli/skills"
count=$(find "$ROOT/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l)
ok "Installed $count CTF skills for each supported AI client"
