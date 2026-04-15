# Prismstack System Automation Upgrade

> Status: APPROVED
> Created: 2026-04-15
> Origin: gstack 系統層自動化技巧分析 → 差距評估 → 設計
> Scope: 6 個系統層改動，分 2 波

---

## 問題

Prismstack 的 11 個 builder skill 已完成，品質機制（15D rubric、fix loop、artifact flow）到位。但系統層自動化有三個短板：

1. **跨 session 不記憶** — preamble 只做狀態偵測，不注入歷史 learnings、不記錄 skill 使用 timeline、不做 context recovery
2. **自動模式太粗** — auto mode 的決策方式是「跳過 STOP gates」，沒有決策原則、沒有 taste/mechanical 分類、沒有 audit trail
3. **沒有回退機制** — Check 發現 plan 層問題時只能標記 ESCALATE，無法自動回退到 Plan 重做

## 來源分析

對比 gstack（`C:\ai_base\gstack`）的系統層機制，找到 9 個差距。經評估淘汰 3 個（並行 Review Army、Adaptive Ceremony、Template 生成），保留 6 個分兩波實施。

### 淘汰理由

| 項目 | 淘汰理由 |
|------|---------|
| Review Army（並行 specialist） | Prismstack 的 15D rubric 已足夠結構化。gstack 需要 7 specialist 是因為 code review 維度太多，skill 品質審查不需要。 |
| Adaptive Ceremony（信任驅動儀式） | Prismstack 的使用模式是「建一次、迭代幾輪」，重複頻率不足以累積 trust signal。 |
| Template 生成系統 | Prismstack 只有 11 個 skill，內容是方法論不是 code reference，不需要從 source code 同步。 |

---

## Wave 1：跨 Session 記憶（基礎設施層）

> 前置條件：無
> Wave 2 依賴 Wave 1：自動決策需要讀取歷史資料（timeline、learnings）

### W1-1: Enhanced Preamble

**改動檔案：** `shared/preamble.md`

**現狀：** slug/branch/state 偵測 + accumulated context 讀取。

**新增執行順序：**

```
1. [現有] Project identification (slug, branch, user)
2. [現有] Shared directory setup
3. [現有] State detection (skill-map, domain-config, check-results)
4. [新增] Session lifecycle — cleanup stale sessions (>2hr), count active
5. [新增] Timeline — 讀最近 5 條事件，印 LAST_SESSION + RECENT_PATTERN
6. [新增] Learnings 注入 — 搜 domain-config.json 的 accumulated，印摘要
7. [新增] Spawned session detection — 偵測 auto-run-state.json
8. [新增] Timeline start event — 寫入 started 事件
9. [現有] Artifact summary
```

**新增 bash block：**

