#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/publish-github.sh GITHUB_OWNER [private|public] [REPOSITORY]

Examples:
  ./scripts/publish-github.sh octocat
  ./scripts/publish-github.sh octocat public motion-shell-wayland

The default visibility is private and the default repository is
motion-shell-wayland. The script never stores a token. It uses an existing
GitHub CLI or SSH authentication setup.
USAGE
}

[[ $# -ge 1 && $# -le 3 ]] || { usage >&2; exit 2; }

owner=$1
visibility=${2:-private}
repository=${3:-motion-shell-wayland}

case "$visibility" in
  private|public) ;;
  *) echo "Visibility must be private or public." >&2; exit 2 ;;
esac

if [[ ! "$owner" =~ ^[A-Za-z0-9-]+$ ]]; then
  echo "GitHub owner contains unsupported characters: $owner" >&2
  exit 2
fi
if [[ ! "$repository" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Repository name contains unsupported characters: $repository" >&2
  exit 2
fi

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo 'Run this script from inside the Motion Shell Git repository.' >&2
  exit 1
}
cd "$root"

if [[ -n $(git status --porcelain) ]]; then
  echo 'The working tree is not clean. Commit or stash changes before publishing.' >&2
  exit 1
fi

branch=$(git branch --show-current)
if [[ "$branch" != main ]]; then
  echo "Expected branch 'main', found '$branch'." >&2
  exit 1
fi

full_name="$owner/$repository"
ssh_url="git@github.com:$full_name.git"
description='A Material 3 Expressive desktop shell for Wayland and Hyprland.'

if command -v gh >/dev/null 2>&1; then
  gh auth status >/dev/null
  if gh repo view "$full_name" >/dev/null 2>&1; then
    if git remote get-url origin >/dev/null 2>&1; then
      git remote set-url origin "$ssh_url"
    else
      git remote add origin "$ssh_url"
    fi
  else
    gh repo create "$full_name" \
      "--$visibility" \
      --source=. \
      --remote=origin \
      --description "$description"
  fi
  git push -u origin main
  printf 'Published Motion Shell to https://github.com/%s\n' "$full_name"
  exit 0
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$ssh_url"
else
  git remote add origin "$ssh_url"
fi

cat <<EOF2
GitHub CLI is not installed, so the remote was prepared but no repository was
created and nothing was pushed.

Create an empty $visibility repository named '$repository' under '$owner', then run:

  git push -u origin main

Prepared remote: $ssh_url
EOF2
