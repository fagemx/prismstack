# Skill Map 推導方法論

> 用途：/domain-plan 規劃 skill map 時使用。
> 語境：你正在幫用戶把他的工作領域變成一套 skill stack。

---

## Step 1: 推導工作生命週期

從用戶的領域推導 5-8 個工作階段。

方法：問「這個領域從開始到交付，經過哪些階段？」

❌ 不要用技術分類（frontend / backend / deploy）
✅ 用工作性質分類（研究 / 規劃 / 創作 / 審查 / 執行 / 分析）

範例：
- 影劇：構思 → 大綱 → 劇本 → 分鏡 → 拍攝 → 後製 → 上映
- 教育：需求分析 → 課程設計 → 教材製作 → 試教 → 修正 → 開課 → 評估

---

## Step 2: 對標 10 個通用姿態

任何領域都需要這 10 個工作姿態：

| # | 姿態 | 做什麼 |
|---|------|--------|
| 1 | **Ideator（發想者）** | 結構化想法、挑戰前提 |
| 2 | **Decision Maker（決策者）** | 決定方向、砍 scope、評估風險 |
| 3 | **Reviewer（審查者）** | 檢查產出品質 |
| 4 | **Tester（測試者）** | 系統性找問題 |
| 5 | **Shipper（發布者）** | 打包、提交、上線 |
| 6 | **Debugger（除錯者）** | 找根因、修問題 |
| 7 | **Retrospective（回顧者）** | 週期性反思和改善 |
| 8 | **Safety（安全守衛）** | 防止 AI 做破壞性操作 |
| 9 | **Docs（文件維護）** | 發布後更新文件 |
| 10 | **Second Opinion（第二意見）** | 獨立上下文的對抗性審查 |

把每個生命週期階段跟這 10 個對標。**沒對上的 = 候選 domain-specific skill。**

---

## Step 3: 3 缺口法

找 domain-specific skill 的 3 種方法：

### 審查缺口
問：通用 /review 抓不到什麼品質維度？
每個抓不到的維度 = 一個候選 skill。

### 工作流缺口
問：專業人士每天做什麼 AI 能幫但通用工具做不到的？
每個專業工作流 = 一個候選 skill。

### 交接缺口
問：哪些步驟之間最容易掉東西？
每個容易掉東西的交接 = 一個候選 bridge skill。

---

## Step 4: 3 獨立性測試

每個候選 skill 必須通過 3 個測試：

### 測試 1：獨立姿態
啟動這個 skill 會改變 agent 的思考方式嗎？
- ✅ 啟動後 agent 變成「數學家」，看數字不看感覺 → 獨立 skill
- ❌ 「檢查名稱拼寫」不改變思考方式 → 合併到其他 skill 的 section

### 測試 2：獨立產出
結束時會產出一個有獨立價值的 artifact 嗎？
- ✅ 產出 Health Score + 修改建議 → 獨立 artifact
- ❌ 「統計文件字數」不是獨立有價值的 artifact → 不是 skill

### 測試 3：獨立觸發
用戶會單獨說「我要做這件事」嗎？
- ✅ 「幫我審查這份設計」→ 用戶會單獨觸發 → 獨立 skill
- ❌ 「檢查 FTUE 是否超過 30 秒」→ 子步驟 → 不是 skill

**判定：**
- 3 個都過 → 獨立 skill
- 過 1-2 個 → 合併到相關 skill 的 section
- 0 個 → 不做

---

## Step 5: Merge vs Split

### 合併信號

| 情況 | 處理 |
|------|------|
| 兩個 skill 永遠一起跑 | 合併成一個 |
| 一個 skill 太小（< 100 行） | 合併到相關 skill 的 section |
| 觸發條件相同 | 合併（用 section 區分） |

### 拆分信號

| 情況 | 處理 |
|------|------|
| 需要不同的專業背景 | 拆成獨立 skill |
| 產出被不同下游消費 | 保持獨立 |
| 超過 500 行 | 拆出子 skill |
| 不同時間觸發 | 保持獨立 |

---

## Step 6: 5 類分類

每個 skill 標記類型：

| 類型 | 核心 | 範例 |
|------|------|------|
| **Review** | 判斷品質 | 設計審查、平衡審查、體驗走查 |
| **Bridge** | 轉譯與交接 | 格式轉換、來源匯入、spec 轉 plan |
| **Production** | 讓東西出現 | 內容生成、code 生成、素材批次產出 |
| **Control** | 編排與治理 | Routing skill、健康檢查、升級規劃 |
| **Runtime Helper** | 運行時依賴 | 外部工具串接、狀態管理、自動化腳本 |

### 健康比例檢查
- Review 不超過 40%（否則只審查不生產）
- 必須有足夠 Bridge（否則 skill 之間斷裂）
- 必須有 Production（否則只規劃不執行）
- 缺 Control → 用戶不知道用哪個 skill

---

## Step 7: 數量校準

