# System Automation Upgrade — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add cross-session memory (timeline, learnings injection, enhanced preamble) and principled auto-decision making (6 principles, state machine backtrack, spawned session protocol) to Prismstack's 11 builder skills.

**Architecture:** All changes are to Markdown methodology files under `skills/shared/` and `skills/prism-routing/`. No new code, no new binaries — only bash inline blocks and prose instructions. Two new JSONL persistence files (`timeline.jsonl`, `auto-decisions.jsonl`) written by existing preamble/completion hooks.

**Tech Stack:** Markdown, bash (inline in skill files), JSONL

**Spec:** `docs/plans/2026-04-15-system-automation-upgrade.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `skills/shared/preamble.md` | Modify | Session lifecycle, timeline read/write, learnings injection, spawned detection |
| `skills/shared/completion-protocol.md` | Modify | Operational reflection, timeline complete event |
| `skills/shared/methodology/context-accumulation-guide.md` | Modify | Add operational type, confidence, decay |
| `skills/shared/state-conventions.md` | Modify | New state files table entries, expanded schemas |
| `skills/shared/methodology/auto-decision-guide.md` | Create | 6 principles, 3 classifications, audit trail, spawned session rules |
| `skills/shared/methodology/fix-loop-guide.md` | Modify | ESCALATE backtrack targets |
| `skills/prism-routing/SKILL.md` | Modify | Auto Mode state machine, simplified dispatch prompts |

---

## Wave 1: Cross-Session Memory

### Task 1: Upgrade preamble.md — session lifecycle + timeline read + learnings injection

**Files:**
- Modify: `skills/shared/preamble.md`

This is the largest single change. The preamble grows from ~53 lines to ~90 lines of bash + updated prose instructions.

- [ ] **Step 1: Add session lifecycle block after existing state detection**

Open `skills/shared/preamble.md`. After the existing block that ends with `echo "ARTIFACTS: $_ARTIFACT_COUNT"` (line 52 area), insert the session lifecycle, timeline read, and learnings injection blocks. Replace the entire bash block (lines 7-52) with:

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

- [ ] **Step 2: Update prose instructions after bash block**

Replace the existing "Accumulated Context" and "Shared artifact directory" sections (everything after the bash block closing ``` up to the `## AskUserQuestion` header) with:

```markdown
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
```

- [ ] **Step 3: Verify AskUserQuestion format and Completion/Next Step sections are unchanged**

Read the file. Confirm the `## AskUserQuestion 格式` section and everything below it is untouched.

- [ ] **Step 4: Commit**

```bash
git add skills/shared/preamble.md
git commit -m "feat: upgrade preamble — session lifecycle, timeline, learnings injection, spawned detection"
```

---

### Task 2: Upgrade completion-protocol.md — operational reflection + timeline complete event

**Files:**
- Modify: `skills/shared/completion-protocol.md`

- [ ] **Step 1: Add Operational Reflection section**

Open `skills/shared/completion-protocol.md`. Before the existing `## Completion 萃取步驟` section (line 5), insert a new section:

```markdown
## Operational Reflection（在萃取之前執行）

完成任務後、進入萃取之前，回答這些問題：
- 有指令或方法失敗嗎？（例：生成的 skill 驗收沒過、scoring formula 不合理）
- 有走錯路又回頭嗎？（例：先 merge 再 split，浪費了時間）
- 發現什麼 domain-specific 怪癖？（例：這個領域的 review 不能用數字評分）

如果有 → 寫入 `domain-config.json` 的 `accumulated` section：
```json
{
  "type": "operational",
  "content": "描述發現的問題和走錯的路",
  "confidence": 7,
  "source": "observed",
  "ts": "2026-04-15T10:00:00Z"
}
```

如果沒有 → 跳過（大部分 session 不會有）。然後進入下方的萃取步驟。
```

- [ ] **Step 2: Add timeline complete event at the end of the file**

Append to the end of `skills/shared/completion-protocol.md`:

