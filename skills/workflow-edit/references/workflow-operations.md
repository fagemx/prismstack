# Workflow Operations Reference

> 用戶可透過 /workflow-edit 執行的操作清單。
> 每個操作定義：做什麼、什麼時候用、改動哪些檔案。

---

## Diagram Format

所有 workflow 圖使用 text-based 格式：

```
/skill-a → artifact-a-*.md → /skill-b → artifact-b-*.md → /skill-c
                                   ↓
                             /skill-d (also consumes artifact-b)
```

規則：
- `/skill-name` 表示 skill 節點
- `artifact-*.md` 表示 artifact 邊
- `→` 表示資料流方向
- `↓` 表示分岔（一個 artifact 被多個下游消費）
- 孤立 skill 放在圖底部，標註 `[orphan]`

---

## Operation 1: View Workflow

**做什麼：** 掃描所有 SKILL.md，建構 artifact flow 圖，以 text diagram 呈現。

**什麼時候用：**
- 用戶想了解目前 skill 間的串接關係
- 修改前先看全局

**步驟：**
1. `ls skills/` 取得所有 skill
2. 讀每個 SKILL.md 的 description — 提取上游/下游/產出
3. 建構 adjacency list：skill → [produces] → artifact → [consumed by] → skill
4. 渲染 text diagram
5. 如果 `workflow-graph.md` 存在，對比差異

**改動的檔案：** 無（唯讀操作）。如果 `workflow-graph.md` 不存在或過時，建議更新。

---

## Operation 2: Add Connection

**做什麼：** 在兩個 skill 之間建立新的 artifact flow 連線。

**什麼時候用：**
- 新增 skill 後需要 wire in
- 發現兩個 skill 之間應該有資料流但沒有

**步驟：**
1. 確認：source skill、target skill、artifact 名稱
2. 修改 source skill 的 SKILL.md：
   - description 的「下游」加入 target skill
   - completion section 的「推薦下一步」加入 target skill
3. 修改 target skill 的 SKILL.md：
   - description 的「上游」加入 source skill
   - Phase 0 (artifact discovery) 加入新 artifact pattern
4. 更新 `workflow-graph.md`

**改動的檔案：**
- `skills/{source}/SKILL.md` — description + completion
- `skills/{target}/SKILL.md` — description + discovery phase
- `workflow-graph.md`

**注意：** 只改連線相關欄位。不改 skill 的內部邏輯、gotchas、scoring。

---

## Operation 3: Remove Connection

**做什麼：** 斷開兩個 skill 之間的 artifact flow。

**什麼時候用：**
- 重構 workflow，不再需要某條資料流
- 某條連線是錯誤的

**步驟：**
1. 確認：要斷開的 source skill + target skill + artifact
2. 檢查：斷開後 target skill 是否變成孤兒（沒有任何上游）
3. 檢查：斷開後 artifact 是否變成孤兒（有人產出但沒人消費）
4. 如果有副作用 → 警告用戶，STOP gate
5. 修改 source SKILL.md：移除 description 的下游參考 + completion 的推薦
6. 修改 target SKILL.md：移除 description 的上游參考 + discovery 的 artifact pattern
7. 更新 `workflow-graph.md`

**改動的檔案：** 同 Add Connection，但方向相反。

---

## Operation 4: Reorder

**做什麼：** 改變 skill 在 workflow 中的執行順序。

**什麼時候用：**
- 發現 skill A 應該在 skill B 之前執行
- 調整 artifact 產出的時序

**步驟：**
1. 呈現目前的執行順序（拓撲排序）
2. 用戶指定新順序
3. 驗證新順序是否合法（不違反 artifact 依賴）
4. 如果不合法 → 顯示衝突的依賴，讓用戶決定
5. 更新所有受影響 skill 的 description（上游/下游）
6. 更新 `workflow-graph.md`

**改動的檔案：**
- 所有順序變動 skill 的 `SKILL.md` — description 的上下游參考
- `workflow-graph.md`

---

## Operation 5: Find Gaps

**做什麼：** 掃描 workflow 找出結構問題。

**什麼時候用：**
- 新增/移除 skill 後檢查完整性
- 定期 health check

**偵測的問題類型：**

| 問題 | 定義 | 嚴重度 |
|------|------|--------|
| 孤兒 artifact | 有 skill 產出但沒有 skill 消費 | Warning |
| 無源 artifact | 有 skill 消費但沒有 skill 產出 | Error |
| 孤兒 skill | skill 沒有上游也沒有下游（除了 routing） | Warning |
| 斷裂路徑 | A→B→?→D，B 和 D 之間缺少橋接 | Error |

**步驟：**
1. 建構完整 artifact flow graph
2. 遍歷每個 artifact — 檢查是否有 producer + consumer
3. 遍歷每個 skill — 檢查是否有上游或下游（routing / entry-point skill 除外）
4. 輸出 gap report

**改動的檔案：** 無（唯讀分析）。輸出建議修復操作。

---

## Operation 6: Find Cycles

**做什麼：** 偵測 workflow 中的循環依賴。

**什麼時候用：**
- 修改連線後驗證
- 懷疑有 circular dependency

**步驟：**
1. 建構 directed graph（skill → skill，透過 artifact）
2. 跑 DFS-based cycle detection
3. 如果有 cycle → 顯示完整路徑：A → B → C → A
4. 建議打破 cycle 的方式（移除哪條邊影響最小）

**改動的檔案：** 無（唯讀分析）。輸出建議修復操作。

**注意：** 有些 cycle 是 intentional（例如 review → fix → review）。標註這類 cycle 但不視為 error。

---

## Operation 7: Validate

**做什麼：** 綜合驗證 — 跑 Find Gaps + Find Cycles + 額外一致性檢查。

**什麼時候用：**
- workflow 修改完成後的最終驗證
- 作為 CI/CD 的 pre-commit check

**額外檢查項目：**

| 檢查 | 描述 |
|------|------|
| YAML 一致性 | 所有 SKILL.md 的 description 中上下游參考是否對稱（A 說下游是 B，B 也說上游是 A） |
| Artifact 命名一致 | 同一個 artifact 在不同 skill 中的命名 pattern 是否一致 |
| Routing 覆蓋率 | routing skill 是否包含所有 skill 的觸發條件 |
| workflow-graph.md 同步 | graph 文件是否跟實際 SKILL.md 內容一致 |

**步驟：**
1. 跑 Find Gaps
2. 跑 Find Cycles
3. 跑額外一致性檢查
4. 輸出 validation report（PASS / WARN / FAIL 計數）

**改動的檔案：** 無（唯讀驗證）。輸出建議修復操作列表。
