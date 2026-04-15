# Fix Loop — 發現問題 → 修復 → 驗證

> 用途：/skill-check 發現問題後自動修復、/domain-build 驗收失敗後自動修復。
> 語境：你正在幫用戶修復 skill 的品質問題，不是修 code bug。

## 完整迴圈

```
Step 1: Baseline Score  → 記錄修復前的分數
Step 2: Issue Triage    → 分類每個問題
Step 3: Fix Loop        → 逐一修復 → 驗證
Step 4: Re-score        → 重新打分
Step 5: Delta Report    → before → after 對比
```

## Step 1: Baseline Score

修復前先記錄當前狀態：
- 如果是 /skill-check review → 記錄 15D score（例：17/30）
- 如果是 /domain-build validate → 記錄 5 項驗收結果

這就是 baseline。修完後要跟它比。

## Step 2: Issue Triage

每個發現的問題分三類：

| 類別 | 條件 | 動作 |
|------|------|------|
| **AUTO-FIX** | 機械問題，有明確正確答案 | 直接修，不問 |
| **ASK** | 判斷問題，需要用戶決定 | 列出選項，問用戶 |
| **ESCALATE** | 結構問題，不是修一個 skill 能解決的 | 停下來報告，建議重新規劃 |

### Prismstack 的 AUTO-FIX 範圍

| 問題 | AUTO-FIX 動作 |
|------|--------------|
| YAML 缺 `origin:` field | 加上 `origin: prismstack-generated` |
| 沒有 completion protocol | 加 STATUS: DONE section |
| 沒有 artifact discovery | 加 Phase 0 discovery bash block |
| description 缺 anti-trigger | 加 "Do NOT use when:" |
| SKILL.md > 250 行但沒有 references/ | 把長 section 拆到 references/ |
| 沒有 STOP gates | 在每個 phase 結尾加 STOP |

### ASK 範圍

| 問題 | 問什麼 |
|------|--------|
| Scoring formula 不對 | 「目前的權重是 X，你覺得合理嗎？」 |
| Gotchas 太 generic | 「這個 gotcha 對你的領域適用嗎？要改成什麼？」 |
| Skill 類型分錯 | 「這個 skill 我判斷是 Review，但它的行為更像 Bridge。你覺得？」 |
| Role identity 太 generic | 「目前角色是 'you are a helper'，建議改成 [具體角色]。OK？」 |

### ESCALATE 範圍

| 問題 | 回報 | 回退目標（Auto Mode） |
|------|------|---------------------|
| Skill 不應該存在（fails independence test） | 建議合併到哪個 skill | → BUILD（從 skill map 移除，重 build 受影響部分） |
| Workflow 有斷點 | 建議用 /workflow-edit 修 | → BUILD（重新 build workflow 串接，不重做 skill 內容） |
| 整個 skill map 前深後淺 | 建議回 /domain-plan 重新規劃 | → PLAN（重新跑 Plan，帶 check 發現作為 constraints） |

**互動模式：** ESCALATE 項目回報給用戶，由用戶決定下一步。
**自動模式：** ESCALATE 項目觸發 state machine 回退（見 prism-routing/SKILL.md 的 State Machine 段落）。回退時把 `reason` 和 `constraints` 寫入 `auto-run-state.json` 的 `backtrack` 欄位，上游 Agent 讀到後針對性修改，不從頭推導。

## Step 3: Fix Loop

按 severity 排序（ESCALATE 先報 → ASK 次之 → AUTO-FIX 最後批量做）：

```
for each AUTO-FIX issue:
  1. 讀目標 skill 的相關 section
  2. 做最小修改（不重寫、不重構、不加新功能）
  3. 記錄改了什麼

STOP gate: 列出所有 ASK items，逐一問用戶

for each user-approved ASK fix:
  1. 執行修改
  2. 記錄

ESCALATE items: 列出，不修，建議用戶下一步
```

### 安全閥

| 條件 | 動作 |
|------|------|
| 修了 10 個 AUTO-FIX 還沒結束 | 停下來，告訴用戶剩多少，問要不要繼續 |
| 修了一個但更多維度變差了 | 停下來，考慮 revert |
| ASK items > 5 個 | 分批問（5 個一批），不要一次丟 20 個問題給用戶 |

### Guard Check（每個 AUTO-FIX 完成後）

修了一個問題後，不只看目標維度有沒有改善，也要看其他維度有沒有被打破：

```
for each completed fix:
  1. Verify: 目標維度有改善嗎？（例：A1 Trigger 從 0 → 1）
  2. Guard: 其他維度有變差嗎？（快速掃描相鄰維度）
     - 如果修 A1 Trigger 時改了 description → 檢查 A2 Role 有沒有被影響
     - 如果修 C7 Gotchas 時加了大段內容 → 檢查 D10 Disclosure（是不是 SKILL.md 變太長）
     - 如果修 E13 Discovery 時改了 Phase 0 → 檢查 B4 Externalization（flow 有沒有斷）

  if Verify pass AND Guard pass → keep fix
  if Verify pass AND Guard fail → rework（帶 Guard 失敗的約束，最多 2 次）
  if Verify fail → revert fix
  if rework 2 次仍 Guard fail → revert，標記為 ASK（需要用戶判斷 tradeoff）
```

**Guard 不是完整 re-review。** 它是快速掃描（~30 秒），只看被修改的檔案影響到的相鄰維度。完整的 re-review 在 Step 4 做。

## Step 4: Re-score

所有修復完成後，重新跑一次打分：
- 用跟 Step 1 一樣的標準
- 記錄 final score

## Step 5: Delta Report

```
=== Fix Loop Report ===
Baseline: 17/30 (Draft)
Final:    23/30 (Usable)
Delta:    +6

AUTO-FIX:  8 items → 8 fixed
ASK:       3 items → 2 fixed, 1 deferred
ESCALATE:  1 item → reported (workflow gap)

Dimension deltas:
  A1 Trigger:     1 → 2 (+1)  ← AUTO-FIX: added anti-trigger
  B5 STOP Gates:  0 → 2 (+2)  ← AUTO-FIX: added gates
  C7 Gotchas:     1 → 1 (0)   ← no change (ASK deferred)
  ...
```

不要說「修好了」然後沒數字。
永遠用 baseline → final → delta 呈現。