```markdown
## Timeline Complete Event（在 STATUS 報告之後執行）

報告 STATUS 後，寫入 timeline complete 事件：

```bash
_TEL_END=$(date +%s)
_TEL_DUR=$(( _TEL_END - _TEL_START ))
echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"skill\":\"SKILL_NAME\",\"event\":\"completed\",\"branch\":\"$_BRANCH\",\"outcome\":\"OUTCOME\",\"duration_s\":\"$_TEL_DUR\",\"session\":\"$_SESSION_ID\"}" >> "$_STATE_DIR/timeline.jsonl" 2>/dev/null || true
```

- `SKILL_NAME`：從當前 skill 的 YAML frontmatter `name:` 欄位讀取（例：`domain-plan`、`skill-check`）
- `OUTCOME`：從 STATUS 映射 — DONE → `done`、DONE_WITH_CONCERNS → `done_with_concerns`、BLOCKED → `blocked`、NEEDS_CONTEXT → `needs_context`
- `_TEL_START`、`_SESSION_ID`、`$_STATE_DIR`、`$_BRANCH`：來自 preamble 的變數

如果 skill 異常退出（沒有正式 completion），不寫 complete event。下次 preamble 偵測到有 started 但沒有 completed 的 session → 推斷上次中斷。
```

- [ ] **Step 3: Commit**

```bash
git add skills/shared/completion-protocol.md
git commit -m "feat: add operational reflection + timeline complete event to completion protocol"
```

---

### Task 3: Upgrade context-accumulation-guide.md — operational type + confidence + decay

**Files:**
- Modify: `skills/shared/methodology/context-accumulation-guide.md`

- [ ] **Step 1: Add operational signal type to the guide**

Open `skills/shared/methodology/context-accumulation-guide.md`. In the `## 原則` section (line 6), replace principle 3:

```markdown
3. **只記 4 種信號** — expertise / correction / preference / benchmark。其他不記。
```

with:

```markdown
3. **只記 5 種信號** — expertise / correction / preference / benchmark / operational。其他不記。
```

- [ ] **Step 2: Add operational to the 萃取流程**

After the existing flow diagram (line 22 area), before `## 寫入規則`, insert:

```markdown
### 第 5 種信號：operational

| 信號 | 偵測規則 | 記錄為 |
|------|---------|--------|
| **operational** | 這次 session 有方法失敗、有走錯路、有發現 domain-specific 怪癖 | `"type": "operational"` |

Operational 信號由 Completion Protocol 的 Operational Reflection 步驟產生，不在萃取流程中重複偵測。
```

- [ ] **Step 3: Add confidence + decay section**

Before `## Phase 0 讀取規則` (line 38 area), insert:

```markdown
## Confidence + Decay

每筆 accumulated entry 包含 `confidence`（1-10）和 `source` 欄位：

```json
{
  "type": "expertise",
  "content": "廣告素材的 CTA 必須在 mobile 上 48px 以上",
  "confidence": 8,
  "source": "user-stated",
  "ts": "2026-04-15T10:00:00Z"
}
```

### 初始 confidence
- `user-stated`（用戶明確說的）→ 9
- `correction`（用戶修正的）→ 9
- `observed`（AI 自己觀察到的）→ 7
- `inferred`（AI 推斷的）→ 5

### 衰減規則（Preamble 讀取時判斷，不修改檔案）
- `user-stated` 和 `correction` → **不衰減**（用戶明確說的永遠有效）
- `operational` 和 `expertise`（source 不是 `user-stated`）→ 每 30 天 confidence -1（用 `ts` 欄位和當前日期計算）
- confidence < 3 → **不注入**（太舊太不確定，但保留在檔案中不刪除）
```

- [ ] **Step 4: Update Phase 0 讀取規則**

Replace the existing `## Phase 0 讀取規則` section with:

```markdown
## Phase 0 讀取規則

每個 skill 啟動時 preamble 讀 domain-config.json，按優先級注入（詳見 preamble.md 的 Learnings Injection 段落）：
- 如果有 `accumulated.corrections` → 最高優先。列出避免重複。
- 如果有 `accumulated.benchmarks` → 注入到 scoring calibration
- 如果有 `accumulated.expertise` → 用在生成 skill 的維度和權重
- 如果有 `accumulated.operational` → 用在避免走錯路
- 如果有 `accumulated.preferences` → 調整互動風格

**衰減過濾：** 注入前計算每筆 entry 的 effective confidence（初始 confidence - 衰減）。effective confidence < 3 的不注入。

**不讀 decision-log.jsonl**（除非用戶明確要看歷史）。
```

- [ ] **Step 5: Commit**

```bash
git add skills/shared/methodology/context-accumulation-guide.md
git commit -m "feat: add operational signal type, confidence scoring, and decay rules"
```

---

### Task 4: Update state-conventions.md — new state files for Wave 1

**Files:**
- Modify: `skills/shared/state-conventions.md`

- [ ] **Step 1: Add timeline.jsonl to state files table**