```bash
# Session lifecycle (cleanup stale >2hr, count active)
find ~/.prismstack/sessions -mmin +120 -type f -exec rm {} + 2>/dev/null || true
_SESSIONS=$(find ~/.prismstack/sessions -mmin -120 -type f 2>/dev/null | wc -l | tr -d ' ')
echo "ACTIVE_SESSIONS: $_SESSIONS"

# Timeline: last session on this branch
if [ -f "$_STATE_DIR/timeline.jsonl" ]; then
  _LAST=$(grep "\"branch\":\"${_BRANCH}\"" "$_STATE_DIR/timeline.jsonl" 2>/dev/null | grep '"event":"completed"' | tail -1)
  [ -n "$_LAST" ] && echo "LAST_SESSION: $_LAST"
  _RECENT_SKILLS=$(grep "\"branch\":\"${_BRANCH}\"" "$_STATE_DIR/timeline.jsonl" 2>/dev/null | grep '"event":"completed"' | tail -3 | grep -o '"skill":"[^"]*"' | sed 's/"skill":"//;s/"//' | tr '\n' ',')
  [ -n "$_RECENT_SKILLS" ] && echo "RECENT_PATTERN: $_RECENT_SKILLS"
fi

# Learnings injection summary
if [ "$_HAS_ACCUMULATED" = "1" ] && [ -f "$_STATE_DIR/domain-config.json" ]; then
  _EXPERT_COUNT=$(grep -c '"type":"expertise"' "$_STATE_DIR/domain-config.json" 2>/dev/null || echo "0")
  _CORRECT_COUNT=$(grep -c '"type":"correction"' "$_STATE_DIR/domain-config.json" 2>/dev/null || echo "0")
  _BENCH_COUNT=$(grep -c '"type":"benchmark"' "$_STATE_DIR/domain-config.json" 2>/dev/null || echo "0")
  echo "LEARNINGS: expertise=$_EXPERT_COUNT corrections=$_CORRECT_COUNT benchmarks=$_BENCH_COUNT"
fi

# Spawned session detection
_SPAWNED="false"
if [ -f "$_STATE_DIR/auto-run-state.json" ]; then
  _AUTO_STATE=$(grep -o '"current_state":"[^"]*"' "$_STATE_DIR/auto-run-state.json" 2>/dev/null | head -1)
  [ -n "$_AUTO_STATE" ] && _SPAWNED="true"
fi
echo "SPAWNED: $_SPAWNED"

# Timeline: record skill start
_SESSION_ID="$$-$(date +%s)"
_TEL_START=$(date +%s)
echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"skill\":\"SKILL_NAME\",\"event\":\"started\",\"branch\":\"$_BRANCH\",\"session\":\"$_SESSION_ID\"}" >> "$_STATE_DIR/timeline.jsonl" 2>/dev/null || true
```

**新增行為規則（prose instruction）：**

- `ACTIVE_SESSIONS >= 3` → 每個 AskUserQuestion 加 re-ground（用戶在切視窗）
- `LAST_SESSION` 存在 → 印 welcome-back：「上次在這個 branch 跑了 /skill-name，結果是 outcome」
- `RECENT_PATTERN` 存在且匹配已知 workflow 路徑 → predictive suggestion：
  - domain-plan → 建議 /domain-build
  - domain-build → 建議 /skill-check
  - skill-check → 建議 /skill-edit 或 /domain-upgrade
  - skill-edit,skill-edit,skill-edit → 建議 /skill-check review --all
  - 不匹配 → 不建議（不硬猜）
- `LEARNINGS` 存在 → 讀 domain-config.json 的 accumulated section，注入到 skill context：
  - corrections → 最高優先，列出避免重複
  - benchmarks → 注入 scoring calibration
  - expertise → 用在生成 skill 的維度和權重
  - operational → 用在避免走錯路
  - preferences → 調整互動風格
- `SPAWNED` 是 `"true"` → 進入 spawned session 行為模式（見 W2-3）

---

### W1-2: Self-Improvement（萃取機制升級）

**改動檔案：** `shared/methodology/context-accumulation-guide.md`, `shared/completion-protocol.md`

**改動 A：加 Operational Reflection**

在 `completion-protocol.md` 的萃取步驟之前，加反思 prompt：

```
完成任務後、萃取之前，回答這些：
- 有指令或方法失敗嗎？（例：生成的 skill 驗收沒過、scoring formula 不合理）
- 有走錯路又回頭嗎？（例：先 merge 再 split，浪費了時間）
- 發現什麼 domain-specific 怪癖？（例：這個領域的 review 不能用數字評分）

如果有 → 寫入 domain-config.json 的 accumulated section：
  type: "operational"
  content: 描述
  confidence: 7（首次觀察）

如果沒有 → 跳過
```

新增第 5 種信號類型 `operational`，和原有 4 種（expertise / correction / preference / benchmark）並列。

**改動 B：Confidence + Decay**

domain-config.json 的 accumulated entries 加欄位：

```json
{
  "type": "expertise",
  "content": "廣告素材的 CTA 必須在 mobile 上 48px 以上",
  "confidence": 8,
  "source": "user-stated",
  "ts": "2026-04-15T10:00:00Z"
}
```

