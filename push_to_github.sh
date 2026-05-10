#!/bin/bash
# ─────────────────────────────────────────────────────────────
# push_to_github.sh
# Pushes the Flutter Debloater project to your GitHub repo.
# Run this from inside the flutter_debloater/ folder.
# ─────────────────────────────────────────────────────────────

set -e

REPO="https://github.com/clever2755-deb/RnzeDebloatera.git"

echo ""
echo "Enter your GitHub Personal Access Token (input hidden):"
read -s PAT
echo ""

if [ -z "$PAT" ]; then
  echo "ERROR: No token entered. Aborting."
  exit 1
fi

REPO_WITH_AUTH="https://${PAT}@github.com/clever2755-deb/RnzeDebloatera.git"

# Init git if not already a repo
if [ ! -d ".git" ]; then
  git init
  echo "Initialized git repository"
fi

git config user.email "you@example.com"
git config user.name "Debloater Push"

# Set or update remote
if git remote get-url origin 2>/dev/null; then
  git remote set-url origin "$REPO_WITH_AUTH"
else
  git remote add origin "$REPO_WITH_AUTH"
fi

git add -A
git commit -m "feat: initial Flutter Debloater project with Shizuku integration" 2>/dev/null || echo "(nothing new to commit)"

git push origin HEAD:main --force

echo ""
echo "SUCCESS — pushed to $REPO"
echo "View your repo at: https://github.com/clever2755-deb/RnzeDebloatera"
