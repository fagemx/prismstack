# Source Type Catalog

來源轉換支援的所有來源類型，以及對應的轉換方法。

---

## 來源類型一覽

| 來源類型 | 用戶怎麼給 | 轉換方法 |
|---------|-----------|---------|
| **Skill repo** | repo 路徑或 URL | 讀 SKILL.md → 評估 fit → 適配 preamble/artifact 格式 → 匯入或合併 |
| **現有 prompt** | 貼 prompt 或給檔案路徑 | 分析 prompt 結構 → 判斷是動作型還是判斷型 → 包裝成 SKILL.md |
| **YouTube / 影片** | URL 或貼逐字稿 | 提取方法論框架 → 轉成 dimensions / scoring / steps |
| **文章 / 部落格** | URL 或貼內容 | 提取判斷規則、checklist、framework → 填入對應 skill section |
| **書 / 方法論** | 描述書名 + 核心方法，或貼重點摘錄 | 提取可操作的判斷標準 → 轉成 gotchas / scoring / forcing questions |
| **SOP / 內部文件** | 給檔案 | 提取工作步驟 → 轉成 skill 流程 + 判斷點 |
| **代碼庫 / PR** | repo 路徑 | 分析 commit pattern / review style → 提取判斷標準和 gotchas |
| **用戶的想法** | 口述 | 幫用戶結構化 → 判斷是新 skill 還是現有 skill 的改進 → 產出 |
| **案例 / 失敗經驗** | 描述一個具體案例 | 轉成 gotcha 或 forcing question → 填入對應 skill |
| **ECC skill** | 指定 ECC skill 名稱或路徑 | 讀 SKILL.md → 加上互動設計 + 判斷邏輯 + 系統整合 → 適配 gstack 格式 |
| **Git history** | repo 路徑 | 分析 commit pattern / 重複工作模式 → 產出 skill |

---

## 各類型轉換要點

### Skill Repo

**識別信號：** 用戶提到 GitHub URL、repo 路徑、或 "skill" + "repo"。

**轉換步驟：**
1. 讀取 repo 的 SKILL.md（或等價檔案）
2. 評估是否符合 gstack 格式
3. 對比現有 skill map — 是否重疊
4. 適配：preamble YAML → gstack frontmatter，artifact 格式 → gstack 標準
5. 決定：匯入（獨立 skill）或合併（patch 進現有 skill）

**常見陷阱：** 外部 skill 的格式不同，不能直接 copy — 必須翻譯成 gstack 的語言。

### 現有 Prompt

**識別信號：** 用戶貼一段 prompt text、給 .txt/.md 路徑、或說「我有一個 prompt」。

**轉換步驟：**
1. 分析 prompt 結構（有沒有 role？有沒有步驟？有沒有判斷標準？）
2. 判斷類型：
   - 動作型 prompt（做某件事）→ Production skill
   - 判斷型 prompt（評估某件事）→ Review skill
   - 混合型 → 可能需要拆成多個 section
3. 提取核心邏輯 → 包裝成 SKILL.md 結構
4. 補充 prompt 缺少的：STOP gates、AskUserQuestion、gotchas

**常見陷阱：** prompt 通常沒有互動設計，不能直接包裝 — 要加上 gstack 的問答和判斷層。

### YouTube / 影片

**識別信號：** YouTube URL、影片連結、或用戶說「這個影片」。

**轉換步驟：**
1. 取得逐字稿（WebFetch 或用戶提供）
2. 忽略閒聊和例子，提取方法論骨架
3. 方法論 → dimensions（如果是評估型）或 steps（如果是流程型）
4. 具體例子 → gotchas 或 benchmarks
5. 金句 / 核心觀點 → forcing questions

**常見陷阱：** 影片內容通常比可用內容多 10 倍 — 不要全部都轉，只取核心方法論。

### 文章 / 部落格

**識別信號：** URL、用戶貼一段文字、或說「這篇文章」。

**轉換步驟：**
1. 讀取全文
2. 提取：規則（rules）、清單（checklists）、框架（frameworks）
3. 判斷屬於哪個 skill 的哪個 section
4. 翻譯成 gstack 格式（不是複製）

**常見陷阱：** 文章的格式已經很好看，容易讓人直接貼 — 但 skill 需要的是可操作的判斷邏輯，不是好讀的文字。

### 書 / 方法論

**識別信號：** 用戶提書名、貼書摘、或說「這本書的方法」。

**轉換步驟：**
1. 確認用戶提供的是哪些章節 / 概念
2. 提取可操作的判斷標準（不是理論）
3. 轉成：gotchas（具體的坑）、scoring（評分維度）、forcing questions（逼出判斷的問題）
4. 理論背景 → references/（Level 5）

