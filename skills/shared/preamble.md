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

# Session lifecycle (cleanup stale >2hr, count active)
find ~/.prismstack/sessions -mmin +120 -type f -exec rm {} + 2>/dev/null || true
_SESSIONS=$(find ~/.prismstack/sessions -mmin -120 -type f 2>/dev/null | wc -l | tr -d ' ')

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

# Timeline: last session on this branch
_LAST_SESSION=""
_RECENT_PATTERN=""
if [ -f "$_STATE_DIR/timeline.jsonl" ]; then
  _LAST_SESSION=$(grep "\"branch\":\"${_BRANCH}\"" "$_STATE_DIR/timeline.jsonl" 2>/dev/null | grep '"event":"completed"' | tail -1)
  _RECENT_PATTERN=$(grep "\"branch\":\"${_BRANCH}\"" "$_STATE_DIR/timeline.jsonl" 2>/dev/null | grep '"event":"completed"' | tail -3 | grep -o '"skill":"[^"]*"' | sed 's/"skill":"//;s/"//' | tr '\n' ',')
fi

# Learnings injection summary
_LEARNINGS_SUMMARY=""
if [ "$_HAS_ACCUMULATED" = "1" ] && [ -f "$_STATE_DIR/domain-config.json" ]; then
  _EXPERT_COUNT=$(grep -c '"type":"expertise"' "$_STATE_DIR/domain-config.json" 2>/dev/null || echo "0")
  _CORRECT_COUNT=$(grep -c '"type":"correction"' "$_STATE_DIR/domain-config.json" 2>/dev/null || echo "0")
  _BENCH_COUNT=$(grep -c '"type":"benchmark"' "$_STATE_DIR/domain-config.json" 2>/dev/null || echo "0")
  _OPER_COUNT=$(grep -c '"type":"operational"' "$_STATE_DIR/domain-config.json" 2>/dev/null || echo "0")
  _LEARNINGS_SUMMARY="expertise=$_EXPERT_COUNT corrections=$_CORRECT_COUNT benchmarks=$_BENCH_COUNT operational=$_OPER_COUNT"
fi

# Spawned session detection
_SPAWNED="false"
if [ -f "$_STATE_DIR/auto-run-state.json" ]; then
  _AUTO_STATE=$(grep -o '"current_state":"[^"]*"' "$_STATE_DIR/auto-run-state.json" 2>/dev/null | head -1)
  [ -n "$_AUTO_STATE" ] && _SPAWNED="true"
fi

# Timeline: record skill start
_SESSION_ID="$$-$(date +%s)"
_TEL_START=$(date +%s)
echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"skill\":\"SKILL_NAME\",\"event\":\"started\",\"branch\":\"$_BRANCH\",\"session\":\"$_SESSION_ID\"}" >> "$_STATE_DIR/timeline.jsonl" 2>/dev/null || true

echo "SLUG: $_SLUG"
echo "BRANCH: $_BRANCH"
echo "PROJECTS_DIR: $_PROJECTS_DIR"
echo "STATE_DIR: $_STATE_DIR"
echo "ACTIVE_SESSIONS: $_SESSIONS"
echo "HAS_SKILL_MAP: $_HAS_SKILL_MAP"
echo "HAS_DOMAIN_CONFIG: $_HAS_DOMAIN_CONFIG"
echo "HAS_CHECK_RESULTS: $_HAS_CHECK_RESULTS"
echo "HAS_ACCUMULATED: $_HAS_ACCUMULATED"
[ -n "$_LEARNINGS_SUMMARY" ] && echo "LEARNINGS: $_LEARNINGS_SUMMARY"
[ -n "$_LAST_SESSION" ] && echo "LAST_SESSION: $_LAST_SESSION"
[ -n "$_RECENT_PATTERN" ] && echo "RECENT_PATTERN: $_RECENT_PATTERN"
echo "SPAWNED: $_SPAWNED"
echo "ARTIFACTS: $_ARTIFACT_COUNT"
[ "$_ARTIFACT_COUNT" -gt 0 ] && ls -t "$_PROJECTS_DIR"/*.md 2>/dev/null | head -5 | while read f; do echo "  $(basename "$f")"; done
```

**Session Awareness:**
- `ACTIVE_SESSIONS >= 3` → 用戶在切視窗。每個 AskUserQuestion 加額外 re-ground。
- `SPAWNED` 是 `"true"` → 自動模式下被 orchestrator 執行。見 `shared/methodology/auto-decision-guide.md` 的 Spawned Session 段落。

**Welcome Back（僅 SPAWNED=false 時）：**
如果 `LAST_SESSION` 存在，印一句 welcome-back：「上次在這個 branch 跑了 /skill-name，結果是 outcome。」
如果 `RECENT_PATTERN` 存在且匹配已知 workflow 路徑，加一句 predictive suggestion：
- domain-plan → 建議 /domain-build
- domain-build → 建議 /skill-check
- skill-check → 建議 /skill-edit 或 /domain-upgrade
- skill-edit,skill-edit,skill-edit → 建議 /skill-check review --all
- 不匹配 → 不建議（不硬猜）

**Learnings Injection：**
如果 `LEARNINGS` 存在（任何計數 > 0），讀 `domain-config.json` 的 `accumulated` section，按優先級注入：
1. `corrections` → 最高優先。列出：「上次用戶修正了：...。避免重複。」
2. `benchmarks` → 注入到 scoring calibration：「用戶提供的基準：...」
3. `expertise` → 用在生成 skill 的維度和權重
4. `operational` → 用在避免走錯路：「上次在這個領域，X 方法不管用」
5. `preferences` → 調整互動風格（STOP 頻率、提問方式）

衰減規則（讀取時判斷，不修改檔案）：
- `user-stated` 和 `correction` → 不衰減
- `operational` 和 `expertise`（非 user-stated）→ 每 30 天 confidence -1（用 `ts` 欄位計算）
- confidence < 3 → 不注入（太舊太不確定）

**Accumulated Context:** If `HAS_ACCUMULATED=1`, read `domain-config.json` 的 `accumulated` section。用這些資訊調整你的行為（見上方 Learnings Injection）。

**Shared artifact directory:** `$_PROJECTS_DIR` (`~/.prismstack/projects/{slug}/`) stores all skill outputs. All skills read from this directory on startup. All skills write their output here.

**State directory:** `$_STATE_DIR` (`~/.prismstack/projects/{slug}/.prismstack/`) stores machine-readable state (domain-config.json, skill-map.json, check-results.json, timeline.jsonl, logs).

**Timeline start event:** Preamble 尾端已自動寫入 `started` 事件到 `$_STATE_DIR/timeline.jsonl`。每個 skill 在使用此 preamble 時，需將 bash block 中的 `SKILL_NAME` 替換為該 skill 的 YAML frontmatter `name:` 欄位值（例：`domain-plan`、`skill-check`）。

## AskUserQuestion 格式（可靠觸發語法）

**STOP gate 必須用此格式寫，否則模型不會呼叫 AskUserQuestion 工具：**

```markdown
**STOP.** AskUserQuestion to confirm [什麼事]:

> [Re-ground + Simplify + RECOMMENDATION + 字母選項]

**One question only. Wait for answer before proceeding.**
```

四段內容：
1. **Re-ground:** 在哪個 skill、哪個 Phase。假設用戶離開了 20 分鐘。
2. **Simplify:** 白話解釋，16 歲的人也能聽懂。
3. **Recommend:** `RECOMMENDATION: Choose X — 理由`
4. **Options:** `A) ... B) ... C) ... D) Skip/先停` — 永遠有逃生門。

詳見 `shared/ask-format.md`。

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
