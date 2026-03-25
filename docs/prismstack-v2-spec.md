# Prismstack v2.2 — Domain Stack 搭建工具

> 前身：v0 regime spec, builder1.md, v1 spec
> v2 核心修正：builder 的首要任務是「搭出可用的 gstack」，不是「提取用戶經驗」。
> v2.1 補充：builder 是持續服務的工具，不只搭一次。包含一組來源轉換能力，幫用戶把各種東西變成 skill。
> v2.2 補充：確立 builder 自身的 10-skill 架構、tool-building 能力、三波建造順序、品質標準整合。
> 大模型本身就能產出可用 skill。用戶的角色是規劃 skill map，不是填 skill 細節。

---

## 設計原則（按優先級）

### P1：最少人工，搭出來就能跑

gstack 遷移到新領域不需要用戶提供任何材料。大模型對大部分領域有足夠知識產出可用的 skill。builder 的首要任務是把完整的 domain gstack 搭建出來，能跑就行。skill 數量不固定，由領域和用戶需求決定（通常 10-25 個，小領域可能更少）。

用戶只需要回答：
- 你的領域是什麼
- 工作流程長什麼樣
- 這些 skill 的規劃你同不同意

細節由 builder + 大模型自己產出。

### P2：有好東西就替換進去

用戶如果有外部 skill、第三方方法、資料源、框架，可以替換進對應的 skill 位置。這是**升級**，不是必要條件。沒有也完全能跑。

替換的東西不一定是用戶自己的經驗。可以是：
- 別人寫的 skill
- 公開的方法論
- 第三方工具的 prompt
- 任何能提升某個 skill 品質的東西

### P3：協助，不是逼問

builder 不做「經驗訪談」。不逼用戶提取隱性知識。

如果用戶想提供經驗，builder 協助他把經驗變成 skill 能用的形式。
如果用戶不想或不能，跳過，大模型補。

### P4：用戶決策在 skill map 層級

用戶最重要的決策是：「這些 skill 各放什麼」。

不是 skill 的 gotchas 怎麼寫、scoring 公式怎麼算、forcing questions 是什麼。那些是 builder 和用戶**一起做**的，而且大部分情況下 builder 自己就能做出夠用的版本。

用戶缺某個 skill 的知識？builder 幫他想辦法：
- 大模型直接產出（大部分情況夠用）
- 推薦外部資源
- 引導用戶描述他知道的部分

### P5：Builder 是持續服務，不是一次性工具

搭完之後 builder 不消失。它持續：
- 傾聽用戶的需求（用戶說「我想加 X」→ builder 幫他釐清真正需要什麼）
- 把各種來源轉成 skill（用戶說「這個 YouTube 的方法很好」→ builder 轉成 skill）
- 迭代改進（用戶說「這個 skill 不好用」→ builder 幫他改）

Builder 自己也是一組 skill，其中一部分專門做「來源 → skill」的轉換。

### P6：永遠帶著編排視角，但不強制

Builder 在任何互動中都帶著「這個 skill 在整個 workflow 裡扮演什麼角色」的視角。

用戶加 skill、改 skill、刪 skill 時，builder 會主動說：

```
「這個 skill 加在這裡的話，它的上游是 /ideation 的產出，
 下游可以接 /eng-review。你的 workflow 會變成這樣：
 /ideation → [新 skill] → /eng-review → build → ...
 這樣串得起來。」
```

或者：

```
「你要加的這個 skill 跟現有 workflow 沒有直接關聯。
 它可以獨立存在，但不會被其他 skill 自動觸發或消費。
 這沒問題，只是讓你知道。」
```

**這是建議，不是限制。** Builder 要做的不是判斷「這個該不該放」，而是**理解用戶為什麼想放**，然後幫他放得更好。

主軸永遠是：**讓工作可以用。**

例如用戶在行銷 stack 裡放一個做菜的 skill。Builder 不應該說「這跟行銷無關」。Builder 應該先想：這個行銷可能就是料理相關的——食品品牌、料理內容創作、食譜行銷。

然後 builder 會說：

```
「你的行銷 stack 加一個做菜 skill——
 我猜你的行銷方向跟料理有關？

 如果是的話，我建議這樣接：
   /content-ideation → /recipe-creation → /content-review
 讓食譜變成內容 pipeline 的一環，
 這樣 /content-review 可以直接消費它的產出。

 或者你有別的用法？告訴我，我來想怎麼接最順。」
```

**Builder 的價值不是當門衛說「這不相關」，而是看出用戶的工作脈絡，幫他把任何 skill 接到最有用的位置。** 用戶比 builder 更懂自己的工作。builder 比用戶更懂 workflow 怎麼串。兩邊合作。

**核心原則：builder 帶著全局 workflow 視角，理解用戶的意圖，提供最好的規劃方案。決定權永遠在用戶。**

這個視角貫穿所有步驟：
- Step 1（Plan）：規劃 skill map 時就帶著 workflow 流向
- Step 3（Upgrade）：每次改動都告訴用戶對 workflow 的影響
- Step 5（Iterate）：持續優化時提醒 workflow 的整體健康度

### P7：警惕前深後淺（Review-Production Asymmetry）

領域 gstack 最常見的結構風險：**前半段（企劃/審查/規劃）已經高度領域化，後半段（實作/驗證/發布）仍停留在 generic software delivery。**

這不是品質問題，是結構問題。成因：
- gstack 原版本身是「審查工作流」，不是「生產工作流」
- 前半段容易接上領域理論（MDA、SDT、三幕結構、Bloom's taxonomy...）
- 後半段容易直接沿用 gstack 原版的 code review / QA / ship 框架
- 設計 artifact 跟實作 artifact 不同，中間缺少轉譯層（bridge layer）

Builder 必須在三個時間點主動檢查這個問題：
1. **Step 1（Map）**：規劃 skill map 時就檢查有沒有 bridge layer
2. **Step 2（Build）完成後**：pack 健康度報告裡標記前後深度差異
3. **Step 3（Upgrade）**：用戶升級前半段時提醒「後半段也需要跟上」

**原則：domain gstack 不能只是一套「用領域語言做審查」的系統。它要逐步進入該領域的生產語言——用領域的工作單位、領域的 runtime evidence、領域的產出 artifact 來工作。**

---

## One-line Definition

**Prismstack 是一個持續服務的搭建工具：快速遷移出完整 domain gstack，然後傾聽用戶需求，把任何來源（skill repo、影片、文章、想法、經驗）轉成 skill，持續迭代直到用戶滿意。**

---

## Builder 自身的 Skill Map（10 個）

Prismstack 本身是一組 gstack skills，安裝在 `~/.claude/skills/prismstack/`。

### 完整 Skill 清單

| # | Skill | 類型 | 工作姿態 | 說明 |
|---|-------|------|----------|------|
| 1 | `/domain-plan` | Bridge | 規劃者 | 推導 skill map + workflow + artifact flow，用戶確認 |
| 2 | `/domain-build` | Production | 搭建者 | 自動搭建完整 domain gstack repo（scaffold + 所有 skill + mechanisms） |
| 3 | `/prism-routing` | Control | 導航者 | Builder 的 routing skill，引導用戶到正確的 builder skill |
| 4 | `/skill-check` | Review | 審查者 | 3 mode：design（規劃階段 7 問）/ review（完成後 15 維 + 6 雷區，支援 `--all` 批量 + cross-skill 分析）/ pack（結構健康度 7 項評估） |
| 5 | `/skill-gen` | Production | 建造者 | 新增單一 domain skill（review / bridge / production / control 類） |
| 6 | `/skill-edit` | Bridge | 編輯者 | 編輯 skill 內部：gotchas / scoring / forcing Qs / references / anti-sycophancy |
| 7 | `/source-convert` | Bridge | 轉譯者 | 來源轉換：repo / prompt / 影片 / 文章 / 書 / SOP / 想法 → skill 或 skill 片段 |
| 8 | `/tool-builder` | Production | 工具匠 | 打造工具型 skill（雙層：自己做 + 產出能做的 skill）：browser automation / API 串接 / CLI 工具 / 檔案處理 / 任何操作流程 |
| 9 | `/domain-upgrade` | Bridge | 迭代者 | 升級流程：傾聽需求 + 測試回饋 + 持續迭代 |
| 10 | `/workflow-edit` | Control | 編排者 | 查看/編輯 artifact flow + skill 串接 + workflow graph |

### Skill 之間的關係