Open `skills/shared/state-conventions.md`. In the `## State Files` table (line 8 area), add after the `workflow-snapshot.md` row:

```markdown
| `timeline.jsonl` | Preamble (start) + Completion (complete) | Preamble (recovery, prediction) | Skill 使用歷史（append-only） |
```

- [ ] **Step 2: Add timeline.jsonl schema**

After the `## domain-config.json Schema` section, before `## Context Accumulation`, insert:

```markdown
## timeline.jsonl Schema

每行一筆 JSON，append-only：
```json
{"ts":"2026-04-15T10:00:00Z","skill":"domain-plan","event":"started","branch":"main","session":"12345-1713168000"}
{"ts":"2026-04-15T10:32:00Z","skill":"domain-plan","event":"completed","branch":"main","outcome":"done","duration_s":"1920","session":"12345-1713168000"}
```

| 欄位 | 說明 | 存在 |
|------|------|------|
| `ts` | UTC timestamp | 全部 |
| `skill` | Skill 名稱（從 YAML frontmatter `name:` 讀取） | 全部 |
| `event` | `started` / `completed` | 全部 |
| `branch` | Git branch | 全部 |
| `outcome` | `done` / `done_with_concerns` / `blocked` / `needs_context` | 僅 completed |
| `duration_s` | 從 start 到 complete 的秒數 | 僅 completed |
| `session` | `$$-$(date +%s)` — 辨識同一個 session | 全部 |
```

- [ ] **Step 3: Add confidence + source fields to domain-config.json accumulated schema**

In the `### domain-config.json 擴展 Schema` section, replace the `accumulated` example entries to include `confidence`, `source`, and `ts`:

```json
  "accumulated": {
    "expertise": [
      {"content": "審素材看構圖、品牌一致、CTA", "extracted_as": "scoring 3 dimensions", "confidence": 9, "source": "user-stated", "ts": "2026-03-25T14:00:00Z"}
    ],
    "corrections": [
      {"content": "gotcha 不對，要查字型大小", "skill": "/ad-check", "section": "gotchas", "confidence": 9, "source": "correction", "ts": "2026-03-25T15:00:00Z"}
    ],
    "preferences": [
      {"content": "STOP gates 太多", "applied_to": "simple Review skills", "confidence": 9, "source": "user-stated", "ts": "2026-03-25T16:00:00Z"}
    ],
    "benchmarks": [
      {"content": "CPM 超過 280 要警告", "skill": "/performance-review", "confidence": 9, "source": "user-stated", "ts": "2026-03-25T17:00:00Z"}
    ],
    "operational": [
      {"content": "這個領域的 review 不能用數字評分，用戶偏好 pass/fail", "confidence": 7, "source": "observed", "ts": "2026-03-26T10:00:00Z"}
    ]
  }
```

- [ ] **Step 4: Commit**

```bash
git add skills/shared/state-conventions.md
git commit -m "feat: add timeline.jsonl schema and confidence fields to state conventions"
```

---

### Task 5: Run install test to validate Wave 1

**Files:**
- None (validation only)

- [ ] **Step 1: Run install test**

```bash
bash test/install-test.sh
```

Expected: All tests pass. If any fail due to the new content (e.g., line count checks), investigate and fix.

- [ ] **Step 2: Verify preamble bash syntax**

```bash
bash -n -c '
_SLUG=test
_BRANCH=main
_STATE_DIR=/tmp/test
_HAS_ACCUMULATED=0
# paste the full preamble bash block and verify no syntax errors
'
```

Expected: No output (no syntax errors).

---

## Wave 2: Auto Decision Making

### Task 6: Create auto-decision-guide.md

**Files:**
- Create: `skills/shared/methodology/auto-decision-guide.md`

- [ ] **Step 1: Write the complete auto-decision-guide.md**

Create `skills/shared/methodology/auto-decision-guide.md` with this content:

