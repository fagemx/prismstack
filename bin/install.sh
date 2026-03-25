#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TARGET="${TARGET:-${HOME}/.claude/skills/prismstack}"

echo "Installing Prismstack to ${TARGET}..."

mkdir -p "$TARGET"

for skill_dir in "$REPO_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  [ "$skill_name" = "shared" ] && continue

  dest="$TARGET/$skill_name"
  mkdir -p "$dest"

  [ -f "$skill_dir/SKILL.md" ] && cp "$skill_dir/SKILL.md" "$dest/"
  [ -d "$skill_dir/references" ] && cp -r "$skill_dir/references" "$dest/"
  [ -d "$skill_dir/scripts" ] && cp -r "$skill_dir/scripts" "$dest/"

  echo "  ✓ $skill_name"
done

mkdir -p "$TARGET/shared"
cp -r "$REPO_DIR/skills/shared/"* "$TARGET/shared/" 2>/dev/null || true
echo "  ✓ shared resources"

echo ""
echo "Prismstack installed successfully."
echo "Skills available: $(ls -d "$TARGET"/*/ 2>/dev/null | wc -l | tr -d ' ')"
