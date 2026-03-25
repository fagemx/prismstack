#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_TARGET=$(mktemp -d)

PASS=0
FAIL=0
TOTAL=0

check() {
  TOTAL=$((TOTAL + 1))
  if "$@"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
  fi
}

echo "Testing Prismstack install to $TEMP_TARGET..."

TARGET="$TEMP_TARGET" bash "$REPO_DIR/bin/install.sh"

# --- 1. Check all 10 skills ---
EXPECTED_SKILLS=("prism-routing" "domain-plan" "domain-build" "skill-check" "skill-gen" "skill-edit" "source-convert" "tool-builder" "domain-upgrade" "workflow-edit")
for skill in "${EXPECTED_SKILLS[@]}"; do
  check test -f "$TEMP_TARGET/$skill/SKILL.md"
  if [ -f "$TEMP_TARGET/$skill/SKILL.md" ]; then
    echo "  ✓ $skill/SKILL.md exists"
  else
    echo "FAIL: $skill/SKILL.md not found"
  fi
done

# --- 2. Check all 6 shared files ---
EXPECTED_SHARED=("completion-protocol.md" "ask-format.md" "artifact-conventions.md" "anti-sycophancy.md" "stop-gates.md" "state-conventions.md")
ALL_SHARED_OK=true
for shared_file in "${EXPECTED_SHARED[@]}"; do
  check test -f "$TEMP_TARGET/shared/$shared_file"
  if [ ! -f "$TEMP_TARGET/shared/$shared_file" ]; then
    echo "FAIL: shared/$shared_file not found"
    ALL_SHARED_OK=false
  fi
done
if $ALL_SHARED_OK; then
  echo "  ✓ shared resources exist (${#EXPECTED_SHARED[@]} files)"
fi

# --- 3. Check references/ directories for skills that have them ---
SKILLS_WITH_REFS=("domain-plan" "domain-build" "skill-check" "skill-gen" "skill-edit" "source-convert" "tool-builder" "domain-upgrade" "workflow-edit")
ALL_REFS_OK=true
for skill in "${SKILLS_WITH_REFS[@]}"; do
  check test -d "$TEMP_TARGET/$skill/references"
  if [ ! -d "$TEMP_TARGET/$skill/references" ]; then
    echo "FAIL: $skill/references/ not found"
    ALL_REFS_OK=false
  fi
done
if $ALL_REFS_OK; then
  echo "  ✓ references/ directories exist (${#SKILLS_WITH_REFS[@]} skills)"
fi

# --- 4. Check scripts/ for domain-build ---
check test -f "$TEMP_TARGET/domain-build/scripts/validate-repo.sh"
if [ -f "$TEMP_TARGET/domain-build/scripts/validate-repo.sh" ]; then
  echo "  ✓ domain-build/scripts/validate-repo.sh exists"
else
  echo "FAIL: domain-build/scripts/validate-repo.sh not found"
fi

# --- 5. Check YAML frontmatter has required fields ---
ALL_YAML_OK=true
for skill in "${EXPECTED_SKILLS[@]}"; do
  for field in "name:" "version:" "origin:" "description:"; do
    check grep -q "^$field" "$TEMP_TARGET/$skill/SKILL.md" 2>/dev/null
    if ! grep -q "^$field" "$TEMP_TARGET/$skill/SKILL.md" 2>/dev/null; then
      echo "FAIL: $skill/SKILL.md missing $field"
      ALL_YAML_OK=false
    fi
  done
done
if $ALL_YAML_OK; then
  echo "  ✓ all YAML frontmatter valid"
fi

# --- 6. Placeholder check ---
check ! grep -rq '{{[A-Z_]*}}' "$TEMP_TARGET" 2>/dev/null
if grep -r '{{[A-Z_]*}}' "$TEMP_TARGET" 2>/dev/null; then
  echo "FAIL: unresolved placeholders found"
else
  echo "  ✓ no unresolved placeholders"
fi

# --- Cleanup & summary ---
rm -rf "$TEMP_TARGET"
echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL checks"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
echo "All install tests passed."