```
用戶說「我做 X 領域」
  → /domain-plan（推導 skill map）
  → /domain-build（搭建完整 repo）
  → /skill-check pack（健康度報告）

用戶說「我要加一個 skill」
  → /skill-gen（domain skill）或 /tool-builder（工具型 skill）
  → /skill-check design（設計檢查）
  → /workflow-edit（接進 workflow）

用戶說「這個 skill 要改」
  → /skill-edit（直接改內部）
  → /skill-check review（品質驗證）

用戶說「這篇文章的方法很好」
  → /source-convert（來源轉換）
  → /skill-edit 或 /skill-gen（落點執行）

用戶說「整體要升級」
  → /domain-upgrade（傾聽 + 測試 + 迭代）

用戶不知道用哪個
  → /prism-routing
```

### 建造順序（三波）

```
Wave 1（最小可用循環）：
  /domain-plan → /domain-build → /prism-routing
  驗收：輸入領域描述 → 產出 skill map → 產出完整可運行 repo

Wave 2（品質工具）：
  /skill-check → /skill-gen → /skill-edit
  驗收：能檢查品質、新增單一 skill、修改 skill 內部

Wave 3（持續服務）：
  /source-convert → /tool-builder → /domain-upgrade → /workflow-edit
  驗收：能轉換外部來源、打造工具型 skill、升級迭代、編輯 workflow
```

### 每個 Builder Skill 遵守的品質標準

Builder 自身的 skill 遵守 gstack 完整品質體系（來自 skill-quality-rubric、skill-writing-doctrine、skill-writing-patterns）：

```
結構：
  - SKILL.md ~150 行（skeleton）+ references/（details）
  - Progressive disclosure：主檔只放 flow/rules，細節在 references/

Entry Layer：
  - Trigger description：when to use + when NOT to use + adjacent skills
  - 單一角色身份：一句話鎖定工作人格
  - Mode routing：入口立刻鎖定路徑

Flow Layer：
  - Flow 外化：TodoWrite / driver script / status table（不靠 Claude 記憶）
  - STOP gates：每個 section 結束都停
  - Recovery：中斷恢復程序

Knowledge Layer：
  - Gotchas：Claude 特別容易犯的錯 + forbidden phrases + forcing questions
  - Scoring rigor：顯式公式，不用 AI 直覺
  - Domain benchmarks：結構化參考數據

System Layer：
  - Artifact discovery：自動搜尋上游產出
  - Output contract：寫到 ~/.gstack/projects/{slug}/
  - Workflow position：知道上下游、建議下一步
  - Completion protocol：DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT

Anti-Sycophancy 三層：
  - Deny list（禁用空洞讚美）
  - Forcing questions（逼出真判斷）
  - Push-back cadence（問一次不夠，再問一次）

AskUserQuestion 四段格式：
  1. Re-ground（假設用戶離開 20 分鐘）
  2. Simplify（16 歲能懂的語言）
  3. Recommend（推薦 + completeness score）
  4. Options（A/B/C + human time / CC time）
```

---

## Builder 的五個核心能力

Builder 不只是「搭一次」的工具。它有五個能力，對應用戶在不同階段的需求：

### 能力 1：快速遷移（一次性）

把 gstack 遷移到目標領域。自動產出完整 repo。
這是 `/domain-plan` + `/domain-build` 做的事。

### 能力 2：傾聽與規劃（持續）

搭完之後，用戶會持續有新需求：
- 「我想加一個專門做 X 的 skill」→ `/skill-gen` 或 `/tool-builder`
- 「這個 skill 應該改成做 Y」→ `/skill-edit`
- 「我的工作流程變了，需要重新安排」→ `/workflow-edit`

Builder 要能：
- 傾聽用戶的需求，區分「用戶說的」和「真正需要的」
- 判斷：這應該是新 skill、還是現有 skill 的新 section、還是調整 workflow
- 跟用戶一起規劃，不是用戶說什麼就照做

### 能力 3：來源轉換（持續）

用戶會帶來各種東西，想變成 skill 或改進 skill。Builder 要能把**任何來源**轉成可用的 skill 或 skill 片段。

這是 `/source-convert` 的職責。詳見下方「來源轉換 Skills」。

### 能力 4：工具打造（持續）

用戶的工作不只有「審查/規劃」，也有「操作工具」。Builder 要能幫用戶把各種工具操作包裝成 skill：

- Browser automation（如：即夢 AI 圖片/影片生成自動化）
- API 串接（如：廣告平台 API、數據源 API）
- CLI 工具（如：FFmpeg 影片處理、ImageMagick 圖片處理）
- 檔案處理（如：素材批量重命名、格式轉換）
- 外部服務整合（如：RunningHub workflow、Replicate API）

這跟 domain skill（review / bridge / production）的工作姿態完全不同：

```
Domain skill：理解領域 → 設計判斷維度 → 寫 scoring / gotchas / forcing Qs
Tool skill：  理解平台 UI/API → 寫自動化腳本 → 包裝成 skill + error handling + mode routing
```

`/tool-builder` 是通用的，不限於特定技術手段。具體用 Playwright、API call、shell script 還是其他方式，由它根據目標平台的特性判斷。

#### `/tool-builder` 的雙層架構

`/tool-builder` 有兩層能力，根據用戶意圖切換：

```
Layer 1：直接做（Hands-on mode）
  用戶說「幫我自動化即夢的影片生成」
  → /tool-builder 自己跑探索流程
  → 產出：working plugin / script / automation code

Layer 2：產出 skill（Meta mode）
  用戶說「幫我做一個能探索新網站的 skill」
  → /tool-builder 產出一個可重複使用的探索型 skill
  → 產出：SKILL.md + references/ + scripts/
```

**Mode routing at entry：**

```
/tool-builder
  → 解析用戶意圖
  → A. 自動化一個具體的目標（Layer 1）
     → 直接進入探索+建造流程
  → B. 建立一個可重複使用的工具型 skill（Layer 2）
     → 設計 skill 結構 + 產出 SKILL.md + scripts/
  → C. 不確定
     → AskUserQuestion 釐清
```

#### 內建方法論：通用探索流程（來自 explore-site 實戰驗證）

不管 Layer 1 還是 Layer 2，`/tool-builder` 內建一套通用的探索方法論，適用於任何需要自動化的目標：

```
Phase 1: Requirements     — 問用戶要自動化什麼，理解意圖和範圍
Phase 2: Discovery Plan   — 列出要找的元素/端點/操作清單（checklist）
Phase 3: Environment      — 建立執行環境（auth / config / dependencies）
Phase 4: Exploration      — 核心循環：嘗試 → 驗證 → 記錄 → 下一個
Phase 5: Integration      — 發現整合點（API / event / file format / CLI flag）
Phase 6: Build            — 從 discoveries 產出 artifact（plugin / script / skill）
Phase 7: Verify           — end-to-end 測試
```

**Phase 4 的核心循環（最重要的部分）：**

```
┌─────────────────────────────────────────────┐
│  1. 觀察當前狀態（screenshot / output）      │
│  2. 假設操作方式（selector / API / command）  │
│  3. 測試假設                                 │
│  4. 驗證結果（screenshot / output）           │
│  5. 成功 → 記錄到 discovery notes            │
│     失敗 → 調整假設 → goto 3                 │
│  6. 下一個 checklist item                    │
└─────────────────────────────────────────────┘
```

#### 不同目標類型的探索策略

| 目標類型 | Phase 4 探索方式 | Phase 5 整合發現 | Phase 6 產出 |
|---------|-----------------|-----------------|-------------|
| **Browser UI** | screenshot → selector → test click/fill | 攔截 network request → API endpoint | plugin.js / automation script |
| **REST API** | 讀 API docs → 試 endpoint → 驗證 response | auth flow / rate limit / pagination | API wrapper script |
| **CLI 工具** | 讀 help/man → 試 flag 組合 → 驗證 output | pipe / file format / exit code | shell script / skill |
| **檔案處理** | 分析 input format → 試 transform → 驗證 output | batch processing / error handling | processing script |
| **外部服務** | 讀 SDK docs → 試 call → 驗證 response | webhook / async result / quota | service integration |

#### 從 explore-site 提取的 gotchas（內建於 /tool-builder）

