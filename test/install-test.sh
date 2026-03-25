#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_TARGET=$(mktemp -d)

echo "Testing Prismstack install to $TEMP_TARGET..."

TARGET="$TEMP_TARGET" bash "$REPO_DIR/bin/install.sh"

EXPECTED_SKILLS=("prism-routing" "domain-plan" "domain-build")
for skill in "${EXPECTED_SKILLS[@]}"; do
  if [ ! -f "$TEMP_TARGET/$skill/SKILL.md" ]; then
    echo "FAIL: $skill/SKILL.md not found"
    rm -rf "$TEMP_TARGET"
    exit 1
  fi
  echo "  ✓ $skill/SKILL.md exists"
done

for shared_file in completion-protocol.md ask-format.md artifact-conventions.md anti-sycophancy.md stop-gates.md; do
  if [ ! -f "$TEMP_TARGET/shared/$shared_file" ]; then
    echo "FAIL: shared/$shared_file not found"
    rm -rf "$TEMP_TARGET"
    exit 1
  fi
done
echo "  ✓ shared resources exist (5 files)"

if grep -r '{{[A-Z_]*}}' "$TEMP_TARGET" 2>/dev/null; then
  echo "FAIL: unresolved placeholders found"
  rm -rf "$TEMP_TARGET"
  exit 1
fi
echo "  ✓ no unresolved placeholders"

rm -rf "$TEMP_TARGET"
echo ""
echo "All install tests passed."
