#!/bin/bash
# pr-info-helper.sh
# Usage: pr-info-helper.sh <commit_sha> <repo>
# Outputs: pr_number, pr_labels (space-separated)

set -euo pipefail

COMMIT_SHA="$1"
REPO="$2"

# PR番号取得
PR_NUMBER=""
COMMIT_MSG=$(git log -1 --pretty=format:%B)
PR_NUMBER=$(echo "$COMMIT_MSG" | grep -o 'Merge pull request #[0-9]\+' | grep -o '[0-9]\+' | head -1)

if [ -z "$PR_NUMBER" ]; then
  # GitHub APIで取得
  PR_NUMBER=$(gh api "repos/$REPO/commits/$COMMIT_SHA/pulls" --jq '.[0].number' 2>/dev/null || echo "")
fi

echo "pr_number=$PR_NUMBER"

# PRラベル取得
LABELS=""
if [ -n "$PR_NUMBER" ]; then
  LABELS=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json labels --jq '.labels[].name' 2>/dev/null | tr '\n' ' ')
fi

echo "pr_labels=$LABELS"