衰減規則（preamble 讀取時判斷，不修改檔案）：
- `user-stated` 和 `correction` → 不衰減
- `operational` 和 `expertise`（非 user-stated）→ 每 30 天 confidence -1
- confidence < 3 → preamble 不注入

**改動 C：Preamble 注入邏輯**

已在 W1-1 的行為規則中涵蓋。

---

### W1-3: Session Timeline

**改動檔案：** `shared/preamble.md`（合併到 W1-1）, `shared/completion-protocol.md`

**檔案位置：** `~/.prismstack/projects/{slug}/.prismstack/timeline.jsonl`

**Schema：**

```json
{"ts":"2026-04-15T10:00:00Z","skill":"domain-plan","event":"started","branch":"main","session":"12345-1713168000"}
{"ts":"2026-04-15T10:32:00Z","skill":"domain-plan","event":"completed","branch":"main","outcome":"done","duration_s":"1920","session":"12345-1713168000"}
```

| 欄位 | 說明 |
|------|------|
| ts | UTC timestamp |
| skill | skill 名稱 |
| event | `started` / `completed` |
| branch | git branch |
| outcome | 僅 completed：`done` / `done_with_concerns` / `blocked` / `needs_context` |
| duration_s | 僅 completed：秒數 |
| session | `$PPID-$(date +%s)` |

**寫入點：**

1. **Preamble 尾端** — start event（已在 W1-1 bash block 中）
2. **Completion Protocol 尾端** — complete event：

```bash
_TEL_END=$(date +%s)
_TEL_DUR=$(( _TEL_END - _TEL_START ))
echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"skill\":\"SKILL_NAME\",\"event\":\"completed\",\"branch\":\"$_BRANCH\",\"outcome\":\"OUTCOME\",\"duration_s\":\"$_TEL_DUR\",\"session\":\"$_SESSION_ID\"}" >> "$_STATE_DIR/timeline.jsonl" 2>/dev/null || true
```

`SKILL_NAME`：執行 skill 的 agent 在 Completion 時從當前 skill 的 YAML frontmatter `name:` 欄位讀取（例：`domain-plan`、`skill-check`），替換到 bash 命令中。`OUTCOME`：從 Completion Protocol 的 STATUS 映射（DONE → `done`、DONE_WITH_CONCERNS → `done_with_concerns`、BLOCKED → `blocked`、NEEDS_CONTEXT → `needs_context`）。

**讀取點：** W1-1 Enhanced Preamble 的 `LAST_SESSION` + `RECENT_PATTERN`。

**不做：** bin/ 腳本、remote telemetry、timeline 清理（增長很慢，1000 次使用 ~200KB）。

---

## Wave 2：自動決策（行為層）

> 前置條件：Wave 1 完成
> 依賴：timeline（用於 context recovery）、learnings（用於 P1 保留用戶意圖）

### W2-1: Auto Decision Principles

**新增檔案：** `shared/methodology/auto-decision-guide.md`

**Prismstack 的 6 條 Decision Principles：**

| # | 原則 | 說明 | 適用場景 |
|---|------|------|---------|
| P1 | **保留用戶意圖** | 用戶說過的維度、權重、角色定義，永遠優先於 AI 推導的 | scoring formula、role identity、gotchas |
| P2 | **覆蓋優先** | 選覆蓋更多生命週期階段的方案。缺口比冗餘更危險 | skill map 規劃、缺口填補 |
| P3 | **獨立性** | 如果兩個選項都可以，選讓 skill 更獨立的 | skill merge/split 決策 |
| P4 | **品質對等** | 輸入多少，產出多少。一句話不假裝 Production | skill 生成深度 |
| P5 | **最小改動** | 修 skill 時只改有問題的部分 | fix loop、skill-edit |
| P6 | **向前推進** | 有疑問但不阻塞時，選較安全的預設值繼續 | 自動模式全程 |