```
Browser automation：
  - 不用 networkidle（AI 生成網站有持久 WebSocket）
  - Modal/popup 先清掉（會 block 一切操作）
  - React/Vue select 要用 Playwright .click()（JS .click() 常失敗）
  - contenteditable 要用 keyboard.type()（.fill() 無效）
  - class name 有 hash 會變（用 [class*="partial"] 代替完整 match）
  - force: true 處理 overlay
  - 上傳後要 wait（file processing 是 async）
  - screenshot 要勤拍（before/after 每個操作）

API integration：
  - API 要用頁面 cookie（page.evaluate fetch，不是 Node.js fetch）
  - status polling 需要 retry + backoff
  - response 結構可能隨版本變

通用：
  - 先做最小 working version，再加 mode/option
  - discovery notes 是核心 artifact，不能只在記憶裡
  - 每個 discovery 要標記 tested: YES/NO
```

### 能力 5：Skill 設計檢查（內建 meta-skill）

Builder 內建一個 `/skill-check` skill，在設計和完成兩個時機自動運行，確保每個 skill 不是空殼。增加第三個 mode `pack` 做整體結構健康度評估。

**三個 mode：**

#### `/skill-check design`（Ground Check — 規劃階段）

在 Step 1（Map）規劃 skill map 時，對每個候選 skill 自動跑。

7 問快速判斷：

```
1. 它是 review、bridge、production、control、還是 runtime helper？
2. 它處理的 work unit 是什麼？
3. 它做完留下什麼 artifact？
4. 它的上游 / 下游是誰？
5. 沒有它，workflow 會痛嗎？
6. 它依賴什麼 runtime（engine / build chain / telemetry / sandbox）？
7. 它是獨立 skill，還是某個 skill 的 section？
```

輸出：

```
/game-review
  類型：Review
  Work unit：GDD
  Artifact：game-review-*.md（Health Score + 修改建議）
  上游：/game-import, /game-ideation
  下游：/balance-review, /player-experience, /game-eng-review
  缺它會痛：✅ 沒有設計審查能力
  Runtime 依賴：無
  獨立性：✅ 獨立姿態 + 獨立產出 + 獨立觸發
  → PASS
```

```
「檢查遊戲名稱拼寫」
  類型：—
  獨立姿態：❌
  獨立 artifact：❌
  獨立觸發：❌
  → FAIL — 建議合併到 /game-qa 的一個 check item
```

#### `/skill-check review`（Quality Review — 完成後）

在 Step 2（Build）完成後、Step 3（Upgrade）改完後自動跑。也可以手動觸發。支援 `--all` 批量審查所有 skill + cross-skill pattern analysis。

**15 維度（5 層 × 3D），每維 0-2 分，滿分 30：**

```
A. 入口層:  A1 Trigger Description / A2 Role Identity / A3 Mode Routing
B. 流程層:  B4 Flow Externalization / B5 STOP Gates / B6 Recovery
C. 知識層:  C7 Gotchas / C8 Scoring Rigor / C9 Domain Benchmarks
D. 結構層:  D10 Progressive Disclosure / D11 Helper Code / D12 Config/Memory
E. 系統層:  E13 Artifact Discovery / E14 Output Contract / E15 Workflow Position
```

詳見 `skills/skill-check/references/review-15d-6mines.md`。

**6 個雷區掃描：**

```
雷 1：Generic 包裝 — substitution test 不通過
雷 2：前深後淺 — 後半段只是 gstack 翻譯
雷 3：Review 當 Production — 做完只多報告，沒推進工作
雷 4：缺 Runtime — skill 寫得好但 runtime 不到位所以空轉
雷 5：過度拆分 — 太薄，使用者不知道用哪個
雷 6：低密度 — 很長但高訊號內容很少
```

#### `/skill-check pack`（Pack Health — 整體結構評估）

在 Step 2（Build）完成後自動跑。整合原本的 7 項 Pack 結構健康度評估：

```
1. Workflow 跑通測試 — 假設用戶典型成果，反推 workflow 能不能跑到
2. 領域深度均衡 — 高深度 vs 低深度 skill 比例
3. 前後銜接 — 每個 skill 的產出有沒有被下游消費
4. 差異化價值 — 跟直接用 gstack 原版比的增量
5. Bridge Layer Check — 設計 artifact ≠ 實作 artifact 時有沒有轉譯層
6. Substitution Test — 換成通用 web app 後半段還一樣嗎
7. Production Artifact Check — 後半段吃的是不是領域的 runtime evidence
```

產出：Pack 結構健康度報告（含 ✅/⚠️/❌ 標記 + builder 建議）

#### 自動 vs 手動

```
自動觸發：
  /domain-plan 完成 → /skill-check design 跑所有候選 skill
  /domain-build 完成 → /skill-check review 跑所有已產出 skill + /skill-check pack 跑整體評估
  /domain-upgrade 每次改完 → /skill-check review 跑被改的 skill
  /skill-gen 完成 → /skill-check review 跑新 skill + /skill-check pack 檢查 workflow 影響

手動觸發：
  用戶隨時可以說 /skill-check 檢查任何 skill 或整個 pack
```

#### Skill 類型分類（5 類）

`/skill-check design` 的第一問用這個分類：

| 類型 | 核心 | 典型輸出 | 寫法重點 |
|------|------|---------|---------|
| **Review** | 判斷 / 審查 / 評估 | score, issue list, recommendation | dimensions + scoring + anti-sycophancy + forcing questions |
| **Bridge** | 轉譯 / handoff / 切片 | spec, slice plan, acceptance criteria | translation logic + scope + in/out + dependency mapping |
| **Production** | 生產 / 生成 / 實作 | code, asset, content, new artifact | build target + execution steps + fallback + success criteria |
| **Control** | 路由 / 編排 / 健康檢查 | workflow map, routing decision, upgrade plan | routing + pack health + conflict resolution |
| **Runtime Helper** | 依賴外部 runtime 的輔助 | 取決於 runtime | 明確標注 runtime dependency，沒有 runtime 就不要做 |

每種類型有不同的自由度：

```
高自由度（ideation / conceptual review）：principles + heuristics + examples
中自由度（structured review / bridge）：phase flow + templates + ask gates
低自由度（production / release / migration）：scripts + exact sequence + tight guardrails
```

#### 外部參考文件

`/skill-check` 的完整判斷邏輯、雷區解說、製作方法詳見：
`skills/skill-check/references/review-15d-6mines.md`

---

## 來源轉換 Skills

Builder 自己內建一組 skill，專門做「來源 → skill」的轉換。這些不是用戶的 domain skill，是 builder 的工具。

### 為什麼需要這個

用戶不會說「請幫我寫一個 SKILL.md.tmpl，裡面要有 gotchas 和 scoring formula」。

用戶會說：
- 「這個 YouTube 影片的方法很好，我想用在我的 review 流程裡」
- 「我有一個自己用了三年的 prompt，想變成正式的 skill」
- 「這篇部落格的框架很適合我的 pitch review」
- 「我買了一本書，裡面的方法論我想整合進去」
- 「我想到一個新的工作流程，幫我變成 skill」
- 「我在 GitHub 找到一個 skill repo，想把裡面的東西拿來用」

Builder 需要能處理所有這些。

### 來源轉換清單

| 來源類型 | 用戶怎麼給 | Builder 怎麼轉 |
|---------|-----------|---------------|
| **其他 skill repo** | 給 repo 路徑或 URL | 讀 SKILL.md → 評估 fit → 適配 preamble/artifact 格式 → 匯入或合併 |
| **現有 prompt** | 貼 prompt 或給檔案路徑 | 分析 prompt 結構 → 判斷是動作型還是判斷型 → 包裝成 SKILL.md.tmpl |
| **YouTube / 影片** | 給 URL 或貼逐字稿 | 提取方法論框架 → 轉成 review dimensions / scoring / steps |
| **文章 / 部落格** | 給 URL 或貼內容 | 提取判斷規則、checklist、framework → 填入對應 skill section |
| **書 / 方法論** | 描述書名和核心方法，或貼重點摘錄 | 提取可操作的判斷標準 → 轉成 gotchas / scoring / forcing questions |
| **SOP / 內部文件** | 給檔案 | 提取工作步驟 → 轉成 skill 流程 + 判斷點 |
| **代碼庫 / PR** | 給 repo 路徑 | 分析 commit pattern / review style → 提取判斷標準和 gotchas |
| **用戶的想法** | 口述 | 幫用戶結構化 → 判斷是新 skill 還是現有 skill 的改進 → 產出 |
| **案例 / 失敗經驗** | 描述一個具體案例 | 轉成 gotcha 或 forcing question → 填入對應 skill |
| **ECC skills** | 指定 ECC skill 名稱或路徑 | 讀 SKILL.md → 提取 knowledge → 加上互動設計 + 判斷邏輯 + 系統整合 → 適配 gstack 格式 |
| **Git history** | 給 repo 路徑 | 分析 commit pattern / 重複工作模式 → 產出 skill（參考 ECC skill-create） |