**常見陷阱：** 書的理論很完整但不可操作 — skill 需要的是「遇到 X 情況，做 Y」，不是「X 的定義是...」。

### SOP / 內部文件

**識別信號：** 用戶給內部文件、流程圖、或說「我們的流程是...」。

**轉換步驟：**
1. 讀取 SOP 全文
2. 提取工作步驟序列
3. 識別判斷點（哪些步驟需要人的決策）
4. 步驟 → skill phases，判斷點 → STOP gates + AskUserQuestion
5. SOP 裡的例外處理 → gotchas

**常見陷阱：** SOP 通常寫給人看，步驟粒度對 AI 不適用 — 需要重新切分。

### 代碼庫 / PR

**識別信號：** repo 路徑、PR URL、或說「看看這個代碼」。

**轉換步驟：**
1. 分析 commit pattern（重複的工作是什麼？）
2. 分析 review comments（哪些判斷反覆出現？）
3. 提取判斷標準 → gotchas、review dimensions
4. 提取風格規範 → scoring criteria

**常見陷阱：** 代碼庫太大 — 只看最近 50 commits 和 open PRs，不要試圖全讀。

### 用戶的想法

**識別信號：** 用戶口述、描述一個想法、或說「我想要一個...」。

**轉換步驟：**
1. 聽完用戶描述
2. 結構化：這是什麼？觸發條件？產出？
3. 判斷：新 skill？還是現有 skill 的改進？
4. 如果是新 skill → hand off to /skill-gen
5. 如果是改進 → hand off to /skill-edit

**常見陷阱：** 用戶的想法通常不完整 — 需要追問，但不要過度追問到用戶失去興趣。

### 案例 / 失敗經驗

**識別信號：** 用戶描述一個具體事件、失敗、或說「上次...」。

**轉換步驟：**
1. 理解案例的完整脈絡
2. 提取教訓：什麼該做但沒做？什麼不該做但做了？
3. 轉成：gotcha（「當 X 時，注意 Y」）或 forcing question（「你確認過 Z 了嗎？」）
4. 判斷插入哪個 skill

**常見陷阱：** 案例通常帶情緒 — 要提取可操作的規則，不是記錄情緒。

### ECC Skill

**識別信號：** 用戶提到 ECC skill 名稱、或 ECC repo 路徑。

**轉換步驟：**
1. 讀 ECC SKILL.md
2. 提取知識和判斷邏輯
3. 加上 gstack 的互動設計（AskUserQuestion、STOP gates）
4. 加上系統整合（frontmatter、routing rules）
5. 適配 gstack artifact 格式

**常見陷阱：** ECC skill 通常沒有互動設計 — 不能直接搬，要加上人機互動層。

### Git History

**識別信號：** 用戶給 repo 路徑 + 想分析工作模式。

**轉換步驟：**
1. 讀最近 100 commits
2. 分析重複 pattern（什麼工作反覆做？）
3. 識別可自動化的判斷和步驟
4. 將 pattern 轉成 skill 的 phases 和 gotchas

**常見陷阱：** Git history 噪音多 — 要過濾出有意義的 pattern，不是統計 commit frequency。

### External Codebase / SDK

**識別信號：** 用戶指向一個外部工具的 source code、SDK repo、或 CLI codebase。

**轉換步驟：**
1. Clone 或讀取 codebase
2. 識別：公開 API 表面、CLI 指令、設定選項
3. 抽取供 skill 使用的部分：
   - 可用操作 → skill 的 phases 或 mode routing 選項
   - 設定選項 → skill 的 config 模式
   - 錯誤碼/訊息 → 錯誤分類用的 gotchas
   - 未記載行為（source vs docs 差異）→ workaround 文件
4. 產出：`references/{tool}-integration-guide.md`
5. 定位：通常是 Level 5（參考資產）或 Level 3（判斷修補）

**常見陷阱：** Codebase 通常很大 — 聚焦在公開 API 和錯誤處理，不深入內部實作。

### API Documentation

**識別信號：** 用戶提供 API docs URL、Swagger/OpenAPI spec、或 SDK readme。

**轉換步驟：**
1. 完整閱讀 API 文件
2. 抽取供 skill 使用的部分：
   - Endpoints → 可用操作
   - Auth 方式 → 設定指引
   - Rate limits → 並行約束
   - Error responses → 錯誤分類
   - Webhooks/callbacks → 非同步處理模式
3. 產出：`references/{api}-quickstart.md`，包含：
   - Auth 設定（逐步）
   - 核心操作（含已測試範例）
   - 已知限制
   - 錯誤處理指引
4. 定位：通常是 Level 5（參考資產），放在 `shared/references/`

**常見陷阱：** API 文件經常不完整或過時。從文件抽取後，
務必對照實際 API 行為驗證（標記未驗證項目）。
