# STOP Gates — 互動設計規範

## 語法（唯一正確的寫法）

```markdown
**STOP.** AskUserQuestion to confirm [什麼事]:

> [摘要 + 選項]

**One question only. Wait for answer before proceeding.**
```

詳見 `ask-format.md` 的完整格式和範例。

## 為什麼語法很重要

錯誤的語法 → 模型把選項印成文字 → STOP gate 失效 → pipeline 自動跑完沒停。

已驗證：`**STOP.**` + blockquote + 字母選項 = 模型可靠呼叫 AskUserQuestion 工具。
已驗證失敗：`🛑 STOP Gate：`、`━━━` 邊框、`請確認：` — 這些模型不一定呼叫工具。

## 放置規則

1. **每個 Phase 邊界一個**（最低要求）
2. **額外 gate**：長 Phase（>5 分鐘工作量）、有風險的決定、不可逆操作
3. **連續工作不超過 5 分鐘**就要停一次
4. **判斷分叉前**加一個 — 走 A 路還是 B 路，問用戶

## Gate 不能自動跳過

STOP gate = 強制 AskUserQuestion 工具呼叫。用戶必須明確選擇才能繼續。

唯一例外：pipeline 自動模式（orchestrator 帶 `--auto` flag）可以跳過。

## 每個 Gate 必須包含

1. **摘要**：剛完成什麼（用戶可能離開了 20 分鐘）
2. **關鍵發現**：分數、問題、決定（如果有）
3. **選項**：至少 A) 繼續 / B) 調整 / C) 停止
4. **推薦**：`RECOMMENDATION: Choose X — 理由`

## 中斷恢復

用戶暫停後回來：
- 重新讀取當前狀態（artifact、進度）
- Re-ground（提醒用戶在哪裡）
- 提供繼續或重新開始當前 Phase 的選項