### 轉換流程（通用）

不管來源類型，轉換都走同一個流程：

```
1. 理解來源（讀 / 聽 / 分析）
2. 判斷落點（Target Placement）
3. 跟用戶確認落點
4. 執行轉換
5. 評估升級效果
6. 讓用戶看結果
```

### Target Placement Model（來源落點判斷）

**這是來源轉換最關鍵的一步。** 不是所有來源都該變成 skill。很多來源只值一條 gotcha 或一個 benchmark patch。如果沒有這個判斷，builder 會「看什麼都想生成 skill」。

每次用戶帶來一個來源，builder 先判斷它應該落在哪一層：

| 落點 | 說明 | 範例 |
|------|------|------|
| **1. New skill** | 這個來源包含一個完整的、獨立的工作姿態 | 用戶帶來一整套 playtest 方法 → 新建 /playtest |
| **2. Skill section** | 這個來源可以替換或新增某個 skill 的一整個 section | 一篇文章的經濟模型框架 → 替換 /balance-review Section 2 |
| **3. Judgment patch** | 這個來源包含零散但有價值的判斷碎片 | 一條實戰 gotcha、一個 benchmark 數字、一個 forcing question |
| **4. Workflow patch** | 這個來源改變的不是 skill 內容，而是 skill 之間的串接 | 「review 完應該先過 balance 再過 player experience」→ 改 workflow 順序 |
| **5. Reference asset** | 這個來源有參考價值但不直接進 skill | 一本書的理論背景 → 放 references/，skill 需要時引用 |

**判斷規則：**

```
這個來源能通過「獨立姿態 + 獨立產出 + 獨立觸發」三個測試嗎？
  三個都過 → Level 1（new skill）
  不過 →

這個來源能替換某個 skill 裡的完整 section 嗎？
  能 → Level 2（skill section）
  不能 →

這個來源包含具體的、可直接用的判斷規則嗎？
  有 → Level 3（judgment patch）
  沒有 →

這個來源改變的是 skill 之間的關係嗎？
  是 → Level 4（workflow patch）
  不是 → Level 5（reference asset）
```

**跟用戶確認落點：**

```
「你帶來的這篇文章，我分析後覺得它最適合：
 替換 /balance-review 的 Section 2（經濟模型框架）。

 它不夠完整到變成獨立 skill，但比現在 Section 2 的大模型版本好。
 你同意這樣放嗎？還是你有別的想法？」
```

### 轉換品質的關鍵

```
好的轉換：
  ✅ 保留來源的核心判斷邏輯
  ✅ 適配 gstack 的互動格式（AskUserQuestion、STOP gates）
  ✅ 跟現有 skill 的其他 section 不衝突
  ✅ 標注來源（這個方法來自哪裡）

壞的轉換：
  ❌ 把一篇 2000 字的文章原封不動塞進 SKILL.md
  ❌ 只取表面結構，丟掉核心判斷
  ❌ 跟現有 skill 矛盾但沒處理衝突
  ❌ 來源不可追溯
```

---

## Canonical Cycle（5 步 + 持續迭代）

```
Plan → Build → Upgrade → Test → Iterate
 規劃    搭建     升級     測試    迭代
                   ↑                 │
                   └─────────────────┘
                   （持續循環：用戶帶來新需求、新來源）
```

### Skill 對應表

```
Step 1 Plan     → /domain-plan
Step 2 Build    → /domain-build → /skill-check pack
Step 3 Upgrade  → /domain-upgrade + /skill-edit + /source-convert + /tool-builder + /workflow-edit
Step 4 Test     → /domain-upgrade（test feedback mode）
Step 5 Iterate  → /domain-upgrade + /skill-gen + /skill-check review

隨時可用：/skill-check, /prism-routing
```

### Step 1: Plan（規劃 skill map）

**用戶做的事：描述領域 + 確認 skill map。**
**Builder 做的事：`/domain-plan` 自動推導 skill map + workflow。**

#### 1.1 最少輸入

```
用戶只需要說：
  「我做遊戲開發」
  「我做影劇製作」
  「我做教育課程設計」
  「我是自由接案的平面設計師」
```

Builder 根據領域自動推導：
- 工作生命週期
- 通用底盤 skill（從 gstack fork）
- 規劃視角 skill（策略/設計/工程，根據領域選）
- 領域專屬 skill（用審查缺口法 + 工作流缺口法推導）
- 入口 skill
- Artifact 流向

#### 1.2 呈現 skill map 讓用戶確認

```
我為你的領域規劃了 18 個 skill：

通用底盤（10 個，從 gstack 遷移）：
  /ideation, /direction, /review, /qa, /ship,
  /investigate, /retro, /careful, /guard, /docs

規劃視角（3 個）：
  /plan-strategy, /plan-design, /plan-eng

領域專屬（4 個）：
  /script-review — 劇本結構與品質審查
  /character-review — 角色一致性與弧線
  /visual-review — 視覺語言與分鏡
  /budget-review — 預算與製作可行性

入口（1 個）：
  /script-import — 外部劇本匯入標準格式

工作流程：
  /script-import → /ideation → /direction →
  /script-review → /character-review → /visual-review →
  /plan-eng → build → /review → /qa → /ship

你覺得：
  A. 這樣可以，開始搭建
  B. 我要加 skill（告訴我加什麼）
  C. 我要刪/合併 skill（告訴我哪些）
  D. 工作流程要改（告訴我怎麼改）
  E. 我有些 skill 想用自己的版本替換（先搭完再換也行）
```

#### 1.3 用戶在這一步的決策

```
用戶決定的：
  - 要哪些 skill（增刪合併）
  - 工作流程對不對
  - 哪些 skill 之後想升級（標記，不影響搭建）

用戶不需要決定的：
  - 每個 skill 裡面寫什麼
  - gotchas / scoring / forcing questions 的具體內容
  - 評分公式
  - preamble 細節
```

產出：`skill-map.md` + `workflow-graph.md`（用戶確認版）

---

### Step 2: Build（自動搭建完整 gstack）

**用戶做的事：等。（或者去喝咖啡。）**
**Builder 做的事：`/domain-build` 自動產出所有 skill。完成後 `/skill-check pack` 自動跑健康度報告。**

#### 2.1 搭建順序

```
Phase 1：工程骨架
  - repo scaffold
  - preamble（含領域詞彙——大模型自己生成）
  - template engine 配置
  - bin/ 工具（fork from gstack）
  - install.sh
  - routing skill

Phase 2：通用底盤 skill
  - 從 gstack fork
  - 自動替換領域詞彙
  - 最少改動，保持 gstack 方法論

Phase 3：規劃視角 skill
  - 從 gstack 的 plan-ceo/eng/design review fork
  - 替換領域框架（大模型產出）

Phase 4：領域專屬 skill
  - 大模型根據領域知識產出
  - 包含：role identity, review dimensions, scoring formula,
    gotchas, forcing questions, anti-sycophancy
  - 品質：可用但不完美（這是預期的）

Phase 5：入口 skill
  - 根據領域的外部素材格式設計

Phase 6：系統整合
  - artifact discovery（每個 skill 知道找上游）
  - save artifact（每個 skill 寫到共享目錄）
  - workflow graph 串接驗證
  - review dashboard
```

#### 2.2 品質預期

```
大模型自動產出的 skill 品質：

通用底盤：80-90%（gstack 方法論 + 領域詞彙替換，很穩）
規劃視角：70-80%（框架對，領域深度中等）
領域專屬：50-70%（骨架對，判斷有但不尖銳，gotchas 是通識級）
入口：80%（格式轉換類，大模型擅長）

這就是 P1 的目標：能跑，不完美，但比沒有好太多。
完美靠 Step 3 升級。
```

#### 2.3 自動產出的東西

```
每個 skill 自動包含：
  - SKILL.md.tmpl（完整 template）
  - YAML frontmatter（name, description with trigger + anti-trigger）
  - Role identity
  - Mode routing（如果適用）
  - Review sections with scoring
  - AskUserQuestion 互動點
  - STOP gates
  - Anti-sycophancy（領域版 forbidden phrases）
  - Gotchas（大模型通識級，等升級）
  - Forcing questions
  - Completion protocol
  - Artifact discovery + save
  - Workflow position（推薦下一步）

每個 skill 不自動包含（等 Step 3 升級）：
  - 實戰級 gotchas
  - 校準過的 benchmark 數字
  - 團隊/個人特定的判斷偏好
  - 比大模型通識更深的領域知識
```