**衝突解決（per phase）：**
- Plan 階段：P2（覆蓋）+ P3（獨立性）主導
- Build 階段：P4（品質對等）+ P1（用戶意圖）主導
- Check 階段：無自動決策（評判者只看 rubric）
- Fix 階段：P5（最小改動）+ P1（用戶意圖）主導

**Decision Classification：**

| 分類 | 判斷標準 | 處理 |
|------|---------|------|
| **Mechanical** | 有明確正確答案 | 靜默自動決策，記入 audit log |
| **Taste** | 合理的人可能有不同選擇 | 自動決策 + 標記，存入最終審批門 |
| **User Required** | 涉及用戶領域知識或改變用戶明確說過的東西 | 不自動決策，用最安全預設值繼續，deferred 到最終審批門 |

**Mechanical 範例：**
- YAML 缺 `origin:` → 加上
- 沒有 completion protocol → 加上
- skill 超過 250 行沒有 references/ → 拆出

**Taste 範例：**
- 兩個 skill 該 merge 還是保持獨立（獨立性測試 2/3）
- scoring formula 的權重分配（用戶沒說過偏好）
- 某個生命週期階段要不要拆成兩個 skill

**User Required 範例：**
- 用戶說「CTA 最重要」但 AI 推導出品牌一致性權重更高 → 必須問
- 增減 skill（改變用戶同意過的 skill map）
- 改變角色定義

**Audit Trail：** `$_STATE_DIR/auto-decisions.jsonl`

```json
{"ts":"...","phase":"build","skill":"ad-check","type":"mechanical","decision":"added completion protocol","principle":"P6"}
{"ts":"...","phase":"plan","skill":"market-research","type":"taste","decision":"kept independent (2/3 tests passed)","principle":"P3","surfaced":true}
{"ts":"...","phase":"build","skill":"brand-voice","type":"user_required","decision":"kept user weight: CTA 30%","principle":"P1","deferred":true}
```

最終審批門（auto mode 結束前）列出所有 `"surfaced":true` 和 `"deferred":true` 的決策讓用戶確認。

---

### W2-2: State Machine 回退

**改動檔案：** `prism-routing/SKILL.md`, `shared/methodology/fix-loop-guide.md`, `shared/state-conventions.md`

**State Machine：**

```
                 ┌──────────┐
                 │  START   │
                 └────┬─────┘
                      │
                 ┌────▼─────┐
                 │   PLAN   │ ◄─── ESCALATE: 「skill map 前深後淺」
                 └────┬─────┘          ↑
                      │                │ backtrack
                 ┌────▼─────┐          │
                 │  BUILD   │ ◄─── ESCALATE: 「skill 不應該存在」
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

**回退觸發條件（只有 ESCALATE 類問題）：**

| ESCALATE 問題 | 回退到 | 做什麼 |
|--------------|--------|--------|
| Skill 不應該存在（fails independence test） | BUILD | 從 skill map 移除，重 build 受影響部分 |
| Skill map 前深後淺 | PLAN | 重新跑 Plan，帶 check 發現作為 constraints |
| Workflow 有結構性斷點 | BUILD | 重新 build workflow 串接，不重做 skill 內容 |

Mechanical 和 ASK 問題不回退 — 在 FIX 階段就地解決。

**Context 傳遞：** `auto-run-state.json` 增加 backtrack 欄位：

```json
{
  "current_state": "PLAN",
  "backtrack": {
    "from": "CHECK",
    "round": 1,
    "reason": "skill map 前深後淺：策略階段 5 個 skill，執行階段只有 1 個",
    "constraints": ["執行階段需要至少 3 個 skill", "保留策略階段現有 skill"]
  }
}
```

上游 Agent 讀到 `backtrack.constraints` → 針對性修改，不從頭推導。

**安全閥：**

| 條件 | 動作 |
|------|------|
| 回退超過 2 次 | DONE_WITH_CONCERNS |
| 回退後 re-check 分數反而降了 | 停止，revert 到回退前版本 |
| 同一 ESCALATE 問題第二次出現 | 不再回退，標記未解決 |

---

### W2-3: Spawned Session 協議

**改動檔案：** `shared/preamble.md`（合併到 W1-1）, `shared/methodology/auto-decision-guide.md`（合併到 W2-1）, `prism-routing/SKILL.md`

**偵測機制：** 用 `auto-run-state.json` 存在性偵測（已在 W1-1 bash block 中）。不用環境變數，因為 Agent subprocess 不一定繼承環境變數。

**Spawned session 行為規則：**

```
如果 SPAWNED 是 "true"：

