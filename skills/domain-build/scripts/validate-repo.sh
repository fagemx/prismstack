#!/usr/bin/env bash
# Validate a domain gstack repo meets minimum acceptance criteria
set -euo pipefail

REPO_DIR="${1:-.}"
PASS=0
FAIL=0

echo "Validating domain gstack repo: $REPO_DIR"
echo "========================================="

# 1. Routing skill exists
if [ -f "$REPO_DIR/skills/routing/SKILL.md" ]; then
  echo "✅ 1. Routing skill exists"
  ((PASS++))
else
  echo "❌ 1. Routing skill missing"
  ((FAIL++))
fi

# 2. Enough skills for first slice (3+)
SKILL_COUNT=$(find "$REPO_DIR/skills" -name "SKILL.md" -not -path "*/shared/*" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -ge 3 ]; then
  echo "✅ 2. First slice possible ($SKILL_COUNT skills)"
  ((PASS++))
else
  echo "❌ 2. Not enough skills ($SKILL_COUNT, need 3+)"
  ((FAIL++))
fi

# 3. Artifact discovery/save patterns present
if grep -rl "gstack/projects" "$REPO_DIR/skills/" >/dev/null 2>&1; then
  echo "✅ 3. Artifact patterns found"
  ((PASS++))
else
  echo "❌ 3. No artifact patterns"
  ((FAIL++))
fi

# 4. install.sh exists and is executable
if [ -x "$REPO_DIR/bin/install.sh" ]; then
  echo "✅ 4. install.sh executable"
  ((PASS++))
else
  echo "❌ 4. install.sh missing or not executable"
  ((FAIL++))
fi

# 5. Interactive skills (3+ with AskUserQuestion)
AQ_COUNT=$(grep -rl "AskUserQuestion" "$REPO_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$AQ_COUNT" -ge 3 ]; then
  echo "✅ 5. Interactive skills ($AQ_COUNT with AskUserQuestion)"
  ((PASS++))
else
  echo "❌ 5. Not enough interactive skills ($AQ_COUNT, need 3+)"
  ((FAIL++))
fi

echo ""
echo "Result: $PASS/5 passed, $FAIL/5 failed"
[ "$FAIL" -eq 0 ] && echo "✅ All criteria met." && exit 0
echo "❌ Criteria NOT met." && exit 1
