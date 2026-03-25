# Prismstack 雙模式設計

> 狀態：討論中
> 日期：2026-03-26

---

## 兩種模式

### Mode A: 互動模式（現有）

```
用戶參與每一步。STOP gate 問用戶確認。品質由用戶 + evaluator 共同保證。

/prismstack → 偵測狀態 → 推薦 skill
  → /domain-plan（用戶確認 skill map）
  → /domain-build（每 5 個 skill 停一次）
  → /skill-check（用戶看報告決定改什麼）
  → /skill-edit（用戶指定改哪裡）

特點：高控制、低風險、適合有特定需求的用戶
```

### Mode B: 自動模式（新增）

```
用戶只說領域 + 品質門檻。代理自動跑完，用戶只看最終結果。

用戶：「幫我建一套行銷 stack，品質至少 Usable」
  → Plan（subagent 1）
  → Build（subagent 2）
  → Check（subagent 3，independent evaluator）
  → Score < 門檻？→ Fix（subagent 4）→ Re-check → 迭代
  → 全部 pass → 交付給用戶

特點：低用戶努力、適合快速出一版、品質由 evaluator 保證
```

---

## 自動模式的技術架構

### 核心原則（來自 Anthropic 文章 + gstack 實踐）

1. **Generator 和 Evaluator 分離** — 用 subagent（fresh context），不在同一個 agent 裡
2. **File-based handoff** — agent 之間只通過 artifact 通訊
3. **Explicit state machine** — 用 state file 追蹤進度，不靠記憶
4. **Quality gate** — evaluator 有硬門檻，低於就繼續迭代
5. **Safety valve** — 最大迭代次數 + 成本估算 + 進度偵測

### State Machine

```
                    ┌──────────────────────────────┐
                    │     auto-run-state.json       │
                    │     (state file on disk)       │
                    └──────────────┬───────────────┘
                                   │
  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
  │  PLAN   │───→│  BUILD  │───→│  CHECK  │───→│  DONE   │
  └─────────┘    └─────────┘    └────┬────┘    └─────────┘
                                     │
                                  score < 門檻？
                                     │ yes
                                ┌────▼────┐
                                │   FIX   │
                                └────┬────┘
                                     │
                                     └──→ CHECK（re-check）
                                          │
                                          └─→ 最大 3 輪 → DONE_WITH_CONCERNS
```

### State File Format

```json
{
  "mode": "auto",
  "domain": "行銷",
  "quality_threshold": 18,
  "max_fix_rounds": 3,
  "current_state": "CHECK",
  "round": 1,
  "started_at": "2026-03-26T10:00:00Z",
  "plan": {
    "status": "done",
    "skill_count": 18,
    "artifact": "skill-map-2026-03-26-1000.md"
  },
  "build": {
    "status": "done",
    "repo_path": "/tmp/marketing-stack",
    "skills_generated": 18
  },
  "check": {
    "status": "in_progress",
    "round": 1,
    "scores": {},
    "avg_score": null
  },
  "fix": {
    "rounds_completed": 0,
    "total_fixes": 0
  }
}
```

### 每個步驟的 Subagent 設計

#### Step 1: PLAN（subagent, fresh context）

```
Input:  用戶的領域描述（可能 1 句話，可能 700 行 spec）
Read:   shared/methodology/skill-map-methodology.md
Do:     /domain-plan 的 Phase 0-5（但跳過所有 STOP gates — 自動模式）
Output: skill-map-*.md + workflow-graph-*.md + domain-config.json
```

不問用戶。用 How-To 9（input sensitivity）自動偵測品質，用 How-To 10（proportional output）對等生成。

#### Step 2: BUILD（subagent, fresh context）

```
Input:  skill-map-*.md（從 disk 讀）
Read:   shared/methodology/skill-craft-guide.md + system-wiring-guide.md
Do:     /domain-build 的 Phase 0-7（跳過 STOP gates）
Output: 完整 domain repo（skills/*/SKILL.md + install.sh + etc.）
```

Build 完後跑 validate-repo.sh。如果失敗自動修。

#### Step 3: CHECK（subagent, fresh context — INDEPENDENT EVALUATOR）

```
Input:  domain repo path（從 state file 讀）
Read:   shared/methodology/quality-standards.md
Do:     /skill-check review --all
Output: check-results.json + score per skill + avg score
```

**關鍵：evaluator 是 fresh subagent，不知道 generator 的推理過程。** 這就是文章說的 generator-evaluator 分離。

#### Step 4: FIX（subagent, fresh context）

```
Input:  check-results.json（從 disk 讀）
Read:   shared/methodology/fix-loop-guide.md
Do:     對每個 score < 門檻的 skill 跑 fix loop
        AUTO-FIX 直接修 / ASK 項目自動選最佳選項（不問用戶）
Output: 修改後的 SKILL.md files
```

Fix 完後回 Step 3（re-check）。最多 3 輪。

#### Step 5: DONE or DONE_WITH_CONCERNS

```
if avg_score >= threshold AND 0 mines:
  → DONE：交付給用戶
elif fix_rounds >= max:
  → DONE_WITH_CONCERNS：交付 + 列出未解決問題
```

### 主控邏輯（/prismstack 的 auto mode）