1. STOP gates → 不呼叫 AskUserQuestion。用 Auto Decision Principles 自動決策。
   - Mechanical → 靜默決策
   - Taste → 自動決策 + 記入 auto-decisions.jsonl
   - User Required → 不自動。記入 auto-decisions.jsonl 標記 "deferred":true。
     用 P1（保留用戶意圖）+ 最安全預設值繼續。

2. Completion Protocol → 正常執行（萃取 + timeline 寫入）。
   不印 welcome-back、不印 predictive suggestion。

3. 錯誤處理 → 不問用戶。能自修的自修，不能的標記 BLOCKED。

4. 互動風格 → 精簡。不解釋決策理由，只輸出 STATUS + 關鍵數字 + artifact 路徑。
```

**Deferred decisions 處理：**

1. 讀 `domain-config.json` accumulated context → 用 P1 保留用戶意圖
2. 沒有 context → 最保守預設值
3. 標記 `"deferred": true` 進 audit trail
4. 最終審批門列出所有 deferred decisions

**對 prism-routing/SKILL.md 的簡化：** Auto Mode 的 Agent dispatch prompt 不再需要長段「跳過 STOP gates、不問用戶、自動做最佳決策」。改為確保 `auto-run-state.json` 存在，子 skill 的 preamble 自動偵測 → 自動切換行為。

---

## 全局改動清單

| 檔案 | Wave | 改動類型 | 說明 |
|------|------|---------|------|
| `shared/preamble.md` | W1 | 修改 | Session lifecycle + Timeline 讀取/寫入 + Learnings 注入 + Spawned 偵測 |
| `shared/completion-protocol.md` | W1 | 修改 | Operational reflection + Timeline complete event 寫入 |
| `shared/methodology/context-accumulation-guide.md` | W1 | 修改 | 加 operational 類型 + confidence + decay 規則 |
| `shared/methodology/auto-decision-guide.md` | W2 | **新建** | 6 原則 + 3 分類 + audit trail + spawned session |
| `shared/methodology/fix-loop-guide.md` | W2 | 修改 | ESCALATE 加回退目標欄位 |
| `shared/state-conventions.md` | W2 | 修改 | auto-run-state.json schema 加 backtrack |
| `prism-routing/SKILL.md` | W2 | 修改 | Auto Mode 改 state machine + 引用 auto-decision-guide + 簡化 dispatch prompt |

## 新增 Persistence

| 檔案 | 位置 | 用途 | 寫入者 | 讀取者 |
|------|------|------|--------|--------|
| `timeline.jsonl` | `$_STATE_DIR/` | Skill 使用歷史 | Preamble (start) + Completion (complete) | Preamble (recovery, prediction) |
| `auto-decisions.jsonl` | `$_STATE_DIR/` | 自動決策 audit trail | Auto mode skills | 最終審批門、/domain-upgrade |

## 不做

- 不新增 bin/ 腳本（bash inline 夠用）
- 不做 remote telemetry（只 local）
- 不做 timeline 清理（增長太慢不需要）
- 不做並行 Review Army（15D rubric 已足夠）
- 不做 Adaptive Ceremony（使用頻率不足以累積 trust）
- 不做 Template 生成（skill 數量少、內容穩定）
