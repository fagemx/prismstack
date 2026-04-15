# Completion Protocol

Every Prismstack skill ends with one of these statuses:

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

## Completion 萃取步驟

**在報告 STATUS 之前，自動執行一次萃取：**

### 萃取什麼（4 種信號）

| 信號 | 偵測規則 | 記錄為 |
|------|---------|--------|
| **expertise** | 用戶表達了領域專業知識（維度、指標、判斷標準、流程） | `"type": "expertise"` |
| **correction** | 用戶修正了 skill 的行為（「這個不對」「應該是 X」） | `"type": "correction"` |
| **preference** | 用戶表達了互動偏好（「太多 STOP」「不要問這個」） | `"type": "preference"` |
| **benchmark** | 用戶提供了具體數字或標準（「CTR 3.5%」「D7 retention 20%」） | `"type": "benchmark"` |

### 什麼不萃取

- 「好」「繼續」「A」等操作指令
- 已經在 artifact 裡的結構化產出（不重複記錄）
- 一般性閒聊

### 怎麼萃取

```
1. 回顧這次互動中用戶的所有輸入
2. 用上面 4 個信號過濾
3. 有匹配 → 寫入 domain-config.json 的 accumulated section + append decision-log.jsonl
4. 沒有匹配 → 跳過（大部分 session 不會有）
5. 然後報告 STATUS
```

### 衝突解決

如果新的萃取跟之前的矛盾（例如 Round 3 說「看 A」，Round 7 說「不看 A」）：
- **correction 優先** — 後來的修正覆蓋之前的
- 在 decision-log.jsonl 裡兩筆都保留（歷史可追溯）
- 在 domain-config.json 的 accumulated 裡只保留最新的
- 加 `"supersedes": "之前的 content"` 標記

## STATUS: DONE
All steps completed. Evidence provided. Artifacts saved.
- Include: summary of what was done, artifact locations, recommended next skill

## STATUS: DONE_WITH_CONCERNS
Completed, but user should know about these issues.
- Include: what was done, concerns list, whether concerns are blocking

## STATUS: BLOCKED
Cannot continue.
- Include: ESCALATION_REASON (what's blocking), SUGGESTION (what to try)

## STATUS: NEEDS_CONTEXT
Missing information to proceed.
- Include: what information is needed, why it's needed, what to do with it

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