| 領域規模 | Skill 數 | 判斷 |
|----------|---------|------|
| 小領域 | 8-12 | 精簡但可用 |
| 中領域 | 13-20 | 理想範圍 |
| 大領域 | 21-30 | 完整覆蓋 |
| 超過 30 | — | **強制合併**，回 Step 5 |

---

## Step 8: Artifact Flow 圖

每個 skill 的產出必須有消費者。畫出：

```
skill → artifact → consumer skill
```

驗證規則：
- ❌ 孤立 artifact（某 skill 產出沒人讀）→ 這個 skill 可能不需要
- ❌ 斷點（某 skill 找不到上游輸入）→ 缺 bridge skill
- ✅ 每條線都有 producer 和 consumer

範例：
```
/import → 標準文件
    ↓
/ideation → concept-*.md
    ↓
/direction → direction-*.md
    ↓
/domain-review → review-*.md → /balance-review, /experience, ...
    ↓
/qa → qa-report-*.md
    ↓
/ship → release
```

---

## 品質門檻

Skill Map Quality Score（5 維度，每項 0-2 分）：

| 維度 | 0 分 | 1 分 | 2 分 |
|------|------|------|------|
| **Coverage** | 生命週期有未覆蓋階段 | 大部分覆蓋 | 全部覆蓋 |
| **Type Balance** | 只有 Review 類 | 有 3 種以上但比例失衡 | 5 類比例健康 |
| **Independence** | 多數 skill 沒過 3 測試 | 部分沒過 | 全部通過 |
| **Bridge Layer** | 無 bridge skill | 有但不完整 | 所有交接都有 bridge |
| **Artifact Flow** | 有孤立 artifact 或斷點 | 大部分連通 | 完全連通 |

- **8-10 分** → 可搭建
- **5-7 分** → 需調整後再搭建
- **< 5 分** → 重新規劃

---

## 反模式

| 反模式 | 問題 | 修正 |
|--------|------|------|
| 一個 skill 做所有事 | agent 沒有姿態切換 | 拆成獨立姿態 |
| 每個功能一個 skill | 太碎，用戶不知道用哪個 | 用 3 獨立性測試合併 |
| 照名稱直接改名 | 領域缺口沒補到 | 先畫生命週期，再對標 |
| 先做完所有 skill 再測 | 不知道哪些有用 | Wave 制：先做 5 個核心 |
| 把知識做成 skill | 「百科全書」不是 skill | Skill 是工作姿態，知識放 references/ |
| 忽略入口 skill | 用戶素材進不了 pipeline | 入口 skill 是 gateway |

---

## Brownfield Mode（現有 Skill 整合）

> 場景：用戶已有散落的 skill、自動化腳本、或半成品 workflow，要整合成可管理的 stack。
> 與 Greenfield 的差異：不是從零推導，是從現有出發、補缺口、建連接。

### 偵測信號

以下任一成立 → 進入 brownfield mode：
- 目標目錄有 `skills/*/SKILL.md`（掃描到現有 skill）
- 用戶說「我有現有的 skill」「整合成 stack」「stack 化」「已經有一些 skill」
- 用戶指向一個已有 skill 的 repo/目錄

### BF Step 1: Skill 盤點（Inventory）

掃描目標目錄，對每個找到的 SKILL.md：

1. **讀取完整內容**
2. **分類**（Review / Bridge / Production / Control / Runtime Helper）
3. **完整度評估**（6 項檢查）：

| 檢查項 | 有 | 缺 |
|--------|----|----|
| Role lock（角色鎖定） | ✅ | 缺 role lock |
| Scoring / 品質判斷 | ✅ | 缺 scoring |
| Stop gates | ✅ | 缺 stop gate |
| Artifact flow（上下游） | ✅ | 缺 artifact flow |
| Gotchas / AI 盲點 | ✅ | 缺 gotchas |
| Anti-sycophancy | ✅ | 缺 anti-sycophancy |

4. **辨識隱含關係**：從 skill 內容推斷它的上游輸入和下游產出，即使沒有明確寫出 artifact flow
5. **掃描非 skill 資產**：自動化腳本（src/）、config 檔、工具程式碼 — 這些是潛在的 Runtime Helper 或 tool-builder 目標

產出：**Skill Inventory Table**

```
| # | Skill | 類型 | 完整度 | 隱含上游 | 隱含下游 | 適配判定 |
|---|-------|------|--------|---------|---------|---------|
| 1 | script-breakdown | Production | 4/6 | 腳本文字 | 分鏡文件 | 🔧 改造 |
| 2 | performance-direction | Production | 3/6 | 分鏡文件 | 帶表演的分鏡 | 🔧 改造 |
| 3 | explore-site | Runtime Helper | 2/6 | 網站 URL | plugin.js | 🔧 改造 |
| ... |
```

### BF Step 2: 適配分類

每個現有 skill 分三類：