產出：**完整可運行的 domain gstack repo**

#### 2.6 Step 2 最小驗收標準

Step 2 完成不是「所有 skill 檔案都在」。是以下 5 條全過：

```
1. Routing skill 可工作
   - 用戶說 /help 或隨便一句話，routing skill 能正確建議用哪個 skill

2. 至少 1 條 first slice 完整跑通
   - 例如 /import → /domain-review → save artifact
   - 每一步的 artifact 都能被下一步讀到
   - 不能有斷點（「找不到上游 artifact」）

3. Artifact discovery / save 沒斷
   - 隨機抽 3 個 skill，確認：
     - 開頭的 artifact discovery bash block 在空目錄不報錯
     - 結尾的 save artifact 能寫到 ~/.gstack/projects/{slug}/

4. install.sh 能在乾淨 repo 裝成功
   - git clone 一個空 repo → 跑 install.sh → 所有 skill 出現在 .claude/skills/

5. 至少 3 個核心 skill 有可讀可用的互動結構
   - 有 AskUserQuestion 互動點（不會一口氣跑完）
   - 有 STOP gates
   - 有 completion summary
   - 隨便跑一個，互動體驗至少是「能用」等級
```

**如果 5 條沒全過，Step 2 還沒完成。** 不是繼續加 skill，而是先修通過驗收。

#### 2.7 Pack 結構健康度評估

5 條驗收通過後，builder 自動做一次整體結構評估，產出一份報告給用戶。

這不是 skill 層級的品質評估，是 **pack 層級的編排評估**。

##### 評估 1：Workflow 能不能跑通產出成果

**最關鍵的一條。** 不是「每個 skill 能不能單獨跑」，而是「整條 workflow 串起來，最後能不能產出用戶真正要的東西」。

用戶搭 gstack 不是為了有 skill，是為了工作能產出成果。Builder 要能根據領域判斷：這個 stack 最後應該產出什麼？然後檢查 workflow 能不能跑到那裡。

```
檢查方式：假設用戶的典型工作成果，反推 workflow 能不能產出。

範例：

行銷 stack：
  用戶的成果 = 一篇行銷文章 / 一則社群貼文 / 一段廣告影片
  檢查：從 /ideation 一路走到 /ship，中間有沒有斷？
    /ideation → /content-plan → /copywriting → /content-review → /ship
    ✅ 能產出文章
    ❌ 影片製作沒有 skill 覆蓋 → 標記 gap

遊戲 stack：
  用戶的成果 = 一份審查過的 GDD / 一個可發布的 build
  檢查 1：/game-import → /game-review → /balance-review → 審查完的 GDD
    ✅ 前半段能產出審查報告
  檢查 2：審查完 → ??? → /game-code-review → /game-qa → /game-ship
    ❌ 設計審查到實作之間沒有銜接 → 標記 gap

教育 stack：
  用戶的成果 = 一堂完整的課程
  檢查：/course-ideation → /learning-design → /content-creation → /course-review → /course-ship
    ✅ 能產出課程
    ⚠️ /content-creation 是動作型 skill，大模型版本可能太淺 → 建議升級
```

**Builder 對每種預期成果產出一個 workflow trace：**

```
成果：[用戶的典型工作成果]
Workflow：[skill A] → [skill B] → ... → [最終產出]
狀態：
  ✅ 可跑通 — 每一步的 artifact 都有下一步消費
  ⚠️ 可跑通但有弱點 — 某些 skill 的深度不夠，建議升級
  ❌ 有 gap — 某個環節沒有 skill 覆蓋，需要補
```

##### 評估 2：領域深度均衡

```
把所有 skill 分成兩類：

  領域深度高 = 有這個領域專屬的判斷邏輯（不只是換詞彙）
  領域深度低 = 基本上是 gstack 原版 + 領域詞彙替換

統計比例：
  高：___ 個（____%）
  低：___ 個（____%）

如果低深度 > 60%：
  「你的 stack 有超過一半的 skill 跟通用 gstack 差異不大。
   這不影響使用，但如果你想讓它更貼合你的領域，
   建議優先升級這幾個：[列出最值得升級的 3 個]」
```

##### 評估 3：前後銜接

```
檢查：每個 skill 的產出，有沒有被至少一個下游 skill 消費？

  /game-review 產出 Health Score + 修改建議
    → 誰讀這個？/balance-review 讀嗎？/game-eng-review 讀嗎？
    → 如果沒人讀 → 這個產出可能在 workflow 裡斷了

  /balance-review 產出 Balance Report
    → 誰讀這個？/game-direction 讀嗎？/game-ship 讀嗎？
    → 如果只有 /game-direction 讀，那它在開發流程裡的價值有限

標記三種狀態：
  ✅ 產出被下游消費
  ⚠️ 產出有下游但銜接可能不順（格式不匹配、內容不夠）
  ❌ 產出沒有下游消費（孤立的 skill）
```

##### 評估 4：差異化價值

```
跟直接用 gstack 原版比，這個 domain stack 的增量價值在哪？

  高增量：[列出真正有領域專屬深度的 skill]
  低增量：[列出基本上是 gstack 翻譯的 skill]
  獨有：[列出 gstack 原版沒有的 skill]

如果高增量 + 獨有 < 5 個：
  「目前你的 stack 跟直接用 gstack + 改詞彙差異不大。
   核心差異化在這幾個 skill：[列出]。
   建議把精力集中在升級這些，它們是你的 stack 存在的理由。」
```

##### 評估 5：Bridge Layer Check（設計→實作的轉譯層）

```
問：這個領域的設計 artifact 跟實作 artifact 是不是同一種東西？

  遊戲：GDD ≠ code → 需要 bridge（slice planning / system spec / handoff）
  影劇：劇本 ≠ 拍攝計畫 → 需要 bridge（分鏡 / production plan）
  行銷：brief ≠ 創意素材 → 需要 bridge（creative spec / content plan）
  教育：課程設計 ≠ 教材 → 需要 bridge（lesson plan / content production）

如果設計 artifact ≠ 實作 artifact，檢查：
  1. Skill map 裡有沒有 bridge skill？
  2. Bridge skill 的輸入是設計 artifact 嗎？
  3. Bridge skill 的輸出能被實作/驗證階段消費嗎？

狀態：
  ✅ Present — 有 bridge layer，串接通
  ⚠️ Thin — 有但轉譯不夠（例如只是 handoff checklist，沒有真正拆解）
  ❌ Missing — 設計直接跳到實作，中間空的
```

##### 評估 6：Substitution Test（領域化程度快速檢驗）

```
最簡單也最有效的 heuristic：

  把這個 domain 換成一般 web app，
  後半段的 skill 還幾乎不變嗎？

逐個 skill 檢查：
  /game-code-review → 換成 web app 的 code review → 幾乎不變 → ❌ generic
  /game-qa → 換成 web app 的 QA → 幾乎不變 → ❌ generic
  /balance-review → 換成 web app → 完全不適用 → ✅ domain-specific
  /player-experience → 換成 web app → 完全不適用 → ✅ domain-specific

統計：
  通過 substitution test（domain-specific）：___ 個
  未通過（generic）：___ 個

如果未通過 > 50%：
  「後半段大多數 skill 在替換測試中跟通用 web app 沒有區別。
   這些 skill 目前能用，但它們不是你的 domain stack 的價值所在。
   想讓後半段也有領域深度的話，需要改變它們的工作單位——
   不是審查 code diff，而是審查 [領域特有的 runtime evidence]。」
```

##### 評估 7：Production Artifact Check（後半段吃的是不是領域的東西）

```
後半段（實作/驗證/發布）的 skill 吃什麼 artifact？

Generic artifacts（任何領域都一樣的）：
  - code diff
  - PR
  - bug report
  - build log
  - changelog

Domain-specific runtime evidence（每個領域不同的）：
  遊戲：playability, feel, frame timing, telemetry, playtest notes
  影劇：rough cut, scene timing, audience screening notes, color grade
  教育：lesson delivery observation, learner confusion points, assessment results
  行銷：campaign performance, creative fatigue, funnel dropoff, A/B results

檢查後半段每個 skill：
  它的輸入只有 generic artifacts → ⚠️ 還沒真正領域化
  它的輸入包含 domain-specific evidence → ✅ 已進入領域生產語言

如果後半段所有 skill 都只吃 generic artifacts：
  「後半段還停留在通用軟體工程語言。
   要讓它真正為 [領域] 工作，需要讓驗證/發布階段
   吃到 [領域] 的 runtime evidence：[列出該領域的 evidence 類型]。
   這可能需要新增 1-2 個 production-specific skill，
   或在現有 skill 裡加入 domain evidence 的 section。」
```

