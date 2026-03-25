# Skill Map 推導方法論

> 來源：gstack skill-orchestration-methodology
> 用途：/domain-plan Phase 1-3 的核心參考

---

## 八步推導流程

### Step 1：從領域名稱推導工作生命週期（5-8 stages）

每個領域都有一個「作品從無到有」的生命週期。找出它。

範例：
- **遊戲**：概念 → 設計 → 原型 → 製作 → 測試 → 打磨 → 發布 → 營運
- **影劇**：構思 → 劇本 → 前製 → 拍攝 → 後製 → 發行
- **教育**：需求分析 → 課程設計 → 內容製作 → 試教 → 迭代 → 發布
- **行銷**：市場研究 → 策略 → 創意 → 製作 → 投放 → 分析 → 迭代

如果用戶的領域你不熟，直接問：「你的工作從頭到尾，大概經過哪些階段？」

### Step 2：對標通用姿態

gstack 有 10 個通用工作姿態（任何領域都需要）：

| # | 姿態 | 做什麼 | 必選？ |
|---|------|--------|--------|
| 1 | **Ideator** | 結構化想法、挑戰前提 | 必選 |
| 2 | **Decision Maker** | 決定方向、砍 scope、評估風險 | 必選 |
| 3 | **Reviewer** | 檢查產出品質 | 必選 |
| 4 | **Tester** | 系統性找問題 | 必選 |
| 5 | **Shipper** | 打包、提交、上線 | 必選 |
| 6 | **Debugger** | 找根因、修問題 | 必選 |
| 7 | **Retrospective** | 週期性反思 | 必選 |
| 8 | **Safety** | 防止破壞性操作 | 幾乎必選 |
| 9 | **Docs** | 發布後更新文件 | 幾乎必選 |
| 10 | **Second Opinion** | 獨立上下文對抗性審查 | 幾乎必選 |

這 10 個從 gstack 直接遷移，改領域詞彙就能用。

### Step 3：判斷規劃視角數量

三個可能的規劃視角：

| 視角 | 看什麼 | 何時需要 |
|------|--------|---------|
| **策略** | 該不該做？方向對嗎？ | 有商業決策時 |
| **設計** | 使用者體驗好嗎？ | 有觀眾/讀者/用戶時 |
| **工程** | 架構對嗎？技術可行嗎？ | 有技術實作時 |

不是每個領域都需要三個。小說可能只需要策略+設計。

### Step 4：三個缺口法找領域專屬 skill

這是最關鍵的一步。三種方法交叉使用：

#### 4a. 審查缺口

問：通用 /review 抓不到的品質維度有哪些？

每個抓不到的維度 = 一個潛在的領域專屬 review skill。

範例推導（遊戲）：
| 品質維度 | 通用 /review 能抓？ | 結果 |
|---------|-------------------|------|
| Code 品質 | 能 | 不需要新 skill |
| GDD 設計品質 | 不能 | → /game-review |
| 數值平衡 | 不能（需 Sink/Faucet 模型） | → /balance-review |
| 玩家體驗 | 不能（需 persona 模擬） | → /player-experience |

#### 4b. 工作流缺口

問：這個領域的專業人士日常做什麼，AI 能幫但通用工具做不到？

範例（影劇）：
- 編劇做「劇本修改」→ /script-revision
- 導演做「分鏡規劃」→ /storyboard-review
- 製片做「預算控制」→ /budget-review

#### 4c. 交接缺口

問：步驟之間最容易掉東西的交接在哪？

每個容易掉東西的交接 = 一個潛在的 bridge skill。

範例（遊戲）：
- 外部文件 → repo 格式 → /game-import
- 概念 → 設計文件 → /game-ideation
- 設計 → 實作 → /game-eng-review

### Step 5：判斷入口 skill

問：用戶有沒有「外部素材需要先匯入」？

| 領域 | 外部素材 | 入口 skill |
|------|---------|-----------|
| 遊戲 | PDF 企劃書、Notion 筆記 | /game-import |
| 影劇 | Word 劇本、Final Draft | /script-import |
| 教育 | PPT 課程大綱 | /course-import |

入口 skill 標準功能：偵測 → 讀取 → 轉換 → completeness audit → 寫入 → 推薦下一步。

如果領域素材已經是純文字且無特殊格式 → 可能不需要入口 skill。

### Step 6：獨立性測試

每個候選 skill 必須通過三個獨立性測試：

| 測試 | 問法 | 不通過怎麼辦 |
|------|------|-------------|
| **獨立姿態** | 執行這個 skill 時，agent 的工作姿勢跟其他 skill 不同嗎？ | 合併到姿勢相同的 skill |
| **獨立產出** | 這個 skill 產出的 artifact 跟其他 skill 不同嗎？ | 合併到產出相同的 skill |
| **獨立觸發** | 用戶會單獨觸發這個 skill 嗎？還是它總是跟某個 skill 一起跑？ | 如果總是一起 → 合併 |

三個都過 → 獨立 skill。
有一個不過 → 可能是某 skill 的 section。
兩個以上不過 → 一定要合併。

### Step 7：數量檢查

目標：10-25 個 skill。

- **< 10**：可能分得不夠細。檢查 Step 4 是否跳過了某些缺口。
- **10-25**：正常範圍。
- **> 25**：太多。用 Merge 啟發法合併。

### Step 8：畫 artifact 流向

用 references/artifact-flow-template.md 的格式，畫出 skill 之間的 artifact 傳遞關係。

每個 artifact 必須有至少一個 consumer。沒有 consumer 的 artifact = 沒人用的產出 = 浪費。

---

## Merge vs Split 啟發法

### 合併（Merge）條件

- 總是一起執行（沒有人單獨觸發其中一個）
- 太薄（SKILL.md < 100 行）
- 觸發條件相同（用戶說同一句話可以觸發兩個）
- 產出格式完全一樣

### 拆分（Split）條件

- 需要不同專業知識（經濟平衡 vs 玩家心理）
- 下游消費者不同（A 的產出給工程、B 的產出給設計）
- SKILL.md > 500 行
- 執行時機不同（設計階段 vs 測試階段）

---

## 領域範例（概要）

**遊戲開發 (~22 skills)**
通用 10 + 規劃 3 + 入口 1 + 領域專屬 8（game-review, balance-review, player-experience, pitch-review, asset-review, playtest, game-ideation, game-direction）

**影劇製作 (~18 skills)**
通用 10 + 規劃 2 + 入口 1 + 領域專屬 5（script-review, character-review, visual-review, audience-experience, budget-review）

**教育 (~16 skills)**
通用 10 + 規劃 2 + 入口 1 + 領域專屬 3（learning-design, course-review, assessment-review）

**行銷 (~31 skills)**
通用 10 + 規劃 3 + 入口 2 + 領域專屬 16（market-research, campaign-strategy, ad-layout, copy-review, brand-review, funnel-review, channel-review, competitor-analysis, content-calendar, creative-brief, media-plan, ab-test, analytics-review, social-review, seo-review, email-review）
— 注意：行銷的 31 個偏多，可考慮合併 channel-review + social-review + email-review → /channel-review。