```markdown
# 自動決策指南

> 用途：Auto Mode 下所有 skill 的決策依據。
> 語境：你正在自動模式下執行，STOP gates 不問用戶，由此指南的原則代替用戶判斷。

---

## 6 條 Decision Principles

| # | 原則 | 說明 | 適用場景 |
|---|------|------|---------|
| P1 | **保留用戶意圖** | 用戶說過的維度、權重、角色定義，永遠優先於 AI 推導的。讀 domain-config.json 的 accumulated context。 | scoring formula、role identity、gotchas |
| P2 | **覆蓋優先** | 選覆蓋更多生命週期階段的方案。缺口比冗餘更危險。 | skill map 規劃、缺口填補 |
| P3 | **獨立性** | 如果兩個選項都可以，選讓 skill 更獨立的。依賴越少越好。 | skill merge/split 決策 |
| P4 | **品質對等** | 輸入多少，產出多少。一句話不假裝 Production，完整 spec 不降級 Draft。 | skill 生成深度 |
| P5 | **最小改動** | 修 skill 時只改有問題的部分。不重寫、不重構、不加新功能。 | fix loop、skill-edit |
| P6 | **向前推進** | 有疑問但不阻塞時，選較安全的預設值繼續。不停在非關鍵問題上。 | 自動模式全程 |

### 衝突解決（per phase）

- **Plan 階段：** P2（覆蓋）+ P3（獨立性）主導
- **Build 階段：** P4（品質對等）+ P1（用戶意圖）主導
- **Check 階段：** 無自動決策（評判者只看 rubric，不受原則影響）
- **Fix 階段：** P5（最小改動）+ P1（用戶意圖）主導

---

## Decision Classification

每個 STOP gate 遇到的決策分三類：

### Mechanical — 有明確正確答案

靜默自動決策，記入 audit log。不呈現給用戶。

範例：
- YAML 缺 `origin:` → 加上 `origin: prismstack-generated`
- 沒有 completion protocol → 加 STATUS: DONE section
- 沒有 artifact discovery → 加 Phase 0 discovery bash block
- description 缺 anti-trigger → 加 "Do NOT use when:"
- SKILL.md > 250 行但沒有 references/ → 把長 section 拆到 references/
- 沒有 STOP gates → 在每個 phase 結尾加 STOP

### Taste — 合理的人可能有不同選擇

自動決策（用 6 原則選較好的），但標記 `"surfaced": true`，存入最終審批門讓用戶確認。

三種自然來源：
1. **Close approaches** — 前兩名都可行，各有不同 tradeoff
2. **Borderline scope** — 獨立性測試剛好 2/3，合併或保持獨立都說得通
3. **Weight ambiguity** — scoring formula 的權重分配，用戶沒明確說過

範例：
- 兩個 skill 該 merge 還是保持獨立（獨立性測試 2/3）
- scoring formula 的權重分配（用戶沒說過偏好）
- 某個生命週期階段要不要拆成兩個 skill

### User Required — 涉及用戶的領域知識

**永不自動決策**，即使在 auto mode 也不行。處理方式：

1. 讀 `domain-config.json` accumulated context → 用 P1（保留用戶意圖）
2. 如果有相關 context → 用那個值作為預設，標記 `"deferred": true`
3. 如果沒有 context → 用最保守的預設值（不改變用戶同意過的東西），標記 `"deferred": true`
4. 最終審批門列出所有 deferred decisions 讓用戶確認

範例：
- 用戶說「CTA 最重要」但 AI 推導出品牌一致性權重更高 → 必須問
- 增減 skill（改變用戶同意過的 skill map）
- 改變角色定義

---

## Audit Trail

每個自動決策記入 `$_STATE_DIR/auto-decisions.jsonl`（append-only）：

```json
{"ts":"2026-04-15T10:05:00Z","phase":"build","skill":"ad-check","type":"mechanical","decision":"added completion protocol","principle":"P6"}
{"ts":"2026-04-15T10:12:00Z","phase":"plan","skill":"market-research","type":"taste","decision":"kept independent (2/3 tests passed)","principle":"P3","surfaced":true}
{"ts":"2026-04-15T10:20:00Z","phase":"build","skill":"brand-voice","type":"user_required","decision":"kept user weight: CTA 30%","principle":"P1","deferred":true}
```

| 欄位 | 說明 |
|------|------|
| `ts` | UTC timestamp |
| `phase` | `plan` / `build` / `fix` |
| `skill` | 受影響的 skill 名稱 |
| `type` | `mechanical` / `taste` / `user_required` |
| `decision` | 一句話描述做了什麼決定 |
| `principle` | 用了哪條原則（P1-P6） |
| `surfaced` | 僅 taste：是否呈現到最終審批門 |
| `deferred` | 僅 user_required：是否延遲到最終審批門 |

---

## 最終審批門

Auto mode 結束前（交付階段），列出所有 `"surfaced": true` 和 `"deferred": true` 的決策：

```
自動搭建完成前，以下決策需要你確認：

