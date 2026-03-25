# Pack Health — 7 項結構評估

> Pack 層級的健康度檢查。不看單一 skill，看整體結構有沒有問題。
> 觸發時機：`/domain-build` 完成後自動跑，或手動 `/skill-check pack`。

---

## 7 項評估

### E1. Workflow 跑通

> 假設用戶的典型成果（一個完整的工作循環），反推 workflow 能不能跑到。

**檢查方法：**
1. 定義典型成果（例：「產出一個可運行的 domain gstack」）
2. 反推需要哪些步驟
3. 對照 pack 的 workflow，看每一步是否有 skill 承接
4. 找斷點：哪一步沒有 skill 或 skill 間銜接不上

**判定：**
- ✅ Workflow 可以完整跑通，每一步都有 skill 承接
- ⚠️ Workflow 大致可跑，但有 1-2 個弱銜接（skill 存在但接口不完整）
- ❌ Workflow 有斷點（某一步完全沒有 skill 承接，或關鍵銜接缺失）

**建議格式：**
```
E1 Workflow 跑通：⚠️
  典型成果：產出完整 domain gstack
  斷點：/domain-build → /skill-check 之間沒有自動觸發機制
  建議：在 /domain-build 的 completion section 加上 /skill-check pack 的觸發提示
```

---

### E2. 領域深度均衡

> 高深度 vs 低深度 skill 的比例是否健康。

**檢查方法：**
1. 對每個 skill 快速判斷深度層級：
   - **高深度**：有領域特化的 benchmarks、gotchas、scoring rubric、forcing questions
   - **中深度**：有部分領域特化，但核心邏輯偏通用
   - **低深度**：幾乎是 generic 邏輯套了領域名稱
2. 計算比例

**判定：**
- ✅ 高深度 ≥ 50%，無低深度
- ⚠️ 高深度 30-50%，或有 1-2 個低深度
- ❌ 高深度 < 30%，或低深度 ≥ 30%

**建議格式：**
```
E2 領域深度均衡：⚠️
  高深度（3）：/balance-review, /player-experience, /pitch-review
  中深度（2）：/game-review, /prism-routing
  低深度（1）：/source-convert
  比例：高 50% / 中 33% / 低 17%
  建議：/source-convert 需要補充領域特化邏輯
```

---

### E3. 前後銜接

> 每個 skill 的產出有被下游消費嗎？

**檢查方法：**
1. 列出每個 skill 的 output artifact
2. 檢查每個 artifact 是否被至少一個下游 skill 讀取
3. 找孤島 artifact（產出了但沒人用）和缺口（下游需要但沒人產出）

**判定：**
- ✅ 所有 artifact 都有下游消費者，所有下游需求都有上游供應
- ⚠️ 1-2 個孤島 artifact 或 1-2 個缺口
- ❌ ≥ 3 個孤島或缺口，artifact flow 基本是斷的

**建議格式：**
```
E3 前後銜接：⚠️
  孤島 artifact：/player-experience 的 journey-map.md（沒有下游讀取）
  缺口：/skill-edit 需要 review 結果但 /game-review 沒寫到檔案
  建議：
    - /game-review 加 artifact 輸出
    - /player-experience 的 journey-map 接入 /game-review 的 context 讀取
```

---

### E4. 差異化價值

> 跟通用 gstack 相比，這個 domain pack 的增量在哪？

**檢查方法：**
1. 假設用戶用通用 gstack（無 domain pack），列出能做到什麼
2. 對比有 domain pack 後多了什麼
3. 增量必須是「領域特化的判斷/知識/workflow」，不只是「多了幾個 skill 名稱」

**判定：**
- ✅ 增量明確：有領域特化的判斷邏輯、benchmarks、workflow 是通用 gstack 做不到的
- ⚠️ 部分增量：有些 skill 有領域特化，有些只是 generic 套皮
- ❌ 增量不明：大部分 skill 跟通用 gstack prompt 差不多

**建議格式：**
```
E4 差異化價值：✅
  通用 gstack 做不到的：
    - /balance-review 的 faucet/sink ratio 計算 + Gini coefficient 基準
    - /player-experience 的 persona-based walkthrough
    - /pitch-review 的 LTV/CPI 基準 + validation ladder
  只是套皮的：
    - （無）
```

---

### E5. Bridge Layer

> 設計 ≠ 實作時，有沒有轉譯層？

