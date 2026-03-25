# Skill 類型指南

> 用途：/domain-plan Phase 2-3，分類候選 skill 並決定寫作重點

---

## 五種 Skill 類型

| 類型 | 核心動作 | 典型產出 | 寫作重點 |
|------|---------|---------|---------|
| **Review** | 判斷/審查 | score, issue list, verdict | dimensions + scoring + anti-sycophancy + forcing questions |
| **Bridge** | 轉譯/handoff | spec, slice plan, structured doc | translation logic + scope + in/out contract + dependency mapping |
| **Production** | 生產/生成 | code, asset, content, document | build target + steps + fallback + success criteria |
| **Control** | 路由/編排 | workflow map, routing decision | routing logic + pack health + conflict resolution |
| **Runtime Helper** | 依賴外部 runtime | varies (test result, deploy status) | runtime dependency declaration — 沒 runtime 就不要建這個 skill |

---

## 各類型詳細說明

### Review 型

**做什麼：** 拿到一個 artifact，判斷它好不好，產出分數和問題清單。

**寫作重點：**
- **審查維度**：明確列出要看的每個面向，每個維度有 0-2 或 0-5 的評分標準
- **校準基準**：什麼叫好、什麼叫差，用具體數字或案例說明
- **反諂媚**：列出這個領域 AI 最常說的空洞讚美，明確禁止
- **逼問問題**：打破表面的問題，至少 3 個
- **verdict 格式**：最後一定要輸出結構化的判定（PASS / CONDITIONAL / FAIL + 理由）

**常見錯誤：** Claude 容易把 review 寫成「列優缺點」而不是「打分數 + 判生死」。

### Bridge 型

**做什麼：** 把上游 skill 的產出轉譯成下游 skill 能消費的格式。

**寫作重點：**
- **輸入契約**：明確說上游會給什麼格式
- **輸出契約**：明確說下游需要什麼格式
- **轉譯邏輯**：哪些資訊要保留、哪些要丟棄、哪些要重組
- **scope 控制**：不要在 bridge 裡做判斷或生產，只做轉譯
- **缺失偵測**：上游產出缺東西時怎麼處理（問用戶 vs 用預設值 vs 擋住）

**常見錯誤：** Claude 容易在 bridge 裡偷做 review 或偷做 production。Bridge 就是 bridge。

### Production 型

**做什麼：** 根據 spec/plan 生產實際的東西（code、content、asset）。

**寫作重點：**
- **建造目標**：明確說要產出什麼，什麼格式，存在哪裡
- **步驟序列**：嚴格的步驟，不能跳
- **fallback**：每一步失敗時怎麼辦
- **成功標準**：怎麼判斷做完了、做對了
- **guardrails**：不能超出 spec 範圍、不能自己加 scope

**常見錯誤：** Claude 容易在 production 時「順便改善」超出 spec 的東西。

### Control 型

**做什麼：** 決定接下來該跑哪個 skill、管理整體 workflow 健康度。

**寫作重點：**
- **路由邏輯**：什麼條件觸發什麼 skill
- **健康指標**：怎麼判斷整體 workflow 是否順暢
- **衝突解決**：兩個 skill 意見不同時怎麼辦
- **狀態追蹤**：目前在 workflow 的哪個位置

**常見錯誤：** Claude 容易把 control 寫成「什麼都管」的萬能 skill。Control 只做路由和協調。

### Runtime Helper 型

**做什麼：** 呼叫外部 runtime（測試框架、部署系統、分析工具），拿回結果。

**寫作重點：**
- **runtime 依賴宣告**：需要什麼工具/系統/API
- **呼叫格式**：怎麼跟 runtime 互動
- **結果解讀**：runtime 回傳的東西怎麼解讀
- **無 runtime 處理**：如果 runtime 不存在，這個 skill 就不該建

**判斷要不要建：** 如果目標領域沒有可呼叫的外部 runtime → 不要建 runtime helper。不是每個領域都需要這個類型。

---

## 自由度等級

不同類型的 skill 需要不同的自由度：

| 自由度 | 適用情境 | 寫作方式 |
|--------|---------|---------|
| **高** | 發想、構思、批判、brainstorm | principles + heuristics + examples。不限制 agent 的思路，給方向不給答案。 |
| **中** | 結構化 review、bridge、規劃 | phase flow + templates + ask gates。有框架但允許靈活填充。 |
| **低** | production、release、migration | scripts + exact sequence + tight guardrails。每一步都鎖死，不允許自由發揮。 |

### 類型 × 自由度對應

| 類型 | 通常自由度 | 例外 |
|------|-----------|------|
| Review | 中 | 探索性 review（如 office-hours）可以高 |
| Bridge | 中 | — |
| Production | 低 | 創意型 production（如寫作）可以中 |
| Control | 低 | — |
| Runtime Helper | 低 | — |