Taste Decisions（自動選了，但你可能有不同看法）：
1. /market-research — 保持獨立（獨立性測試 2/3）。理由：P3 獨立性。
   → A) 同意  B) 改成合併到 /campaign-strategy

User Required（用了預設值，需要你確認）：
1. /brand-voice — 保持用戶權重 CTA 30%。理由：P1 保留用戶意圖。
   → A) 確認  B) 改成 ...

A) 全部確認  B) 逐個修改  C) 全部接受，之後再調
```

---

## Spawned Session 行為規則

如果 preamble 偵測到 `SPAWNED` 是 `"true"`，你正在自動模式下被 orchestrator 執行。調整行為：

### 1. STOP gates
不呼叫 AskUserQuestion。用上方的 6 原則 + 3 分類自動決策：
- Mechanical → 靜默決策
- Taste → 自動決策 + 記入 auto-decisions.jsonl（`"surfaced": true`）
- User Required → 不自動。記入 auto-decisions.jsonl（`"deferred": true`）。用 P1 + 最安全預設值繼續。

### 2. Completion Protocol
正常執行（Operational Reflection + 萃取 + timeline complete event 寫入）。
但不印 welcome-back、不印 predictive suggestion（沒有用戶在看）。

### 3. 錯誤處理
不問用戶。能自修的自修（例：validate-repo.sh 失敗 → 讀錯誤訊息 → 修），不能的標記 BLOCKED 讓 orchestrator 處理。

### 4. 互動風格
精簡。不解釋決策理由（記在 audit log 就好），只輸出 STATUS + 關鍵數字 + artifact 路徑。
```

- [ ] **Step 2: Commit**

```bash
git add skills/shared/methodology/auto-decision-guide.md
git commit -m "feat: create auto-decision-guide — 6 principles, 3 classifications, spawned session rules"
```

---

### Task 7: Update fix-loop-guide.md — ESCALATE backtrack targets

**Files:**
- Modify: `skills/shared/methodology/fix-loop-guide.md`

- [ ] **Step 1: Add backtrack target to ESCALATE section**

Open `skills/shared/methodology/fix-loop-guide.md`. Replace the existing `### ESCALATE 範圍` section (lines 56-60) with:

```markdown
### ESCALATE 範圍

| 問題 | 回報 | 回退目標（Auto Mode） |
|------|------|---------------------|
| Skill 不應該存在（fails independence test） | 建議合併到哪個 skill | → BUILD（從 skill map 移除，重 build 受影響部分） |
| Workflow 有斷點 | 建議用 /workflow-edit 修 | → BUILD（重新 build workflow 串接，不重做 skill 內容） |
| 整個 skill map 前深後淺 | 建議回 /domain-plan 重新規劃 | → PLAN（重新跑 Plan，帶 check 發現作為 constraints） |

**互動模式：** ESCALATE 項目回報給用戶，由用戶決定下一步。
**自動模式：** ESCALATE 項目觸發 state machine 回退（見 prism-routing/SKILL.md 的 State Machine 段落）。回退時把 `reason` 和 `constraints` 寫入 `auto-run-state.json` 的 `backtrack` 欄位，上游 Agent 讀到後針對性修改，不從頭推導。
```

- [ ] **Step 2: Commit**

```bash
git add skills/shared/methodology/fix-loop-guide.md
git commit -m "feat: add backtrack targets to ESCALATE classification in fix-loop-guide"
```

---

### Task 8: Update state-conventions.md — auto-decisions.jsonl + backtrack schema

**Files:**
- Modify: `skills/shared/state-conventions.md`

- [ ] **Step 1: Add auto-decisions.jsonl to state files table**

In the `## State Files` table, add after the `timeline.jsonl` row (added in Task 4):

```markdown
| `auto-decisions.jsonl` | Auto mode skills | 最終審批門、/domain-upgrade | 自動決策 audit trail（append-only） |
```

- [ ] **Step 2: Add auto-decisions.jsonl schema**

After the `## timeline.jsonl Schema` section (added in Task 4), insert:

```markdown
## auto-decisions.jsonl Schema

自動模式下每個決策的記錄，append-only：
```json
{"ts":"2026-04-15T10:05:00Z","phase":"build","skill":"ad-check","type":"mechanical","decision":"added completion protocol","principle":"P6"}
{"ts":"2026-04-15T10:12:00Z","phase":"plan","skill":"market-research","type":"taste","decision":"kept independent (2/3 tests passed)","principle":"P3","surfaced":true}
{"ts":"2026-04-15T10:20:00Z","phase":"build","skill":"brand-voice","type":"user_required","decision":"kept user weight: CTA 30%","principle":"P1","deferred":true}
```

詳見 `shared/methodology/auto-decision-guide.md`。
```