##### 報告格式

Builder 在 Step 2 完成後自動產出：

```
═══════════════════════════════════════════
     PACK 結構健康度報告
═══════════════════════════════════════════

■ Workflow 跑通測試
  成果 1：[審查過的 GDD]  → ✅ 可跑通
  成果 2：[可發布的 build] → ❌ 設計→實作之間有 gap

■ 領域深度
  高深度：9 個（41%）
  低深度：13 個（59%）
  → ⚠️ 超過一半是通用版翻譯

■ 前後銜接
  ✅ 正常銜接：15 個
  ⚠️ 銜接可能不順：4 個
  ❌ 孤立產出：3 個

■ 差異化價值
  高增量：5 個
  低增量：12 個
  獨有：5 個
  → 核心差異化集中在前半段

■ Bridge Layer
  ❌ Missing — 設計 artifact（GDD）到實作（code）之間沒有轉譯層

■ Substitution Test
  通過（domain-specific）：9 個
  未通過（generic）：13 個
  → 後半段大多數 skill 跟通用 web app 無區別

■ Production Evidence
  吃 domain evidence 的 skill：3 個
  只吃 generic artifact 的 skill：10 個
  → 後半段還停留在通用工程語言

■ 結構風險
  ⚠️ 前深後淺（Review-Production Asymmetry）
  前半段已進入領域審查語言，後半段仍為 generic engineering

■ Builder 建議
  1. 🔴 補 bridge layer（設計→實作轉譯，例如 /implementation-plan）
  2. 🟡 後半段 3 個最重要的 skill 加入 domain runtime evidence
  3. 🟡 升級未通過 substitution test 的 skill，改變工作單位
  4. ⚪ 長期：把孤立 skill 接進 workflow 或移除

═══════════════════════════════════════════
```

**這份報告不是限制。** 用戶看完可以：
- 照建議改
- 不改（「我知道後半段弱，但目前夠用」）
- 有不同想法（「gap 不需要補，我有其他工具處理那段」）

Builder 提供視角，用戶做決定。

---

### Step 3: Upgrade（傾聽需求 + 來源轉換 + 持續改進）

**這一步不是一次性的。它是 builder 搭完後的常態工作模式。**
**涉及的 builder skills：`/domain-upgrade`（流程主導）+ `/skill-edit`（直接改）+ `/source-convert`（來源轉換）+ `/tool-builder`（工具型）+ `/workflow-edit`（串接調整）**

用戶會持續帶來三種東西：
- **需求**：「我想加一個做 X 的功能」
- **來源**：「這個影片/文章/skill 很好，我想用」
- **回饋**：「這個 skill 不好用，哪裡不對」

Builder 持續處理這三種輸入。

#### 3.1 傾聽需求：用戶說的 vs 真正需要的

用戶不一定知道自己要的是什麼。Builder 要幫他釐清。

```
用戶說：「我想加一個 AI 美術審查的 skill」

Builder 想：
  - 他真的需要一個獨立的 skill 嗎？
  - 還是在 /review 裡加一個 visual section 就夠了？
  - 他的 workflow 裡這個 skill 在哪個位置？
  - 有上游 artifact 嗎？有下游消費者嗎？

Builder 問：
  「你目前的美術審查流程是什麼樣的？
   A. 每次都需要獨立做一次完整的美術審查 → 獨立 skill
   B. 做 code review 的時候順便看一下美術 → 加到 /review 裡
   C. 不確定 → 我先加成 /review 的一個 section，你用看看，
      如果太重再拆出來」
```

#### 3.2 來源轉換：把各種東西變成 skill

用戶帶來任何東西，builder 用「來源轉換 Skills」處理。（詳見上方「來源轉換 Skills」章節）

常見場景：

```
場景 1：用戶帶來一個外部 skill repo
  「我找到一個做遊戲平衡的 skill repo，想用」
  → Builder 讀 repo → 評估跟現有 /balance-review 的差異
  → 問用戶：「替換整個？還是合併最好的部分？」
  → 執行

場景 2：用戶看了一個 YouTube 影片
  「這個影片教的 pitch 方法很好」
  → Builder 讀逐字稿/用戶摘要 → 提取方法框架
  → 整合進 /pitch-review 的對應 section
  → 讓用戶確認

場景 3：用戶有一個自己的想法
  「我覺得審查 GDD 的時候應該先看核心循環，再看其他的」
  → Builder：「好，我把 /game-review 的 Section 順序調一下，
    核心循環移到最前面。你跑一次看看？」

場景 4：用戶有一篇部落格文章
  「這篇文章的遊戲經濟框架比現在用的好」
  → Builder 讀文章 → 提取 framework → 替換 /balance-review 的 Section 2
  → 標注來源

場景 5：用戶自己有經驗但不知道怎麼表達
  「我知道什麼是好的對白，但說不清楚」
  → Builder 不做訪談。而是：
    「我先給你看現在 /dialogue-review 怎麼評分的。
     你看看哪裡不對，告訴我。」
  → 用戶在大模型版本上挑錯 / 補充 → Builder 修改
```

#### 3.3 用戶主動升級

用戶說「我想升級 /balance-review」，builder 問：

```
你有什麼可以讓 /balance-review 更好？

  A. 我有一個現成的 skill/prompt 做這件事
     → 匯入，評估 fit，替換或合併

  B. 我有相關的代碼庫/資料/文件
     → 分析提取判斷規則，填入對應 section

  C. 我知道一個好的外部方法/框架（文章、影片、書）
     → 告訴我來源，我讀完整合進去

  D. 我自己有經驗想分享
     → 我先給你看現在的版本，你在上面改

  E. 我不確定怎麼升級，但覺得現在的版本不夠好
     → 告訴我哪裡不好，我們一起改
```

#### 3.3 升級的粒度

不一定要替換整個 skill。可以只升級一個 section：

```
升級粒度：
  - 替換整個 skill（用外部 skill 取代）
  - 替換 scoring formula（用更好的評分方式）
  - 加 gotchas（加幾條實戰踩過的坑）
  - 換 benchmarks（用真實數據替換大模型猜的）
  - 加 forcing questions（加幾個更尖銳的問題）
  - 改 review dimensions（調整審查維度和權重）
  - 改 anti-sycophancy（加領域特定的空洞讚美禁止清單）
```

#### 3.4 升級來源不限於用戶自己的經驗

```
有效的升級來源：
  - 用戶自己的經驗 ✓
  - 別人寫的 skill ✓
  - 公開的方法論/框架 ✓
  - 學術研究 ✓
  - 第三方工具的 best practices ✓
  - 行業報告的 benchmark 數字 ✓
  - 社群討論的 gotchas ✓
  - 任何能讓這個 skill 更好的東西 ✓
```

#### 3.5 Builder 協助用戶提供經驗（不是逼問）

如果用戶選了 D（想分享自己的經驗），builder 的姿態是**協助結構化**，不是訪談：

```
不做：
  ❌ 「請描述你的完整判斷流程」
  ❌ 「你的評分標準是什麼？請列出所有維度」
  ❌ 「請提供 5 個 gotchas」

做：
  ✅ 「現在 /balance-review 的 Day 7 retention benchmark 是 20%。
      你覺得這個數字對你的遊戲類型準嗎？如果不準，你會用什麼數字？」
  ✅ 「現在 gotchas 裡有一條：Claude 會忽略 time dimension。
      你實際用的時候有遇到其他 Claude 常犯的錯嗎？」
  ✅ 「現在 scoring formula 把 economy balance 權重設在 25%。
      你覺得在你的遊戲類型裡應該更高還是更低？」
```

**關鍵差異：builder 先給出大模型版本，用戶在上面改。不是從空白開始問。**

---

### Step 4: Test（用真實材料測試）

**用戶做的事：拿真實工作材料跑一次。**
**Builder 做的事：`/domain-upgrade`（test feedback mode）收集回饋，標記需要改進的地方。**

#### 4.1 測試方式

```
1. 在真實專案裡安裝 domain gstack
2. 用真實的工作材料跑 first slice（2-3 個 skill 的 workflow）
3. 記錄：
   - 哪些 skill 真的幫到了
   - 哪些 skill 判斷離譜
   - 哪些地方互動太多（問太多）
   - 哪些地方互動太少（該問沒問）
   - 哪些 artifact 串接斷了
```

#### 4.2 回饋分類