```python
# Pseudocode — 實際是 SKILL.md 裡的指令

state = read_state_file() or create_initial_state(domain, threshold)

while state.current != "DONE":

    if state.current == "PLAN":
        dispatch_subagent("domain-plan", input=domain_description)
        state.plan.status = "done"
        state.current = "BUILD"
        save_state()

    elif state.current == "BUILD":
        dispatch_subagent("domain-build", input=state.plan.artifact)
        state.build.status = "done"
        state.current = "CHECK"
        save_state()

    elif state.current == "CHECK":
        results = dispatch_subagent("skill-check --all", input=state.build.repo_path)
        state.check.scores = results.scores
        state.check.avg_score = results.avg

        if results.avg >= state.quality_threshold:
            state.current = "DONE"
        elif state.fix.rounds_completed >= state.max_fix_rounds:
            state.current = "DONE_WITH_CONCERNS"
        else:
            state.current = "FIX"
        save_state()

    elif state.current == "FIX":
        dispatch_subagent("fix-loop", input=state.check.results)
        state.fix.rounds_completed += 1
        state.current = "CHECK"  # re-check after fix
        save_state()

report_final_results(state)
```

### 可恢復性

因為每步都寫 state file：
- 中斷了 → 重新啟動 → 讀 state file → 從上次的 state 繼續
- 不重做已完成的步驟

### Safety Valves

| 安全閥 | 門檻 | 動作 |
|--------|------|------|
| 最大 fix 輪數 | 3 | 停下來，DONE_WITH_CONCERNS |
| 連續 2 輪沒有進步（分數不升） | 偵測 | 停下來，建議重構 |
| 總時間 | 60 分鐘 | 警告，問要不要繼續 |
| Skill 數量太多（>30） | 偵測 | 建議合併後再跑 |

---

## 進入模式的 UX

```
用戶打 /prismstack

Phase 1: 偵測狀態（現有的 triage）
Phase 2: 偵測到 BLANK
Phase 3: AskUserQuestion

  你想怎麼建？

  A) 互動模式 — 我帶你一步一步走，每步確認
     適合：你有特定需求、有材料想整合、想參與決策
     時間：30-60 分鐘（依領域複雜度）

  B) 自動模式 — 告訴我領域，我自己跑完 plan → build → check → fix
     適合：先出一版能跑的，之後再調
     時間：15-30 分鐘（自動運行，你可以去做別的事）
     品質：至少 Usable（18/30），不夠會自動修

  RECOMMENDATION: 第一次建議 A（互動），了解流程後用 B 會更快。
```

如果選 B：
```
  你的領域是什麼？（一句話就好，也可以給詳細 spec）
  > 用戶輸入

  品質門檻？（預設 Usable = 18/30）
  A) Draft（12/30）— 最快，骨架版
  B) Usable（18/30）— 推薦，能用的版本（預設）
  C) Production（24/30）— 最慢，需要更多輸入材料

  開始了。我會自動跑 Plan → Build → Check → Fix。
  你可以隨時打斷我。完成後會通知你。
```

---

## 實作方式的選擇

### 方案 1：Skill 內部 loop（最簡單）

```
/prismstack auto mode 自己跑迴圈：
  - 在主 context 裡依序讀取各 sub-skill 的 SKILL.md
  - 按 state machine 推進
  - 用 Agent tool 派 subagent 做 evaluator（分離 context）
```

優點：不需要新工具，現有機制就能做
缺點：主 context 會積累，長時間可能 context 溢出

### 方案 2：Bash driver script（gstack 模式）

```
bin/auto-build.sh 驅動整個流程：
  - 每步呼叫 Claude Code CLI
  - 完全獨立的 context（每步新 session）
  - Script 管理 state file
  - Script 判斷下一步
```

優點：完全分離 context，可恢復性最好
缺點：需要 Claude Code CLI 的 headless 模式，技術門檻高

### 方案 3：Hybrid（推薦）

```
/prismstack 是 orchestrator（在主 context）：
  - 讀 state file，判斷下一步
  - 派 subagent（Agent tool）做每個步驟
  - Subagent 完成 → 結果寫到 artifact
  - Orchestrator 讀 artifact → 更新 state → 派下一個 subagent
  - Evaluator 用 subagent（fresh context = 獨立判斷）
```

優點：
- Subagent 有 fresh context（不互相污染）
- Orchestrator context 小（只管 state machine）
- Generator-Evaluator 自然分離
- 現有 Agent tool 就能做

缺點：
- Orchestrator 還是在主 context（但很輕）
- 需要確保 subagent 結果正確寫回 disk

---

## 跟現有架構的關係

| 現有元件 | 自動模式怎麼用 |
|---------|---------------|
| /prismstack triage | 加 auto mode 選項 |
| /domain-plan | subagent 執行，跳過 STOP gates |
| /domain-build | subagent 執行，跳過 STOP gates |
| /skill-check | subagent 執行（independent evaluator） |
| fix-loop-guide | subagent 跑 fix，AUTO-FIX only（不問用戶） |
| state-conventions | 用 auto-run-state.json 追蹤 |
| context-accumulation | completion 時照常萃取 |
| quality-standards | evaluator 的判斷標準（不變） |

**不需要重建任何 skill。** 只需要：
1. 改 /prismstack 的 triage 加 auto mode 選項
2. 加 auto-run-state.json 的 schema
3. 寫 orchestrator 邏輯（~50 行指令在 /prismstack 裡）
4. 每個 sub-skill 加一個 `--auto` flag 支援跳過 STOP gates

---

## 風險和限制

| 風險 | 對策 |
|------|------|
| Evaluator 太寬鬆（什麼都 pass） | 校準：用 quality-standards 的 calibration benchmarks |
| Fix loop 改壞（越修越差） | 每輪 re-score，分數下降就停 |
| Context 溢出（orchestrator 累積太多） | Orchestrator 只管 state，subagent 做重活 |
| 用戶不知道進度 | 每步完成後更新 state file，用戶可以隨時查看 |
| 生成品質太低（Level 1 input） | 誠實標記：「auto mode + Level 1 input = Draft 品質」 |
| 成本失控 | 預估：Plan ~$1 + Build ~$5-20 + Check ~$2 + Fix ~$5-10 = ~$10-35 total |