- [ ] **Step 3: Add backtrack field to auto-run-state.json schema**

In the `## Auto Mode State (auto-run-state.json)` section, add the `backtrack` field to the JSON schema. After `"fix": { ... }`, add:

```json
  "backtrack": {
    "from": null,
    "round": 0,
    "reason": null,
    "constraints": []
  }
```

And add a note below the schema:

```markdown
### backtrack 欄位

Auto mode state machine 回退時寫入：
- `from`：回退來源（`"CHECK"` 或 `"FIX"`）
- `round`：第幾次回退（安全閥：最多 2 次）
- `reason`：ESCALATE 問題的一句話描述
- `constraints`：上游 Agent 必須遵守的約束條件（例：`["執行階段需要至少 3 個 skill"]`）

回退完成後，`backtrack` reset 為 null 值。
```

- [ ] **Step 4: Commit**

```bash
git add skills/shared/state-conventions.md
git commit -m "feat: add auto-decisions.jsonl schema and backtrack field to state conventions"
```

---

### Task 9: Rewrite prism-routing Auto Mode — state machine + simplified dispatch

**Files:**
- Modify: `skills/prism-routing/SKILL.md`

This is the largest Wave 2 change. The Auto Mode section (lines 299-463) gets rewritten with the state machine, decision principle references, and simplified dispatch prompts.

- [ ] **Step 1: Replace the Auto Mode section**

Open `skills/prism-routing/SKILL.md`. Replace everything from `## Auto Mode: 自動 Plan → Build → Check → Fix 迴圈` (line 299) through `### Resumability` section end (line 463) with:

```markdown
## Auto Mode: State Machine Pipeline

當用戶選擇 B（自動模式）時進入此流程。

### State Machine

```
                 ┌──────────┐
                 │  START   │
                 └────┬─────┘
                      │
                 ┌────▼─────┐
                 │   PLAN   │ ◄─── ESCALATE: skill map 結構問題
                 └────┬─────┘          ↑
                      │                │ backtrack
                 ┌────▼─────┐          │
                 │  BUILD   │ ◄─── ESCALATE: skill 獨立性 / workflow 斷點
                 └────┬─────┘          ↑
                      │                │ backtrack
                 ┌────▼─────┐          │
                 │  CHECK   │──────────┘
                 └────┬─────┘
                      │
              ┌───────▼───────┐
              │ score >= 門檻? │
              └───┬───────┬───┘
                  │yes    │no
                  │  ┌────▼────┐
                  │  │   FIX   │
                  │  └────┬────┘
                  │       │
                  │  ┌────▼─────────┐
                  │  │ re-CHECK     │──→ 分數沒升? → DONE_WITH_CONCERNS
                  │  └────┬─────────┘
                  │       │ 夠了 ↓
              ┌───▼───────▼───┐
              │     DONE      │
              └───────────────┘