| 分類 | 判斷標準 | 處理方式 |
|------|---------|---------|
| **✅ 直接用** | 完整度 5-6/6，有明確 artifact flow | 只加 wiring（discovery/save 路徑） |
| **🔧 改造** | 完整度 2-4/6，核心邏輯好但缺機制 | 保留核心邏輯，補缺少的機制 |
| **❌ 重寫** | 完整度 0-1/6，或職責不清、跟其他 skill 嚴重重疊 | 重新設計，但參考原有內容 |

**改造的具體意思**：不是重寫 skill，是在現有 SKILL.md 上追加：
- 缺 artifact flow → 加 Phase 0 discovery + 結尾 save
- 缺 scoring → 加 scoring formula
- 缺 stop gate → 在關鍵判斷點加 STOP
- 缺 gotchas → 從使用經驗或領域知識補
- 缺 anti-sycophancy → 加 forbidden phrases + forcing questions

### BF Step 3: 雙向生命週期推導

**Bottom-up（從現有 skill 反推）：**
1. 把盤點的 skill 按隱含的工作順序排列
2. 每個 skill 對應一個生命週期階段
3. 產出「現有覆蓋的生命週期」

**Top-down（從領域推導應有的）：**
1. 使用 Step 1 的標準方法推導完整生命週期
2. 對標 10 個通用姿態

**比對：**
```
應有：素材輸入 → 腳本拆解 → 表演設計 → 生成指令 → 批次生產 → 品質審查 → 迭代
現有：           腳本拆解 → 表演設計 → 生成指令
缺口：素材輸入 ←                              → 批次生產 → 品質審查 → 迭代
```

### BF Step 4: 差異分析

產出三張清單：

**1. 現有 skill 處理清單**
```
| Skill | 適配 | 需要補的機制 |
|-------|------|-------------|
| /script-breakdown | 🔧 | artifact flow, anti-sycophancy |
| /performance-direction | 🔧 | artifact flow, scoring |
```

**2. 缺口 skill 清單**
```
| Skill | 類型 | 為什麼需要 |
|-------|------|-----------|
| /extract-scripts | Bridge | Excel → 腳本文字，現有 skill 無法處理 |
| /video-produce | Control | triage entry，用戶不知道從哪開始 |
| /generate | Runtime Helper | 包裝自動化引擎 |
```

**3. 非 skill 資產處理建議**
```
| 資產 | 路徑 | 建議 |
|------|------|------|
| 自動化引擎 | src/ | 用 /tool-builder 包裝成 /generate skill |
| Excel 處理 | skills/xlsx/ | 當作通用工具，/extract-scripts 調用它 |
| 站點探索 | skills/explore-site/ | 保留為獨立工具 skill |
```

### BF Step 5: 回到標準流程

差異分析完成後，合併成完整 skill map（現有 + 缺口），然後回到標準的：
- Step 4: 獨立性測試（全部 skill，包含現有的）
- Step 5: Merge vs Split
- Step 6: 分類
- Step 7: 數量校準
- Step 8: Artifact Flow 圖

**注意**：標準流程中，每個 skill 多帶一個 `source` 標記：

```
| # | Skill | 類型 | Source |
|---|-------|------|--------|
| 1 | /extract-scripts | Bridge | 🆕 新增 |
| 2 | /script-breakdown | Production | 🔧 改造 |
| 3 | /shotgen | Production | 🔧 改造 |
| 4 | /generate | Runtime Helper | 🆕 新增（tool-builder） |
```

這個 `source` 標記會傳給 /domain-build，決定每個 skill 的建置方式。

---

## Brownfield 品質門檻

在標準的 5 維度品質門檻之外，brownfield mode 額外檢查：

| 維度 | 0 分 | 1 分 | 2 分 |
|------|------|------|------|
| **Inventory Accuracy** | 現有 skill 分類有誤 | 大部分正確 | 全部正確 |
| **Adaptation Scope** | 改造範圍不清 | 列出但不完整 | 每個 skill 有明確的改造清單 |

Brownfield 總分 = 標準 5 維度（10 分）+ 額外 2 維度（4 分）= 14 分滿分。
- **12-14** → 可搭建
- **8-11** → 需調整
- **< 8** → 重新盤點

---

## Brownfield 反模式

| 反模式 | 問題 | 修正 |
|--------|------|------|
| 全部重寫 | 浪費現有成果，用戶不認得自己的 skill | 優先改造，只有完整度 0-1 才重寫 |
| 只加 wiring 不補機制 | 串起來了但品質沒提升 | 改造必須補齊 scoring + stop gate |
| 忽略非 skill 資產 | 自動化腳本、工具沒整合進 stack | 掃描 src/、scripts/、config/，評估是否需要包裝 |
| 強制統一風格 | 現有 skill 的寫法被完全覆蓋 | 保留核心邏輯和術語，只補缺少的機制 |
| 照搬現有順序 | 現有順序可能有缺口 | 必須做雙向推導，不能只 bottom-up |
