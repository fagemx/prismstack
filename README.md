# Prismstack

**把你的專業知識變成一套 AI skill 系統**

[English](README.en.md)

你是行銷專家、教育工作者、遊戲設計師、或任何領域的專業人士。你有自己的工作流程、判斷標準、品質門檻。Prismstack 幫你把這些變成一套可運行、可共享、可持續改進的 AI skill 系統。

一束光（你的專業知識）進去，分散成多色（可操作的 AI skill）出來。

> **這是什麼：** 你的知識和流程的結構化——變成 AI 能遵循的工作系統，帶有品質評分、修復迴圈、和防止 AI 敷衍的機制。
> **這不是什麼：** 通用 AI 工具合集——它生成的是*你的領域*的專屬 skill，不是萬用模板。

**適合誰用：**
- **有工作流程的團隊** — 把「每個人各自用 AI」升級成「團隊共用一套 AI 工作系統」
- **領域專家** — 你的三句話裡有完整的評分公式和判斷標準，Prismstack 聽得懂、轉得出
- **想讓 AI 照自己的方式工作的人** — 不是通用建議，是你的實際流程

---

## 快速開始：10 分鐘上手

1. 安裝 Prismstack（30 秒，見下方）
2. 執行 `/prismstack` — 自動偵測你的專案狀態，引導你下一步
3. 告訴它你的領域：「我做行銷」或者直接給一份詳細 spec — 都可以
4. 選擇**互動模式**（一步一步帶你走）或**自動模式**（自動跑完 Plan → Build → Check → Fix）
5. 你會拿到一個完整的領域 skill repo，附帶 install.sh，馬上能用

---

## 安裝 — 30 秒

