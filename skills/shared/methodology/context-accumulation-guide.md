# Context Accumulation 指南

> 用途：所有 skill 的 Completion 階段。
> 語境：你剛完成一次互動，要在收尾時萃取值得記住的脈絡。

## 原則

1. **執行中不記錄** — 你在做正事時不要想「這句話要不要記」。完全專注於任務。
2. **Completion 時回顧** — 任務做完、要報告 STATUS 的時候，回顧一次用戶的輸入。
3. **只記 4 種信號** — expertise / correction / preference / benchmark。其他不記。
4. **大部分 session 不記任何東西** — 這是正常的。不是每次互動都有新脈絡。

## 萃取流程

```
完成任務
  ↓
回顧用戶在這次互動中的輸入
  ↓
有沒有 4 種信號之一？
  → 沒有 → 直接報告 STATUS（大部分情況）
  → 有 → 萃取（~5 秒）→ 寫入 → 報告 STATUS
```

## 寫入規則

### domain-config.json (snapshot)
- 新增的加到 `accumulated.{type}` array
- 矛盾的替換舊的（加 `supersedes` 標記）
- 保持 JSON 乾淨（不超過 50 條 accumulated entries）
- 超過 50 條 → 移除最舊的 expertise（corrections 和 preferences 保留更久）

### decision-log.jsonl (append-only)
- 永遠 append，不修改不刪除
- 每筆包含 ts、skill、type、content、extracted_as
- 這是歷史記錄，不是讀取頻繁的狀態

## Phase 0 讀取規則

每個 skill 啟動時讀 domain-config.json：
- 如果有 `accumulated.expertise` → 用在生成 skill 的 scoring/phases/role
- 如果有 `accumulated.corrections` → 避免已知錯誤
- 如果有 `accumulated.preferences` → 調整互動（STOP 頻率、提問方式）
- 如果有 `accumulated.benchmarks` → 用在 scoring calibration

**不讀 decision-log.jsonl**（除非用戶明確要看歷史）。