```
A 類（自動修）：
  - 詞彙不對 → 改 preamble
  - artifact 格式不接 → 改 output contract
  - trigger 描述不準 → 改 description

B 類（跟用戶討論後修）：
  - 判斷維度缺了 → 加 section
  - 判斷方向錯了 → 改 scoring / review dimensions
  - 互動節奏不對 → 調 STOP gates

C 類（需要升級材料）：
  - gotchas 太淺 → 標進 upgrade backlog
  - benchmark 數字不對 → 標進 upgrade backlog
  - 缺少領域深度 → 標進 upgrade backlog
```

---

### Step 5: Iterate（持續改進）

```
搭完 → 測完 → 發現問題 → 改
                         ├─ A 類：builder 自動修
                         ├─ B 類：跟用戶討論
                         └─ C 類：回 Step 3 升級

這個循環沒有終點。
domain gstack 是活的，會隨著使用持續演化。
```

---

## Work Unit

### 主要 work unit

**一個完整的 domain gstack repo。**

從 Step 1 到 Step 2 結束就產出。Step 3-5 是持續的。

### 次要 work unit

**一個 skill 升級。**

用戶帶著材料來升級某個 skill，這是一次獨立的 work unit。

---

## Ready / Done

### Ready

```
最低門檻：用戶能說出自己的領域是什麼。
就這樣。不需要材料、不需要文件、不需要經驗描述。
```

### Done（Step 2 完成）

```
- 有完整的 domain gstack repo
- 所有 skill 可運行
- workflow graph 串接完整
- install.sh 能在真實專案安裝
- 用戶確認過 skill map
```

### Better（Step 3-5 之後）

```
- 關鍵 skill 已用更好的材料升級
- 在真實工作中驗證過
- calibration backlog 在收斂
- 用戶持續在用
```

---

## State Model

### Dossier States

```
1. planning      — Step 1 進行中（用戶在確認 skill map）
2. building      — Step 2 進行中（自動搭建）
3. ready         — Step 2 完成（完整 gstack 可用）
4. upgrading     — Step 3 進行中（用戶在升級個別 skill）
5. testing       — Step 4 進行中（真實材料測試）
6. iterating     — Step 5 持續改進中
```

### Skill States

```
1. planned       — 在 skill map 裡有位置
2. generated     — 大模型自動產出（可用但非最優）
3. upgraded      — 用更好的材料升級過
4. validated     — 在真實工作中驗證過
5. calibrating   — 有已知問題在改進中
```

---

## Execution Contract

### Runtime Policy

```
1. 能自動的就自動，不問用戶
2. 用戶只做 skill map 層級的決策
3. 細節由 builder + 大模型產出，用戶事後可改
4. 沒有材料就用大模型能力補，不 block 在用戶身上
5. 升級是可選的、漸進的、無壓力的
```

### 不做的事

```
❌ 逼用戶做經驗訪談
❌ 在搭建過程中反覆問用戶細節
❌ 因為缺少用戶材料而停下來
❌ 把品質責任推給用戶（「你沒提供 gotchas 所以 skill 不好用」）
❌ 要求用戶理解 skill 架構（YAML、template、preamble）
❌ 搭完就消失（builder 是持續服務）
❌ 拒絕任何來源類型（用戶帶來什麼，builder 就處理什麼）
```

### Stop Policy

```
只在這些情況停：
- 用戶的領域 builder 完全不理解（需要用戶補充基本描述）
- Skill map 有根本性分歧（用戶要的和 builder 推導的差太多）
- 真實測試發現 workflow 不成立（需要重新規劃）
```

---

## 與 gstack 架構的關係

### 直接複用（不重做）

```
- template engine（gen-skill-docs.ts）
- preamble injection
- umbrella + symlink
- self-update mechanism
- config store
- host abstraction
- artifact discovery / save pattern
- review dashboard
- completion protocol
- session awareness
```

### Builder 自動處理（用戶不碰）

```
- SKILL.md.tmpl 生成
- YAML frontmatter
- 領域詞彙替換
- preamble 領域化
- artifact flow 串接
- install.sh 生成
- CLAUDE.md 生成
- routing skill 生成
- bin/ 工具 fork
- test 骨架
- per-project state 管理（~/.gstack/projects/{slug}/.prismstack/）
```

> **State conventions:** 每個 project 的 prismstack 狀態（check results, build progress, domain config）存放在 `~/.gstack/projects/{slug}/.prismstack/`。詳見 `skills/shared/state-conventions.md`。

### 用戶參與的部分

```
- 確認 skill map（增刪合併）
- 確認 workflow（流程對不對）
- 提供升級材料（可選）
- 測試回饋（跑完告訴 builder 什麼好什麼不好）
```

---

## 與 Everything Claude Code (ECC) 生態的關係

> 參考：C:\ai_project\everything-claude-code
> ECC = 120+ skills 的 Claude Code 插件合集（50K+ stars），含 skill-stocktake、skill-create 等 meta-skill。

### 設計原則：Builder 產出的 domain stack 必須相容 ECC 生態

Builder 產出的 skill 格式需要同時滿足 gstack 和 ECC 的要求，讓用戶可以：
- 在 gstack 環境中用（preamble injection、artifact flow、AskUserQuestion）
- 在 ECC 環境中用（YAML frontmatter、install.sh、~/.claude/skills/ 結構）
- 混合使用（ECC 的通用 skill + Prismstack 的 domain skill 共存）

### 四個整合面

#### 1. 格式相容（產出層）

Builder 產出的每個 skill 必須包含 ECC 相容的格式：

```
ECC skill 格式：
  ---
  description: "..."     ← trigger + anti-trigger
  origin: "..."          ← 來源標記
  ---
  # skill-name
  ## When to Use
  ## How It Works
  ## Examples

gstack skill 格式（在 ECC 格式之上額外包含）：
  - Role identity
  - Mode routing
  - AskUserQuestion 互動點
  - STOP gates
  - Scoring + gotchas + forcing questions
  - Artifact discovery / save
  - Completion protocol
```

**Builder 的 `/domain-build` 產出的 SKILL.md 同時滿足兩套格式。** ECC 用戶看到的是標準 skill，gstack 用戶看到的是完整互動式 skill。

#### 2. 來源整合（/source-convert）

`/source-convert` 能吃 ECC 的 120+ skills 作為來源：

```
用戶說「ECC 裡有個 python-patterns skill，我想用在我的 domain stack」
  → /source-convert 讀 ECC skill
  → 判斷落點（new skill / skill section / judgment patch）
  → 適配 gstack 格式（加 AskUserQuestion、scoring、artifact flow）
  → 整合進 domain stack
```

ECC skills 通常是 knowledge-type（patterns、standards、references），轉成 gstack skill 時需要加上：
- 互動設計（AskUserQuestion、STOP gates）
- 判斷邏輯（scoring、forcing questions）
- 系統整合（artifact discovery、workflow position）

#### 3. 品質審計（/skill-check 參考 ECC skill-stocktake）

ECC 的 `skill-stocktake` 提供了一套成熟的審計模式，`/skill-check` 可以參考：

```
skill-stocktake 的優點（可整合）：
  - Quick Scan mode：只檢查有變動的 skill（diff-based）
  - 結果快取（results.json）：不用每次全跑
  - 批次 subagent 評估：20 個 skill 一批
  - Verdict 分類：Keep / Improve / Update / Retire / Merge
  - Reason 品質要求：必須 self-contained + decision-enabling
  - Resume detection：中斷可繼續

/skill-check 已有但 stocktake 沒有的：
  - 15D 品質 rubric（更細的評分維度）
  - 6 雷區掃描
  - Pack 層級健康度（不只 skill 層級）
  - design mode（規劃階段 7 問）
```

**Builder 的 `/skill-check` = gstack 的深度 rubric + ECC stocktake 的效率機制。**

#### 4. 來源產出（/source-convert 參考 ECC skill-create）

ECC 的 `skill-create` 能從 git history 自動產出 skill，這個能力可以整合進 `/source-convert`：

```
skill-create 的方法（可整合為 /source-convert 的一個來源類型）：
  - 分析 git commit pattern
  - 提取重複的工作模式
  - 自動產出 skill

/source-convert 的來源類型表新增：
  | git history | 給 repo 路徑 | 分析 commit pattern → 提取工作模式 → 產出 skill |
```

#### 5. 安裝機制

Builder 產出的 domain stack 的 `install.sh` 參考 ECC 的跨平台方式：

