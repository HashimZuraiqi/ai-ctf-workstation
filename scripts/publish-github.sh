#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo="${1:-}"
visibility="${2:-private}"
[[ -n "$repo" ]] || { echo "Usage: ./scripts/publish-github.sh <owner/repo> [private|public]" >&2; exit 2; }
[[ "$repo" == */* ]] || { echo "Repository must be owner/repo" >&2; exit 2; }
[[ "$visibility" == private || "$visibility" == public ]] || { echo "Visibility must be private or public" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 1; }
command -v gh >/dev/null 2>&1 || {
  echo "GitHub CLI (gh) is not installed. On Kali: sudo apt install gh" >&2
  echo "Then run: gh auth login" >&2
  exit 1
}
gh auth status >/dev/null 2>&1 || { echo "Authenticate first with: gh auth login" >&2; exit 1; }
cd "$ROOT"
if [[ ! -d .git ]]; then git init -b main; fi
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  git add .
  git commit -m "Initial AI CTF workstation"
fi
if git remote get-url origin >/dev/null 2>&1; then
  echo "origin already exists: $(git remote get-url origin)"
  echo "Pushing current branch..."
  git push -u origin HEAD
else
  gh repo create "$repo" "--$visibility" --source=. --remote=origin --push
fi
echo "Published: $repo"
