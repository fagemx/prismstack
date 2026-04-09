# Functional Test Guide — 手動測試 → 發現問題 → 修復 → 重測

> **用途：** domain stack 搭建或升級後，用真實任務測試個別 skill 的實際效果。
> **與 /skill-check 的差異：** /skill-check 檢查結構（SKILL.md 有沒有該有的段落），本指南檢查行為（skill 跑起來結果對不對）。
> **使用者：** /domain-upgrade（feedback mode）、用戶手動測試、/skill-edit（驗收修改效果）

---

## Structural Review vs Functional Test

| | Structural Review (/skill-check) | Functional Test (本指南) |
|---|---|---|
| 檢查什麼 | SKILL.md 的段落、格式、15D 評分 | Skill 跑起來的實際結果 |
| 用什麼 | 讀 SKILL.md 檔案 | 用真實任務執行 skill |
| 發現什麼 | 缺少 gotchas、scoring 不嚴謹、flow 不完整 | 結果品質不對、格式不合下游、效果比預期差 |
| 修復管道 | /skill-edit（改文件）| /skill-edit（改文件）+ scripts/ 修改 |

---

## 單一 Skill 測試迴圈（9 步）

1. **選一個真實任務**（不是玩具範例）
2. **執行 skill**（完整跑一次，包含 Phase 0 到 completion）
3. **評估產出**（對照用戶期望：格式對嗎？內容對嗎？品質可接受嗎？）
4. **記錄發現**（什麼有效、什麼無效、什麼意外）
5. **分類每個發現**：
   - **A類（自動修復）**：機械性問題，有唯一正確答案 → 直接修
   - **B類（需要判斷）**：需要用戶決定 → 問用戶
   - **C類（超出範圍）**：根源在其他 skill 或基礎設施 → 升報
6. **修復**（透過 /skill-edit 或直接修改 scripts/）
7. **用同一個任務重跑**
8. **比較修復前後**
9. **如果改善 → 下一個任務。如果沒有 → 更深入診斷**

---

## 測試案例選擇

每個 skill 至少選 3 個測試案例：

| 類型 | 目的 | 例子 |
|------|------|------|
| **代表性案例** | 最常見的使用情境 | 用一段標準劇本測試 /script-analyze |
| **邊緣案例** | 異常但合法的輸入 | 只有 2 個角色的劇本、超長對白 |
| **失敗案例** | 應該觸發 graceful degradation 的輸入 | 空白輸入、格式完全錯誤的文件 |

---

## 記錄格式（functional-test-log.jsonl）

每次測試追加一行：
```json
{
  "ts": "2026-04-09T09:30:00+08:00",
  "skill": "/script-analyze",
  "task": "用狐九劇本測試結構分析",
  "round": 1,
  "result": "partial",
  "findings": ["角色分類正確", "場景漏了 3 個", "格式與下游不相容"],
  "fix_applied": "修改 scene detection regex",
  "delta": "場景從 5 個增加到 8 個，格式已修正"
}
```

---

## 終止條件

何時可以停止測試：
- 代表性案例連續 2 次通過
- 邊緣案例被 gracefully 處理（結果不完美但不崩潰）
- 失敗案例觸發適當的 BLOCKED 或 DONE_WITH_CONCERNS

---

## 與既有 skills 的整合

- **/domain-upgrade Mode 1（Feedback）**：收集用戶的功能測試回饋時，參考本指南的記錄格式
- **/skill-edit**：完成修改後，建議用戶跑一次 functional test 驗收
- **/skill-check**：structural review 通過不代表 functional test 通過，兩者互補