**檢查方法：**
1. 找出 pack 中「設計決策」到「實作執行」的接縫
2. 檢查接縫處有沒有 Bridge 類 skill 或 handoff 機制
3. 如果設計 skill 的輸出格式跟實作 skill 的輸入格式不匹配 → 缺 bridge

**判定：**
- ✅ 所有設計→實作的接縫都有 bridge 或格式匹配
- ⚠️ 大部分有，但 1-2 個接縫靠用戶手動轉譯
- ❌ 設計 skill 的輸出跟實作 skill 的輸入基本對不上

**建議格式：**
```
E5 Bridge Layer：⚠️
  有 bridge 的接縫：/domain-plan → /domain-build（plan 輸出 skill-map，build 讀取）
  缺 bridge 的接縫：/game-review 的 issue list → 沒有 skill 把 issue 轉成修改任務
  建議：/skill-edit 加 review-result 讀取邏輯，自動把 issue 轉成修改項
```

---

### E6. Substitution Test

> 把領域名稱換成「通用 web app」，pack 的後半段（judgment / scoring / output）還一樣嗎？

**檢查方法：**
1. 聚焦 pack 的後半段 skill（judgment、scoring、output 相關）
2. 心理替換：把所有領域術語換成通用術語
3. 如果後半段 skill 讀起來 85%+ 不變 → FAIL

**判定：**
- ✅ 後半段大量使用領域特化概念，替換後明顯不適用
- ⚠️ 混合：有些 skill 是領域特化的，有些替換後不變
- ❌ 後半段替換後基本不變，只是 generic 包裝

**建議格式：**
```
E6 Substitution Test：⚠️
  替換後改變的：/balance-review（faucet/sink 概念不適用於 web app）
  替換後不變的：/game-review 的後半段（建議太通用）
  建議：/game-review 的判斷邏輯補充 genre-specific scoring rubric
```

---

### E7. Production Artifact

> 後半段 skill 吃的是不是領域 runtime 的 evidence？

**檢查方法：**
1. 找出 pack 後半段 skill 的輸入來源
2. 檢查輸入是否來自領域 runtime 的真實 evidence（playtest data、analytics、user feedback、code metrics……）
3. 如果只吃設計文件（GDD、spec）而不吃 runtime evidence → 判斷會脫離現實

**判定：**
- ✅ 後半段 skill 有讀取 runtime evidence 的機制（analytics、test results、user data）
- ⚠️ 有部分讀取，但主要還是吃設計文件
- ❌ 完全只吃設計文件，沒有 runtime evidence 入口

**建議格式：**
```
E7 Production Artifact：⚠️
  有 runtime evidence 的：/balance-review（讀取 economy spreadsheet + playtest data）
  只吃設計文件的：/game-review（只讀 GDD）
  建議：/game-review 加 playtest observation / analytics dashboard 讀取入口
```

---

## Pack Health 報告模板

```
=== Pack Health Report: [pack 名稱] ===
評估日期：YYYY-MM-DD
Skill 數量：N

E1 Workflow 跑通:      ✅ / ⚠️ / ❌
E2 領域深度均衡:       ✅ / ⚠️ / ❌
E3 前後銜接:           ✅ / ⚠️ / ❌
E4 差異化價值:         ✅ / ⚠️ / ❌
E5 Bridge Layer:       ✅ / ⚠️ / ❌
E6 Substitution Test:  ✅ / ⚠️ / ❌
E7 Production Artifact: ✅ / ⚠️ / ❌

健康度：_/7 ✅，_/7 ⚠️，_/7 ❌

綜合判定：
  6-7 ✅ → 健康，可以開始使用
  4-5 ✅ + 其餘 ⚠️ → 大致健康，優先修 ⚠️ 項
  任何 ❌ → 有結構問題，必須先修 ❌ 項再使用
  ≥ 3 ❌ → 需要重新設計 pack 結構
```

---

## Builder 建議優先順序

修復優先順序（由高到低）：

1. **❌ 項** — 結構性問題，不修會影響整個 pack 的使用
2. **⚠️ E1 Workflow 跑通** — workflow 斷點直接影響用戶體驗
3. **⚠️ E3 前後銜接** — artifact 不通會造成信息孤島
4. **⚠️ E6 Substitution Test** — 通不過代表 pack 缺乏領域價值
5. **⚠️ E5 Bridge Layer** — 缺 bridge 增加用戶手動成本
6. **⚠️ E2/E4/E7** — 深度和差異化問題，迭代中逐步改善