```

每個 phase 的子 Agent 透過 preamble 的 `SPAWNED` 偵測自動進入 spawned session 模式。決策依據見 `shared/methodology/auto-decision-guide.md`。

### Auto Phase 0: 收集輸入

問兩個問題（僅此兩問，不再多問）：

1. 「你的領域是什麼？（一句話就好，也可以給檔案路徑或詳細描述）」
2. 「品質門檻？」
   - A) Draft（12/30）— 最快，骨架版
   - B) Usable（18/30）— 推薦（預設）
   - C) Production（24/30）— 最慢，需要更多材料

收到後建立 `auto-run-state.json`，開始自動執行。

**從這裡開始，用戶不再被打斷。** 所有步驟自動進行直到完成或觸發 safety valve。

### Auto Phase 1: PLAN

```
dispatch Agent(subagent_type="general-purpose", prompt="""
你是 Prismstack 的 /domain-plan skill。

讀取方法論：
  cat {PRISM_DIR}/shared/methodology/skill-map-methodology.md
讀取決策指南：
  cat {PRISM_DIR}/shared/methodology/auto-decision-guide.md

用戶的領域輸入：{domain_input}
{backtrack_constraints_if_any}

按 /domain-plan 的 Phase 0-5 執行。
Preamble 會偵測 SPAWNED=true，自動切換為 spawned session 模式。
品質級別按 How-To 9 偵測輸入品質。
產出存到 {PROJECTS_DIR}/

完成後報告：skill_count, artifact_path
""")
```

更新 state: plan.status = "done", current_state = "BUILD"

如果是回退（`backtrack.from` 不為 null）：
- 把 `backtrack.constraints` 注入到 prompt 的 `{backtrack_constraints_if_any}` 位置
- Agent 針對 constraints 修改 skill map，不從頭推導
- 完成後 reset backtrack 為 null

### Auto Phase 2: BUILD

```
dispatch Agent(subagent_type="general-purpose", prompt="""
你是 Prismstack 的 /domain-build skill。

讀取方法論：
  cat {PRISM_DIR}/shared/methodology/skill-craft-guide.md
  cat {PRISM_DIR}/shared/methodology/system-wiring-guide.md
讀取決策指南：
  cat {PRISM_DIR}/shared/methodology/auto-decision-guide.md

Skill map: {plan.artifact}
建到: {repo_path}
{backtrack_constraints_if_any}

按 /domain-build 的 Phase 0-7 執行。
Preamble 會偵測 SPAWNED=true，自動切換為 spawned session 模式。
每個 skill 按 How-To 10 品質對等生成。
完成後跑 validate-repo.sh，失敗的自動修。

報告：skills_generated, repo_path
""")
```

更新 state: build.status = "done", current_state = "CHECK"

### Auto Phase 3: CHECK（Independent Evaluator）

**關鍵：這是獨立的 evaluator，fresh context，不知道 generator 做了什麼。**

```
dispatch Agent(subagent_type="general-purpose", prompt="""
你是 Prismstack 的 /skill-check 品質審查員。

讀取標準：
  cat {PRISM_DIR}/shared/methodology/quality-standards.md

審查目標：{repo_path}/skills/*/SKILL.md
模式：review --all（15D + 6 mines + cross-skill analysis）

你不知道這些 skill 是怎麼生成的。你只看到成品。
嚴格打分。每個 2 分都要有證據。
不讀 auto-decision-guide.md — 你是獨立評判者。

報告：per-skill scores, avg_score, below_threshold skills, mines triggered
對每個低分 skill，分類問題為 AUTO-FIX / ASK / ESCALATE（含回退目標）。
""")
```

讀取結果。更新 state。

### Auto Phase 4: FIX, BACKTRACK, or DONE

```
讀取 CHECK 結果。

# 1. 檢查是否有 ESCALATE 項目需要回退
escalate_items = check 結果中 type == "ESCALATE" 的項目

if escalate_items 存在 AND backtrack.round < 2:
    # 判斷回退目標
    for item in escalate_items:
        if item.target == "PLAN":
            寫入 auto-run-state.json:
              backtrack.from = "CHECK"
              backtrack.round += 1
              backtrack.reason = item.reason
              backtrack.constraints = item.constraints
            current_state = "PLAN"  # 回退到 PLAN
            → 跳到 Auto Phase 1
        elif item.target == "BUILD":
            寫入 auto-run-state.json:
              backtrack.from = "CHECK"
              backtrack.round += 1
              backtrack.reason = item.reason
              backtrack.constraints = item.constraints
            current_state = "BUILD"  # 回退到 BUILD
            → 跳到 Auto Phase 2

# 2. 如果沒有 ESCALATE 或回退已用完，走原有 fix 邏輯
if check.avg_score >= quality_threshold AND mines == 0:
    current_state = "DONE"
elif fix.rounds_completed >= max_fix_rounds:
    current_state = "DONE_WITH_CONCERNS"
elif fix.last_avg_score != null AND check.avg_score <= fix.last_avg_score:
    current_state = "DONE_WITH_CONCERNS"
else:
    fix.last_avg_score = check.avg_score

    dispatch Agent(prompt="""
    你是 Prismstack 的 fix loop 執行者。

    讀取指南：
      cat {PRISM_DIR}/shared/methodology/fix-loop-guide.md
    讀取決策指南：
      cat {PRISM_DIR}/shared/methodology/auto-decision-guide.md

    審查結果：{check_results}
    修復目標：score < {threshold} 的 skills

    Preamble 會偵測 SPAWNED=true，自動切換為 spawned session 模式。
    AUTO-FIX 項目直接修。
    ASK 項目用 auto-decision-guide 的原則決策。
    ESCALATE 項目標記但不修（由上層 state machine 處理）。
    每個修改都 atomic commit。
    每個決策記入 auto-decisions.jsonl。

    報告：fixes_applied, escalated_items
    """)

    fix.rounds_completed += 1
    current_state = "CHECK"  # re-check
