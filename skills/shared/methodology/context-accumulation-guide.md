# Context Accumulation 指南

> 用途：所有 skill 的 Completion 階段。
> 語境：你剛完成一次互動，要在收尾時萃取值得記住的脈絡。

## 原則

1. **執行中不記錄** — 你在做正事時不要想「這句話要不要記」。完全專注於任務。
2. **Completion 時回顧** — 任務做完、要報告 STATUS 的時候，回顧一次用戶的輸入。
3. **只記 5 種信號** — expertise / correction / preference / benchmark / operational。其他不記。
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

### 第 5 種信號：operational

| 信號 | 偵測規則 | 記錄為 |
|------|---------|--------|
| **operational** | 這次 session 有方法失敗、有走錯路、有發現 domain-specific 怪癖 | `"type": "operational"` |

Operational 信號由 Completion Protocol 的 Operational Reflection 步驟產生，不在萃取流程中重複偵測。

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

## Phase 0 讀取規則

每個 skill 啟動時 preamble 讀 domain-config.json，按優先級注入（詳見 preamble.md 的 Learnings Injection 段落）：
- 如果有 `accumulated.corrections` → 最高優先。列出避免重複。
- 如果有 `accumulated.benchmarks` → 注入到 scoring calibration
- 如果有 `accumulated.expertise` → 用在生成 skill 的維度和權重
- 如果有 `accumulated.operational` → 用在避免走錯路
- 如果有 `accumulated.preferences` → 調整互動風格

**衰減過濾：** 注入前計算每筆 entry 的 effective confidence（初始 confidence - 衰減）。effective confidence < 3 的不注入。

**不讀 decision-log.jsonl**（除非用戶明確要看歷史）。