**前置需求：** [Claude Code](https://docs.anthropic.com/en/docs/claude-code)、[Git](https://git-scm.com/)

### 方式 A：貼給 Claude（推薦）

打開 Claude Code，貼上這段：

> 安裝 Prismstack：執行 **`git clone https://github.com/fagemx/prismstack.git ~/.claude/skills/prismstack`**，然後告訴用戶 Prismstack 準備好了 — 執行 `/prismstack` 開始。

### 方式 B：安裝到專案裡

```bash
git clone https://github.com/fagemx/prismstack.git
cd prismstack
bash bin/install.sh --project    # 安裝到目前專案的 .claude/skills/
```

所有子 skill（`/domain-plan`、`/skill-check` 等）都可以獨立呼叫。

### 方式 C：全域安裝

```bash
bash bin/install.sh --global     # 安裝到 ~/.claude/skills/
```

只有 `/prismstack` 可以直接呼叫，子 skill 透過 triage 載入。

---

## 看它怎麼運作

### 互動模式 — 一步一步

```
你：    /prismstack

Claude: 正在偵測專案狀態...
        狀態：BLANK — 沒有找到 domain stack。

        你想怎麼建？
        A) 互動模式 — 我帶你一步一步走
        B) 自動模式 — 告訴我領域，我自動跑完

你：    A

Claude: 你的領域是什麼？

你：    行銷，主要做社群廣告素材

Claude: 我推導了工作生命週期：
        策略 → 發想 → 規格 → 生產 → 審查 → 投放 → 分析

        18 個 skill 規劃好了：

        | # | Skill | 類型 | 層級 |
        |---|-------|------|------|
        | 1 | /market-research | Review | 策略 |
        | 2 | /campaign-strategy | Bridge | 策略 |
        | ... | ... | ... | ... |

        Skill Map 品質分數：8/10

        A) 這樣可以，開始搭建
        B) 我要加 skill
        C) 我要改

你：    A

Claude: 開始搭建...（每 5 個 skill 停一次確認）
        → 18 個 skill 生成完成
        → validate-repo.sh：5/5 通過
        → 要安裝到你的專案嗎？

你：    好

Claude: ✅ 安裝完成。試試 /market-research 或 /campaign-strategy。
```

### 自動模式 — 一個指令搞定

```
你：    /prismstack

Claude: 狀態：BLANK

        你想怎麼建？
        A) 互動模式
        B) 自動模式

你：    B

Claude: 領域？
你：    教育課程設計

Claude: 品質門檻？
        A) Draft（12/30）— 最快
        B) Usable（18/30）— 推薦
        C) Production（24/30）— 最慢

你：    B

Claude: 開始自動搭建。你可以去做別的事。

        ⏳ 規劃中... 16 個 skill 已規劃
        ⏳ 搭建中... 16 個 skill 已生成
        ⏳ 審查中... 平均 15/30（Draft+）— 未達門檻
        ⏳ 修復第 1 輪... 12 項自動修復
        ⏳ 重新審查... 平均 19/30（Usable）✅

        ✅ 完成。
        Skill 數量：16 | 品質：19/30（Usable）| 修復輪數：1
        Repo：./education-stack/
        安裝：cd education-stack && bash bin/install.sh --project
```

---

## 工作流程

Prismstack 是一套流程，不是一堆工具。Skill 按照 domain stack 的搭建順序排列：

**提取 → 規劃 → 搭建 → 審查 → 修復 → 迭代**

每個 skill 的產出是下一個的輸入。`/methodology-extract` 把你的專業提煉成方法論。`/domain-plan` 用它來規劃 skill map。`/domain-build` 生成 skill。`/skill-check` 審查品質。低分觸發修復迴圈。所有產出存到 `~/.prismstack/projects/`，下游 skill 自動找到——即使跨 session。

| Skill | 你的專家 | 做什麼 |
|-------|---------|--------|
| `/prismstack` | **導航員** | 偵測專案狀態（BLANK / PLANNED / BUILT / ITERATING），引導你到對的 skill。支援互動和自動模式。 |
| `/methodology-extract` | **方法論蒸餾師** | 帶著你的問題看任何材料，提取對你有用的方法論。碰撞式互動：你的直覺 × 任何來源 = 結構化原則。不是問卷，是思維碰撞。 |
| `/domain-plan` | **領域架構師** | 從你的領域推導 skill map：生命週期、缺口分析、獨立性測試。如果有方法論會自動參考。 |
| `/domain-build` | **堆疊建造者** | 自動生成完整的領域 repo：骨架、所有 skill、install.sh、artifact flow 串接。執行驗收檢查。 |
| `/skill-check` | **品質檢查員** | 三種模式：`design`（7 問規劃檢查）、`review`（15 維度 + 6 雷區）、`pack`（結構健康度）。支援批量模式 `--all`。內建修復迴圈。 |
| `/skill-gen` | **技能工匠** | 在現有 stack 中新增單一 skill。獨立性測試 + 7 問設計檢查 + 串接到 workflow。 |
| `/skill-edit` | **技能外科醫生** | 編輯 skill 內部：gotcha、評分公式、逼問、反敷衍。提供修改前後的分數差異。 |
| `/source-convert` | **知識翻譯者** | 把特定來源（文章、影片、書、repo、prompt、SOP）轉成 skill 內容。5 級落點判斷。 |
| `/tool-builder` | **工具匠** | 打造自動化 skill：瀏覽器、API、CLI、檔案處理。雙層模式：直接做 + 產出能做的 skill。 |
| `/domain-upgrade` | **堆疊管家** | 持續改進：傾聽需求、收集測試回饋、派遣到對的 skill。三種模式：回饋 / 升級 / 傾聽。 |
| `/workflow-edit` | **工作流架構師** | 查看和編輯 artifact flow、skill 串接、workflow 圖。驗證：無孤立、無循環、bridge 覆蓋。 |
| `/super-guide` | **實戰教練** | 不知道下一步？卡關？想理解原理？教練用你自己的 stack 當教材，帶你做中學。三模式：情境教學 / 問答 / 診斷。 |

---

## 為什麼不直接寫 prompt？

你可以寫一個好的 prompt。但你的團隊有 5 個人，每個人寫不同的 prompt，品質不一致。有人離職了，prompt 就沒了。

Prismstack 把你的專業變成**可管理的系統**：

| | 散落的 prompt | Prismstack skill |
|---|---|---|
| **歸屬** | 在個人腦裡，人走就沒了 | 裝在團隊共享目錄，任何人都能用 |
| **品質** | 靠感覺（「看起來不錯」） | 有評分公式、有維度、有證據 |
| **AI 態度** | AI 什麼都說好 | 禁止空洞讚美 + 逼問 + 追問 |
| **流程** | 一口氣跑完 | 每個判斷點停下來問你 |
| **串接** | 各做各的 | 上一步的產出自動進下一步 |
| **改進** | 下次又從零開始 | 記得你說過什麼，越用越準 |
| **出錯** | 不知道哪裡壞 | 自動偵測 → 分類 → 修復 → 驗證 |

---

## 背後的方法論

Prismstack 有 9 份內建方法論，教 AI 怎麼幫你建好 skill：

**搭建骨架（教怎麼建）：**

| 方法論 | 解決什麼問題 |
|--------|-------------|
| **Skill Map 推導法** | 怎麼從你的工作流程推導出需要哪些 skill |
| **Skill 撰寫指南** | 怎麼寫出好的 skill：10 原則 + 7 結構模式 + 5 template（各帶 smart defaults 推導規則） |
| **串接指南** | 怎麼讓 skill 之間自動傳遞資料 + 6 種 pipeline 組合模式（Sequential / Fan-Out / Fan-In / Review Loop / Gateway / Feedback Injection） |
| **迭代改進迴圈** | skill 內部的反覆改進：8 phase 迴圈（Review → Ideate → Modify → Snapshot → Verify → Guard → Decide → Log） |

**品質保障（教怎麼改善）：**

| 方法論 | 解決什麼問題 |
|--------|-------------|
| **品質標準** | 怎麼判斷 skill 好不好：15 維度 + 校準基準 + 6 個常見陷阱 |
| **修復迴圈** | 發現問題怎麼修：偵測 → 分類 → 修 → Guard Check → 驗證 → 對比 |
| **功能測試指南** | 用真實任務測試 skill：9 步測試迴圈 + 8 維度壓力測試矩陣（成熟 stack 進階用） |

**系統自動化（教怎麼自動跑）：**

| 方法論 | 解決什麼問題 |
|--------|-------------|
| **自動決策指南** | 自動模式的 6 條決策原則 + 3 種決策分類（Mechanical / Taste / User Required） |
| **脈絡累積指南** | 跨 session 記住用戶的專業判斷：5 種信號 + confidence 衰減 + 啟動時自動注入 |

Skill 撰寫指南的 10 原則包含：Trigger 先寫、姿態切換、Flow 外化、Gotchas 最高價值、脆弱處嚴格、主檔+references 拆分、Recovery 定義、Output 可讀、壓力測試（Production 級）、辯論式生成。

---

## 技術背景

Prismstack 的工程方法論源自 [gstack](https://github.com/garrytan/gstack)（Garry Tan 的 AI 工程工作流），經過完整消化重寫，適配「幫用戶建 skill」的情境。不需要安裝 gstack。

**核心差異：**
- gstack = 固定 25 個 Web/SaaS 工程 skill
- Prismstack = 12 個 builder skill（含實戰教練），能為任何領域生成 10-50 個專屬 skill

**Prismstack 獨有的能力：**
- 方法論提取（帶著你的問題看任何材料，碰撞出結構化原則）
- 雙模式（互動 + 自動，生成者與評判者分離）
- 輸入敏感度（你給一句話或一份 spec，品質對等生成）
- 脈絡累積（記得你說過什麼，跨 session 越用越準，confidence 衰減防止過時資訊）
- 工具打造（雙層：直接自動化 + 產出能自動化的 skill）
- 辯論式生成（Author-A → Critic → Author-B → 合成，用辯論產出更好的 skill 內容）
- Smart Defaults（從領域信號自動推導 scoring 權重、gotchas、role identity，減少用戶需要填的東西）
- Pipeline 模式庫（6 種組合模式 + 選擇指南，教你怎麼串出有效的 workflow）
- 自動模式升級（State Machine + 回退機制 + 6 條決策原則 + 審批門）

---

## 怎麼運作的

### 一個 skill 裡面有什麼

每個 Prismstack 產出的 skill 不是一段 prompt，是一個完整的工作節點：

```
你的 /ad-check skill（素材品檢）裡面有：

角色鎖定     →  「你是廣告品檢員，不是 helper」
觸發條件     →  什麼時候用、什麼時候不用、跟哪些 skill 相鄰
評分公式     →  構圖 25% / 品牌一致 20% / CTA 20% / 色彩 15% / ...
停頓點       →  每個審查維度結束後停下來問你
反敷衍機制   →  禁止說「整體不錯」，必須逐維度打分附證據
AI 盲點      →  「Claude 容易忽略文字被角色遮擋」+ 怎麼防止
逼問         →  「這個 CTA 縮到手機螢幕大小還看得到嗎？」
修復迴圈     →  發現問題 → 自動分類 → 能修的直接修 → 重新打分 → 對比
上下游       →  自動找到 /ad-layout 的產出，做完推薦 /compliance-review
```

### Skill 之間怎麼串接

```
/brief-intake 產出 brief-001.md
    ↓ 自動存到共享目錄
/creative-direction 啟動時自動找到這份 brief
    ↓ 審查完產出 direction-001.md
/production-plan 啟動時自動找到審查結果
    ↓ 拆成任務，產出 task-batch-001.md
/ad-layout 啟動時自動找到任務清單
    ↓ ...一路串到投放
```

你不需要手動告訴 AI「去讀那個檔案」。每個 skill 知道去哪裡找上游的產出。

### 品質怎麼保證

```
生成 skill 後自動審查（15 個維度，0-2 分）：

入口層：觸發描述清楚嗎？角色鎖定了嗎？入口路由有嗎？
流程層：進度有追蹤嗎？有停頓點嗎？中斷能恢復嗎？
知識層：有 AI 盲點嗎？有評分公式嗎？有參考基準嗎？
結構層：檔案拆分合理嗎？有輔助腳本嗎？有狀態記憶嗎？
系統層：能找到上游嗎？產出格式對嗎？知道下一步是什麼嗎？

低於門檻 → 自動進修復迴圈：
  1. 記錄修復前分數
  2. 分類問題（能自動修 / 需要問你 / 需要重新設計）
  3. 自動修能修的
  4. 重新打分
  5. 報告差異（修復前 17 分 → 修復後 23 分）
```

### 你的知識怎麼進入 skill

```
你說：「審素材要看構圖、品牌一致、CTA，其他不重要」

Prismstack 聽到的：
  → 3 個評分維度（構圖、品牌一致、CTA）
  → 權重暗示（「其他不重要」= 這三個佔高權重）
  → 自動生成：構圖 25% / 品牌一致 20% / CTA 20% / 其他 35%
  → 問你確認（不是問你要什麼維度，是給你解讀讓你修正）

你給一句話 → 產出 Draft 品質（12-15/30）
你給專業筆記 → 產出 Usable 品質（18-22/30）
你給完整 spec → 產出 Production 品質（24-28/30）

輸入品質 = 輸出品質。不浪費你的專業，也不假裝一句話能產出完美結果。
```

---

## 疑難排解

**Skill 沒出現？** 在專案根目錄執行 `bash bin/install.sh --project`，重啟 Claude Code。

**只有 `/prismstack` 能用，子 skill 不行？** 你用的是全域安裝。子 skill 透過 `/prismstack` triage 使用，或改用 `--project` 安裝。

**Windows？** 用 Git Bash 或 WSL。或用 `pwsh bin/install.ps1 --project`。

**測試安裝：** `bash test/install-test.sh` — 應顯示 72/72 通過。

---

## 授權

MIT — 見 [LICENSE](LICENSE)。
