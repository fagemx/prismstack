# Prismstack Preamble

> 每個 Prismstack skill 在 YAML frontmatter 之後、skill 內容之前，應包含以下 preamble。

## Preamble (run first)

```bash
# Project identification
_SLUG=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_USER=$(whoami 2>/dev/null || echo "unknown")

# Shared artifact storage (cross-skill, cross-session)
mkdir -p ~/.prismstack/projects/$_SLUG
_PROJECTS_DIR=~/.prismstack/projects/$_SLUG

# Prismstack state directory
mkdir -p "$_PROJECTS_DIR/.prismstack"
_STATE_DIR="$_PROJECTS_DIR/.prismstack"

# Session tracking
mkdir -p ~/.prismstack/sessions
touch ~/.prismstack/sessions/"$PPID"

# Detect project state
_HAS_SKILL_MAP=0
[ -f "$_STATE_DIR/skill-map.json" ] && _HAS_SKILL_MAP=1
_HAS_DOMAIN_CONFIG=0
[ -f "$_STATE_DIR/domain-config.json" ] && _HAS_DOMAIN_CONFIG=1
_HAS_CHECK_RESULTS=0
[ -f "$_STATE_DIR/check-results.json" ] && _HAS_CHECK_RESULTS=1

# Artifact summary
_ARTIFACT_COUNT=$(ls "$_PROJECTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

# Read accumulated context (if exists)
_HAS_ACCUMULATED=0
if [ -f "$_STATE_DIR/domain-config.json" ]; then
  _ACCUMULATED=$(cat "$_STATE_DIR/domain-config.json" | grep -c '"accumulated"' 2>/dev/null || echo "0")
  [ "$_ACCUMULATED" -gt 0 ] && _HAS_ACCUMULATED=1
fi

echo "SLUG: $_SLUG"
echo "BRANCH: $_BRANCH"
echo "PROJECTS_DIR: $_PROJECTS_DIR"
echo "STATE_DIR: $_STATE_DIR"
echo "HAS_SKILL_MAP: $_HAS_SKILL_MAP"
echo "HAS_DOMAIN_CONFIG: $_HAS_DOMAIN_CONFIG"
echo "HAS_CHECK_RESULTS: $_HAS_CHECK_RESULTS"
echo "HAS_ACCUMULATED: $_HAS_ACCUMULATED"
echo "ARTIFACTS: $_ARTIFACT_COUNT"
[ "$_ARTIFACT_COUNT" -gt 0 ] && ls -t "$_PROJECTS_DIR"/*.md 2>/dev/null | head -5 | while read f; do echo "  $(basename "$f")"; done
```

**Accumulated Context:** If `HAS_ACCUMULATED=1`, read `domain-config.json` 的 `accumulated` section。用這些資訊調整你的行為：
- `expertise` → 用在 scoring formula、phase 設計
- `corrections` → 避免重複用戶已修正的錯誤
- `preferences` → 調整互動風格（STOP 頻率、提問方式）
- `benchmarks` → 用在 scoring calibration

**Shared artifact directory:** `$_PROJECTS_DIR` (`~/.prismstack/projects/{slug}/`) stores all skill outputs. All skills read from this directory on startup. All skills write their output here.

**State directory:** `$_STATE_DIR` (`~/.prismstack/projects/{slug}/.prismstack/`) stores machine-readable state (domain-config.json, skill-map.json, check-results.json, logs).

## AskUserQuestion Format

**ALWAYS follow this structure for every AskUserQuestion call:**
1. **Re-ground:** Project, branch, what we're doing. Assume user was away 20 minutes.
2. **Simplify:** 用白話解釋，16 歲的人也能聽懂。
3. **Recommend:** `RECOMMENDATION: Choose [X] because [reason]` — include completeness score per option.
4. **Options:** `A) ... B) ... C) ... D) Skip/Defer` — always include an escape option.

## Completion Status Protocol

DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT.

## Next Step Routing Protocol

After every completion, include `Next Step:` block:
- BLOCKED → do not suggest next skill
- NEEDS_CONTEXT → suggest re-running with missing info
- DONE_WITH_CONCERNS → route to skill that addresses top concern
- DONE → route forward in workflow pipeline

### Workflow Pipeline

```
/domain-plan → /domain-build → /skill-check pack
/skill-check review → /skill-edit (if issues found)
/source-convert → /skill-gen or /skill-edit
/tool-builder → /skill-check review
/domain-upgrade → dispatches to appropriate skill
/workflow-edit → /skill-check pack
```

### Backtrack Rules

- Skill map fundamentally wrong → /domain-plan
- Repo structure broken → /domain-build (re-scaffold)
- Skill quality too low → /skill-edit or /skill-gen (rewrite)
- Workflow disconnected → /workflow-edit
