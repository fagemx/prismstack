# Design Check — 7 問 Ground Check

> 規劃階段用。對每個候選 skill 逐題跑，判斷該不該建。
> 觸發時機：`/domain-plan` 完成後自動跑，或手動 `/skill-check design`。

---

## 7 個問題

### Q1. 類型？

> 這個 skill 屬於哪一類？

| 類型 | 核心 | 典型輸出 |
|------|------|---------|
| **Review** | 判斷 / 審查 / 評估 | score, issue list, recommendation |
| **Bridge** | 轉譯 / handoff / 切片 | spec, slice plan, acceptance criteria |
| **Production** | 產出 artifact | code, config, document, scaffold |
| **Control** | 路由 / 排程 / 協調 | routing decision, workflow state |
| **Runtime Helper** | 執行環境輔助 | setup script, env check, debug trace |

**PASS:** 能明確歸到一類，且該類在 pack 中有存在理由。
**FAIL:** 歸不進任何一類，或同時跨兩類以上。
- 跨 Review + Production → 拆成兩個 skill，或決定主要姿態只做一邊。
- 歸不進去 → 重新定義 scope，可能是想法還沒成形。

**輸出格式：**
```
Q1 類型：Review
判定：PASS — 純審查 skill，不產出 artifact
```

---

### Q2. Work Unit？

> 它處理的工作單位是什麼？（一次呼叫處理的東西）

**PASS:** 能用一句話說清楚 work unit（例：「一份 GDD」「一個 API endpoint」「一個 skill 檔案」）。
**FAIL:** 說不清楚，或 work unit 太大（「整個專案」）或太小（「一行 config」）。
- 太大 → 拆成多個 skill，每個處理一個明確的 work unit。
- 太小 → 合併到上游 skill 的一個 section。

**輸出格式：**
```
Q2 Work Unit：一份 domain skill 的 SKILL.md
判定：PASS — 明確、大小適中
```

---

### Q3. Artifact？

> 做完留下什麼 artifact？

**PASS:** 有明確的、可被下游消費的 artifact（檔案、structured output、score card）。
**FAIL:** 只留下聊天文字，或 artifact 跟現有 skill 的 artifact 重複。
- 只有聊天 → 補 artifact 輸出（寫檔案或 structured summary）。
- 重複 → 合併到已有那個 artifact 的 skill。

**輸出格式：**
```
Q3 Artifact：score-card.md（9 維度分數 + 6 雷區報告）
判定：PASS — 獨立 artifact，下游可讀
```

---

### Q4. 上下游？

> 上游是誰（輸入從哪來）、下游是誰（輸出給誰用）？

**PASS:** 上游至少一個（明確的觸發來源或輸入 artifact），下游至少一個（消費者或行動項）。
**FAIL:** 沒有上游（孤島 skill，不知道什麼時候用）或沒有下游（做完沒人用）。
- 無上游 → 要嘛補觸發條件，要嘛合併到某個 workflow 節點。
- 無下游 → 重新評估是否需要這個 skill，或補 artifact 輸出讓下游能接。

**輸出格式：**
```
Q4 上游：/domain-build（自動觸發）、用戶手動呼叫
Q4 下游：/skill-edit（根據 review 結果修改）、/domain-upgrade（迭代改進）
判定：PASS — 上下游都有
```

---

### Q5. 痛點？

> 沒有它，workflow 會痛嗎？

**PASS:** 能描述出具體的痛（「沒有它，skill 品質完全靠感覺判斷，容易漏雷區」）。痛點是真實的、不是假設的。
**FAIL:** 痛點是假的（「沒有它也行，只是少一個功能」），或痛點已經被現有 skill 解決。
- 假痛點 → 不建。降為現有 skill 的一個 section 或 checklist item。
- 已被解決 → 不建。確認現有 skill 是否需要加強。

**輸出格式：**
```
Q5 痛點：沒有品質審查，/domain-build 產出的 skill 品質無法量化，只能靠人工通讀
判定：PASS — 真實痛點
```

---

### Q6. Runtime？

> 依賴什麼外部 runtime？（工具、API、檔案系統、資料庫……）

**PASS:** Runtime 依賴明確且可取得。或者不需要外部 runtime（純判斷/審查類）。
**FAIL:** 依賴的 runtime 不存在、不穩定、或用戶環境大概率沒有。
- Runtime 不存在 → 先解決 runtime 問題，或降級為「手動流程 skill」。
- Runtime 不穩定 → 加 fallback / graceful degradation。

**輸出格式：**
```
Q6 Runtime：Read + Glob + Grep（讀 skill 檔案）— 標準工具，無外部依賴
判定：PASS
```

---

### Q7. 獨立性？

> 這是獨立 skill 還是某個 skill 的 section？

判斷標準：
- **有獨立的觸發時機**（不是只在某 skill 流程中才用）→ 獨立 skill
- **有獨立的 artifact**（產出不是某 skill artifact 的子集）→ 獨立 skill
- **兩者都沒有** → 合併為某 skill 的 section

**PASS:** 有獨立觸發 + 獨立 artifact → 應該是獨立 skill。
**FAIL:** 缺獨立觸發或獨立 artifact → 合併。
- 無獨立觸發 → 降為 X skill 的 section（標明是哪個 skill）。
- 有觸發但無獨立 artifact → 考慮合併，或補 artifact。

**輸出格式：**
```
Q7 獨立性：
  獨立觸發：✅（用戶隨時可說 /skill-check）
  獨立 artifact：✅（score card / health report）
判定：PASS — 獨立 skill
```

---

## 彙總報告格式

```
=== Design Check: [skill 名稱] ===

Q1 類型：___          → PASS / FAIL
Q2 Work Unit：___     → PASS / FAIL
Q3 Artifact：___      → PASS / FAIL
Q4 上下游：___        → PASS / FAIL
Q5 痛點：___          → PASS / FAIL
Q6 Runtime：___       → PASS / FAIL
Q7 獨立性：___        → PASS / FAIL

結果：_/7 PASS
判定：
  7/7 → 建
  5-6/7 → 建，但修正 FAIL 項
  3-4/7 → 重新設計後再評估
  0-2/7 → 不建，合併到 ___
```

---

## FAIL 後的行動對照表

| FAIL 項 | 常見行動 |
|---------|---------|
| Q1 類型不清 | 收窄 scope，選一個主要姿態 |
| Q2 Work unit 太大 | 拆成多個 skill |
| Q2 Work unit 太小 | 合併到上游 skill 的 section |
| Q3 無 artifact | 補 artifact 設計，或合併 |
| Q4 無上游 | 補觸發條件或合併到 workflow 節點 |
| Q4 無下游 | 評估是否需要，補 artifact 輸出 |
| Q5 假痛點 | 降為現有 skill 的 checklist item |
| Q6 Runtime 不可得 | 先解決 runtime 或降級 |
| Q7 非獨立 | 合併到指定 skill |
