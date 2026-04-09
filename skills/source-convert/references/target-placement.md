# Target Placement Model

來源落點判斷 — 來源轉換最關鍵的一步。

不是所有來源都該變成 skill。很多來源只值一條 gotcha 或一個 benchmark patch。
如果沒有這個判斷，builder 會「看什麼都想生成 skill」。

---

## 5 個落點層級

| Level | 落點 | 說明 | 範例 |
|-------|------|------|------|
| **1** | New skill | 來源包含完整的、獨立的工作姿態 | 用戶帶來一整套 playtest 方法 → 新建 /playtest |
| **2** | Skill section | 來源可以替換或新增某個 skill 的一整個 section | 一篇文章的經濟模型框架 → 替換 /balance-review Section 2 |
| **3** | Judgment patch | 零散但有價值的判斷碎片：gotcha、benchmark、forcing question | 一條實戰經驗 → 加進 /game-qa 的 gotchas |
| **4** | Workflow patch | 改變的不是 skill 內容，而是 skill 之間的串接 | 「review 完應該先過 balance 再過 player experience」→ 改 workflow 順序 |
| **5** | Reference asset | 有參考價值但不直接進 skill | 一本書的理論背景 → 放 references/，skill 需要時引用 |

---

## 判斷決策樹

依序問以下問題，第一個符合的就是落點：

```
Step 1: 獨立性三測試
  這個來源能通過「獨立姿態 + 獨立產出 + 獨立觸發」全部三項嗎？
  ├─ 三項全過 → Level 1（New skill）
  └─ 任一不過 → 繼續 Step 2

Step 2: Section 替換測試
  這個來源能替換或新增某個現有 skill 的完整 section 嗎？
  ├─ 能 → Level 2（Skill section）
  └─ 不能 → 繼續 Step 3

Step 3: 判斷規則測試
  這個來源包含具體的、可直接使用的判斷規則嗎？
  （gotcha、benchmark 數字、forcing question、scoring criteria）
  ├─ 有 → Level 3（Judgment patch）
  └─ 沒有 → 繼續 Step 4

Step 4: 關係變更測試
  這個來源改變的是 skill 之間的關係嗎？
  （觸發順序、上下游、routing 邏輯）
  ├─ 是 → Level 4（Workflow patch）
  └─ 不是 → Level 5（Reference asset）
```

---

## 獨立性三測試詳解（Level 1 判定用）

| 測試 | 問題 | PASS 標準 |
|------|------|----------|
| 姿態獨立 | 這個來源描述的工作模式跟現有所有 skill 都不同嗎？ | 不是任何現有 skill 的子集或變體 |
| 產出獨立 | 這個來源產出的 artifact 跟現有 skill 不重疊嗎？ | artifact 名稱和內容都不重複 |
| 觸發獨立 | 這個來源的觸發條件跟現有 skill 不衝突嗎？ | 用戶不會搞混「該用這個還是那個」 |

三項全 PASS → Level 1。
任一 FAIL → 這個來源不夠格當獨立 skill，往 Level 2-5 判斷。

---

## 各 Level 的執行路徑

### Level 1: New Skill
- Hand off to `/skill-gen`，帶上提取的內容作為輸入
- 提取內容包括：role identity、核心判斷邏輯、suggested phases、gotchas
- `/skill-gen` 負責建 SKILL.md + wiring

### Level 2: Skill Section
- Hand off to `/skill-edit`，指定目標 skill 和 section
- 提取內容包括：新 section 的完整內容（已翻譯成 gstack 格式）
- `/skill-edit` 負責替換/新增 section + 驗證一致性

### Level 3: Judgment Patch
- 直接透過 `/skill-edit` 插入
- 插入類型：
  - gotcha → 加到目標 skill 的 Gotchas section
  - benchmark → 加到目標 skill 的 scoring 或 references/
  - forcing question → 加到目標 skill 的 Anti-Sycophancy 或對應 phase
- 一次可能插入多個 skill

### Level 4: Workflow Patch
- Hand off to `/workflow-edit`（如果存在）
- 或直接修改 routing skill 和 skill-map.md
- 變更內容：觸發順序、上下游關係、routing 邏輯

### Level 5: Reference Asset
- 在目標 skill 的 `references/` 目錄建立新檔案
- 或在 `skills/shared/references/` 如果多個 skill 會用到
- 檔案格式：markdown，標注來源和用途
- 在相關 skill 的 SKILL.md 中加上引用路徑

---

## 跟用戶確認落點（AskUserQuestion 格式）

確認落點時，使用四段格式：

### 1. Re-ground
重新說明用戶帶來了什麼來源，以及目前分析的結果。

### 2. Simplify
用白話解釋這個落點的意思：
- Level 1：「這個內容夠完整，值得變成一個獨立的新 skill。」
- Level 2：「這個內容可以升級現有 skill 的某個部分。」
- Level 3：「這裡面有幾條很好的判斷規則，可以塞進現有 skill。」
- Level 4：「這個改變的是 skill 之間的串接方式，不是 skill 內容。」
- Level 5：「這個有參考價值，但不直接進 skill — 放在參考資料裡。」

### 3. Recommend
```
RECOMMENDATION: Level {N}（{落點名稱}），因為 {一句話原因}。
目標：{具體目標 skill 或位置}
```

### 4. Options
```
A. Level {N} — {落點}：{具體描述} (CC: ~X min)
B. Level {替代} — {替代落點}：{具體描述} (CC: ~Y min)
C. 用戶自己指定落點
D. 跳過，不轉換
```

---

## 常見誤判

| 誤判 | 正確判斷 |
|------|---------|
| 一篇好文章 → Level 1（新 skill） | 通常是 Level 2-3（section 或 patch） |
| 一個 gotcha → Level 2（section） | 通常是 Level 3（judgment patch） |
| 一本書 → Level 1（新 skill） | 通常是 Level 3 + Level 5（幾條規則 + 理論放 references） |
| 一個 prompt → Level 1（新 skill） | 先跑獨立性測試 — 很多 prompt 是現有 skill 的改進 |
| 用戶的想法 → Level 1（新 skill） | 先結構化再判斷 — 很多想法其實是 Level 3 |

**核心原則：** 不確定時，選較小的 level。Level 3 比 Level 1 安全。
過度生成 skill 比不夠生成更危險 — 多一個爛 skill 比少一條 gotcha 更糟。

### Level 5 特例：共享知識庫（shared/references/）

如果來源是 external codebase 或 API documentation，且**多個 skill 都需要引用**：
- 建立檔案在 `skills/shared/references/` 而不是單一 skill 的 `references/`
- 命名：`{tool-or-api}-{content-type}.md`
- 在所有引用此 reference 的 SKILL.md 中加上：
  `讀取 shared/references/{filename} — {tool} 整合細節`
- 更新 shared/ 目錄的索引（如果有的話）

**判斷標準：** 如果只有一個 skill 需要 → 放該 skill 的 `references/`。
如果兩個以上 skill 需要 → 放 `shared/references/`。