```

### Auto Phase 5: 交付 + 審批門

```
if current_state == "DONE" OR current_state == "DONE_WITH_CONCERNS":

    # 讀取 auto-decisions.jsonl，找出需要用戶確認的決策
    taste_decisions = auto-decisions.jsonl 中 "surfaced": true 的
    deferred_decisions = auto-decisions.jsonl 中 "deferred": true 的

    if current_state == "DONE":
        向用戶報告：
        「✅ 自動搭建完成。

         領域：{domain}
         Skills：{skill_count} 個
         品質：avg {avg_score}/30（{grade}）
         Fix 輪數：{rounds}
         回退輪數：{backtrack.round}

         Repo 在：{repo_path}
         安裝：cd {repo_path} && bash bin/install.sh --project」

    elif current_state == "DONE_WITH_CONCERNS":
        向用戶報告：
        「⚠️ 自動搭建完成，但有未解決問題。

         品質：avg {avg_score}/30
         未通過的 skills：{below_threshold}
         ESCALATE 項目：{escalated}

         建議：切換到互動模式，用 /skill-edit 手動改進。」

    # 審批門（如果有 taste 或 deferred 決策）
    if taste_decisions OR deferred_decisions:
        列出所有需要確認的決策（見 auto-decision-guide.md 的「最終審批門」格式）
        等用戶確認或修改
```

### Safety Valves

| 條件 | 動作 |
|------|------|
| fix 3 輪後分數還不夠 | DONE_WITH_CONCERNS |
| 連續 2 輪分數不升 | DONE_WITH_CONCERNS（避免死循環） |
| 回退超過 2 次 | DONE_WITH_CONCERNS（回退用完） |
| 回退後 re-check 分數反而降了 | 停止，revert 到回退前版本 |
| 同一 ESCALATE 問題第二次出現 | 不再回退，標記未解決 |
| 用戶打斷（任何輸入） | 停下來，報告當前狀態，問要繼續還是切互動模式 |

### Resumability

如果中斷（context 溢出、用戶關閉 session）：
- 下次啟動 /prismstack → Phase 1 偵測到 auto-run-state.json
- 顯示上次進度：「偵測到上次的自動搭建：{domain}，停在 {current_state}。」
- 如果有 `backtrack` 狀態 → 「上次在回退第 {round} 輪，原因：{reason}」
- 「要繼續嗎？」
```

- [ ] **Step 2: Verify the surrounding sections are intact**

Read lines before 299 and after the original 463 to confirm:
- `## Phase 4: Load & Execute Sub-Skill` section above is untouched
- `## Workflow Pipeline` section below is untouched

- [ ] **Step 3: Commit**

```bash
git add skills/prism-routing/SKILL.md
git commit -m "feat: rewrite auto mode — state machine with backtrack, decision principles, approval gate"
```

---

### Task 10: Final validation

**Files:**
- None (validation only)

- [ ] **Step 1: Run install test**

```bash
bash test/install-test.sh
```

Expected: All tests pass.

- [ ] **Step 2: Verify all 7 files are consistent**

Read each modified/created file and cross-check:
1. `preamble.md` references `timeline.jsonl` → `state-conventions.md` has its schema
2. `preamble.md` references `SPAWNED` → `auto-decision-guide.md` has spawned section
3. `completion-protocol.md` references `operational` type → `context-accumulation-guide.md` defines it
4. `fix-loop-guide.md` references backtrack targets → `prism-routing/SKILL.md` has state machine
5. `state-conventions.md` has `auto-decisions.jsonl` → `auto-decision-guide.md` defines its schema
6. `prism-routing/SKILL.md` dispatch prompts reference `auto-decision-guide.md` → file exists

- [ ] **Step 3: Verify no broken cross-references in all skill SKILL.md files**

```bash
grep -r "auto-decision-guide" skills/ --include="*.md"
grep -r "timeline.jsonl" skills/ --include="*.md"
grep -r "auto-decisions.jsonl" skills/ --include="*.md"
grep -r "SPAWNED" skills/ --include="*.md"
grep -r "operational" skills/shared/methodology/ --include="*.md"
```

Verify each reference points to a file or section that exists.

- [ ] **Step 4: Final commit (if any fixups needed)**

```bash
git add -A
git commit -m "fix: cross-reference fixups from system automation upgrade"
```

Only if Step 3 found issues. Otherwise skip.