```
ECC 方式：
  install.sh → 委託給 Node.js scripts/install-apply.js
  支援 Windows / macOS / Linux

Builder 產出的 install.sh：
  - 同樣委託 Node.js（跨平台）
  - 安裝到 ~/.claude/skills/{domain-name}/
  - 相容 ECC 的目錄結構
  - 不衝突（domain skills 和 ECC skills 可以共存）
```

---

## Skill Map 規劃的具體方法（Builder 內部邏輯）

### 自動推導流程

```
1. 從領域名稱推導工作生命週期
2. 對標 gstack 的 7 個必選姿態
3. 判斷需要幾個規劃視角（策略/設計/工程）
4. 用三個缺口法找領域專屬 skill：
   - 審查缺口：通用 /review 抓不到的品質維度
   - 工作流缺口：專業人士日常做的、AI 能幫但通用工具做不到的
   - 交接缺口：步驟之間最容易掉東西的
5. 判斷需不需要入口 skill（外部素材匯入）
6. 每個候選 skill 過三個測試（獨立姿態/獨立產出/獨立觸發）
7. 數量檢查：15-25 個
8. 畫 artifact 流向
```

### 用戶缺某個 skill 的知識時

```
Builder 的處理順序：
1. 大模型直接產出（大部分情況夠用）
2. 問用戶：「你知道任何處理 X 的方法、工具、或框架嗎？」（輕量、不逼）
3. 如果用戶說不知道 → 用大模型版本，標進 upgrade backlog
4. 如果用戶說知道 → 協助整合進去

永遠不會因為用戶不知道而卡住。
```

---

## 升級（Step 3）的詳細設計

### 升級觸發

```
用戶主動觸發：
  「我想升級 /balance-review」
  「我有一個方法想加到 /script-review」
  「這個 gotcha 不對，我知道正確的」

Builder 建議觸發：
  Step 4 測試後：「/character-review 的判斷在測試中偏離最多，建議優先升級」

不觸發：
  Builder 不會主動說「你的 skill 不夠好，請提供經驗」
```

### 升級管道

| 用戶提供的 | Builder 做的 | 產出 |
|-----------|-------------|------|
| 現成 skill | 評估 fit → 替換或合併 | 升級後的 SKILL.md.tmpl |
| 代碼/PR | 分析判斷 pattern → 提取規則 | 填入對應 section |
| 文件/文章/框架 | 結構化讀取 → 轉成 skill 語言 | 填入對應 section |
| 口述經驗 | 在大模型版本基礎上改（不是從零問） | 修改對應 section |
| 「這裡不對」 | 用戶指出問題 → builder 修 | 修改對應部分 |

### 升級不需要完整

```
可以只改一行：
  「Day 7 retention benchmark 應該是 15% 不是 20%」
  → builder 改一個數字，done。

可以改一整個 section：
  「經濟平衡的整個評估框架我有更好的」
  → builder 讀用戶的框架，重寫整個 section。

可以替換整個 skill：
  「我有一個現成的 balance review prompt，比你生成的好」
  → builder 評估後替換。
```

### 升級效果評估（每次改動後的快速 check）

每次升級不是「改了就算升級」。Builder 在每次改動後做 3 問快速 check：

```
1. Workflow 更有用了嗎？
   這個改動讓 skill 在 workflow 裡的作用更清楚、產出更被下游需要了嗎？
   - Yes → ✅
   - No change → ⚠️ 不一定是壞事，但要注意
   - Worse → ❌ 改動可能破壞了串接

2. 判斷比 baseline 更準了嗎？
   改動後的判斷（gotchas / scoring / forcing questions）
   比大模型自動產出的版本更貼近實際工作嗎？
   - Yes → ✅（這是升級的核心價值）
   - Same → ⚠️ 改了但沒變好，考慮是否值得
   - Worse → ❌ 回退

3. 用戶跑一次會覺得更好嗎？
   從使用體驗看：互動更順、結果更有用、摩擦更少？
   - Yes → ✅
   - 沒測過 → 標記「待驗證」
   - No → ❌ 需要進一步調整
```

**3 個 ✅ = 升級成功。有 ❌ = 需要處理。有 ⚠️ = 記錄但不 block。**

**為什麼只有 3 問而不是 8 維 rubric：** 升級是高頻操作（用戶可能每天改一點）。太重的評估會拖慢迭代。3 問夠判斷方向，真正的品質靠 Step 4（Test）驗證。

---

## 設計哲學

### 搭建優先，完美其次

Step 2 產出的不是最好的 skill，但是完整的、可運行的、有 workflow 的。
這比 3 個完美 skill + 19 個空位有價值得多。

### 大模型能力是 default，不是 fallback

不是「用戶沒提供所以只好用大模型」。
是「大模型產出的就是基線，用戶的材料是加分項」。

### 用戶的時間花在刀刃上

```
值得用戶花時間的：
  ✅ 確認 skill map 的規劃
  ✅ 測試後的回饋
  ✅ 升級最重要的 2-3 個 skill

不值得用戶花時間的：
  ❌ 填寫每個 skill 的細節
  ❌ 回答 20 輪經驗訪談
  ❌ 學習 skill 架構
  ❌ 手動寫 YAML / template
```

### Complexity is not quality; fit is quality

一個大模型自動產出的 100 行 skill，在正確位置做正確的事，
比一個精心打磨的 700 行 skill 放在沒人用的位置有價值。

---

## 時間估算

```
Step 1（Plan）：10-30 分鐘用戶時間
  builder 推導 skill map → 用戶確認/修改

Step 2（Build）：builder 自動，用戶等
  預估 30-60 分鐘 CC 時間（根據 skill 數量）

Step 3（Upgrade）：可選，每個 skill 5-30 分鐘
  用戶想升級幾個就升級幾個

Step 4（Test）：30-60 分鐘
  用真實材料跑一次 first slice

Step 5（Iterate）：持續
  每次發現問題 → 5-15 分鐘修一個
```

**用戶從「我想做一個影劇 gstack」到「完整可用的 repo」：約 1-2 小時。**
其中用戶實際參與時間：約 30-60 分鐘（主要在 Step 1 和 Step 4）。

---

## Kernel vs Regime Boundary

### Kernel（跨領域可複用）

```
- gstack template engine
- preamble injection
- artifact discovery / save
- skill quality 快速評估
- upgrade pipeline（匯入 → 評估 → 替換/合併）
- test feedback → categorize → route
```

### Regime（Prismstack 專屬）

```
- 領域 → skill map 的推導邏輯
- 三個缺口法
- 三個測試
- 通用底盤的定義
- 大模型自動產出 skill 的 prompt 設計
- 領域詞彙自動生成
- 來源轉換 skills（各來源類型 → skill 的轉換邏輯）
- 傾聽需求的判斷邏輯（新 skill vs 現有 skill 改進 vs workflow 調整）
- 升級時的協助姿態設計
```

### Out of Scope

```
- marketplace / distribution
- 通用 builder kernel（先做 3 個領域再抽象）
- 自動把任何 repo 無損轉成 gstack
- 保證大模型產出的領域知識 100% 正確
- 替代領域專家
```

---

## 與 v0/v1 的差異

| | v0 | v1 | v2.2 |
|---|---|---|---|
| 核心定位 | 經驗提取 regime | demand-driven builder | **10-skill 持續服務搭建工具** |
| 用戶最少參與 | 需要大量訪談 | 需要提供材料 | 說出領域就能搭 |
| 大模型的角色 | 輔助提取 | 按需補缺 | **default 產出者** |
| 材料的角色 | 必要輸入 | demand-driven 填充 | **可選升級，任何來源都能轉** |
| 用戶經驗的角色 | 核心 | 重要但非必要 | **眾多來源之一** |
| Skill map 決策 | 用戶逐步確認 | 用戶按需確認 | **用戶一次確認** |
| Skill 細節 | 用戶填 | 用戶填 + 大模型補 | **大模型產出，用戶事後可改** |
| 搭完之後 | 交付結束 | 交付結束 | **持續傾聽、轉換、迭代** |
| 來源轉換 | 無 | 四條管道 | **`/source-convert` 專門 skill** |
| 工具打造 | 無 | 無 | **`/tool-builder` 包裝任何操作流程為 skill** |
| 品質檢查 | 無 | 無 | **`/skill-check` 三 mode：design / review / pack** |
| Builder 自身形態 | prompt | script | **10 個 gstack skills** |
| 完成標準 | judgment library | first slice | **完整可運行 repo + 持續演化** |
| 時間 | 多次對話 | 2-3 次對話 | **1-2 小時搭建 + 持續迭代** |
