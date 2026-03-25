#!/usr/bin/env bash
# Output the repo slug (basename of git remote or directory)
set -euo pipefail
remote=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$remote" ]; then
  basename "${remote%.git}"
else
  basename "$(pwd)"
fi
