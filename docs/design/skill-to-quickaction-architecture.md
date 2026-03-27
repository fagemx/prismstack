# Skill Stack → Quick Action 架構設計筆記

> 狀態：實驗階段，待測試驗證
> 日期：2026-03-26
> 來源：jimeng-auto + conversapix-edit 實務經驗歸納

---

## 核心洞見

**Skill stack 不是給用戶的。Skill stack 是給代理的裝備。**

用戶永遠在 UI 裡。正常時走模板。異常時代理帶著 skill stack 上場處理，結果一樣回到 UI。

---

## 三層架構

```
┌─────────────────────────────────────────────────┐
│  Layer 1: UI（用戶看到的）                        │
│  Quick Action 卡片 → 填坑 → 進度條 → 結果        │
│  templates.ts 配置驅動，不需要開發                 │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  Layer 2: 代理（處理變化的）                      │
│  Claude Code CLI / Claude API                    │
│  裝備了 skill stack，能處理超出模板的情況          │
│  STOP gate → SSE 事件 → UI 按鈕（不是對話）       │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  Layer 3: Skill Stack（代理的工具箱）             │
│  SKILL.md 定義規則、gotchas、scoring              │
│  references/ 定義領域知識                         │
│  artifact flow 定義 pipeline 順序                 │
│  用戶完全看不到這一層                             │
└─────────────────────────────────────────────────┘
```

---

## 兩種模式的分工

### 模板模式（90% 的時間）

```
UI → 填欄位 → TS 小工具直接跑 → 成品
```

- 固定流程，不需要判斷
- 快、便宜、可預測
- 就是現有的 Quick Action（RunningHub / OpenRouter provider）

### 代理模式（10% — 出問題 / 有變化 / 超出模板時）

```
UI → 代理（帶 skill stack）→ 處理 → 成品回 UI
```

觸發時機：
- 批量生成時需要條件替換（「這批要換風格」「第3支跳過博奕元素」）
- 審查描述的多樣性不足（shot-review 的工作）
- 生成結果不符預期，需要修改再重跑（repair loop）
- 任何超出固定欄位能處理的動態需求

---

## Quick Action 卡片 = Pipeline，不是 Skill

```
一張卡片 = 一條完整 pipeline

「影片廣告生產」卡片
  provider: 'agent-pipeline'
  pipeline: extract → breakdown → performance → shotgen → review → generate

  用戶看到：一張卡片 + 進度條 + 幾個確認按鈕
  代理在背後：自動跑 pipeline，用 skill stack 處理每一步
```

Skill 多不是問題 — 用戶根本看不到 skill。用戶看到的是卡片。

---

## 用戶的體驗

```
正常：
  按下卡片 → 上傳 Excel → 選參數 → 等 → 拿成品
  （跟「萬物聖誕節」一樣簡單）

有變化：
  按下卡片 → 上傳 → 跑到一半 → UI 彈出選項：
  「鏡頭 2 和 3 場景重複，要：A) 自動調整 B) 手動指定場景 C) 跳過」
  → 點 A → 繼續跑 → 拿成品

出問題：
  代理自動處理（gotchas、fix loop）
  用戶甚至不知道出過問題
```

**用戶不需要知道 skill 是什麼。不需要會 AI 對話。不需要看 terminal。**

---

## 技術銜接點

### 已有基礎（conversapix-edit）

- Quick Action 卡片系統（templates.ts 配置驅動）
- Provider 路由（RunningHub / OpenRouter，可擴展）
- SSE 事件流（pipeline 進度推送）
- 結果顯示 UI（圖片/音頻/視頻）

### 需要建的

1. **新 provider type**: `'agent-pipeline'`
   - 後端收到 → 啟動代理（Claude Code CLI spawn 或 Claude API call）
   - 代理載入指定的 skill stack
   - STOP gate → 轉成 SSE 事件 → 前端顯示選項按鈕
   - 用戶選擇 → 回傳代理 → 繼續

2. **Pipeline 配置格式**
   ```typescript
   {
     provider: 'agent-pipeline',
     pipelineConfig: {
       skills: ['extract-scripts', 'script-breakdown', 'shotgen', ...],
       // 或者不指定 skill，讓代理自己判斷（更靈活但更貴）
       skillStackPath: '/path/to/jimeng-auto/skills/',
       entrySkill: 'video-produce',  // triage entry
     }
   }
   ```

3. **STOP gate → UI 按鈕的映射**
   - AskUserQuestion 四段格式 → SSE 事件
   - Options A/B/C/D → UI 按鈕
   - 用戶點擊 → 回傳代理

4. **呼叫代理的方式**（三選一，待測試）
   | 方式 | 優點 | 缺點 |
   |------|------|------|
   | `claude -p` CLI spawn | 最簡單，現在就能用 | 依賴 Claude Code 安裝 |
   | Claude API + system prompt | 最穩定，TS 直接整合 | 需要把 SKILL.md 壓成 prompt |
   | Claude Code SDK | Agent 能力最完整 | 較新，文件少 |

---

## 成本模型

| 流程 | 走什麼 | 成本 |
|------|--------|------|
| 固定批量生成 | TS 模板 | ~0（不過 AI） |
| 需要判斷的 pipeline | 代理 + skill stack | Claude API token |
| 只有 STOP gate 選擇 | 代理跑、用戶點按鈕 | 中等（代理跑但互動少） |
| 完整動態互動 | 代理 + 多輪 STOP gate | 較高 |

**關鍵：不是每次都過代理。固定的用 TS，動態的才呼叫代理。**

---

## 與 Prismstack 的關係

Prismstack 產出的 skill stack 是代理的裝備。Prismstack 不需要知道 UI 的事。

```
Prismstack（建 skill stack 的工具）
  ↓ 產出
Skill Stack（代理的裝備）
  ↓ 被裝備
代理（Claude Code / Claude API）
  ↓ 被呼叫
Quick Action 卡片系統（UI 層）
  ↓ 被使用
團隊成員（按按鈕的人）
```

Prismstack 的價值：讓「建代理裝備」這件事系統化、可維護、有品質保證。

---

## 產業趨勢對齊：AI-Native Tool Layer

> 來源：2026-03-26 X 討論串（天猪 @atian25）+ OpenAI Codex PR #15276
> 核心命題：Bash 和 Markdown 是人類時代的過渡方案，AI 時代需要原生結構化的工具層和上下文格式。

### Anthropic 收購 Bun 的真正原因

不是為了 CLI 效能，不是為了 JS 沙箱。是為了 **重新定義 Agent 的工具層**：

1. 用 Bun 重新實現常用 Bash 命令 → 從底層約定結構化輸出規範
2. 用這套工具鏈訓練模型 → 模型精通這套結構化工具
3. Bun 的 JS 沙箱變成安全執行環境 → 所有 Agent 操作在沙箱內

### Codex PR #15276 做的是同一件事

把 Code Mode 從外部 Node.js 進程（stdin/stdout JSON protocol）換成嵌入式 V8（Rust channels + callbacks）。

```
舊：Agent → spawn Node.js → 解析 stdout 文字 → 猜測狀態
新：Agent → 嵌入 V8 → Rust channel 結構化通訊 → 精確狀態
```

不再解析文字。直接結構化通訊。

### 三層對應

| 層次 | 人類時代 | AI 時代 | 誰在做 |
|------|---------|---------|--------|
| Runtime | Node.js 外部進程 | V8 嵌入 Rust | Codex PR #15276 |
| Tool layer | Bash（文字輸出） | Bun 重新實現（結構化輸出） | Anthropic 收購 Bun |
| Context format | Markdown（人類可讀） | AI-native format（模型可訓練） | 未來趨勢 |

### stdin 沒有事件的問題

天猪指出：Bash 的 stdin 沒有事件機制，AI 只能輪詢 stdout 判斷狀態。做過 Coding Agent 的都遇到過 `vite init` 卡住的問題。isTTY 不治本。

**我們的 STOP gate → SSE → UI 按鈕 就是應用層的解法**：不讓用戶解析 AI 的文字輸出，而是把 AI 的決策點變成結構化 SSE 事件，推到 UI 變成按鈕。

### 與本架構的對齊

```
天猪的論點                          我們的架構
──────────                          ──────────
Bash 為人類設計                     CLI skill 對話為人類設計
AI 需要結構化工具                   代理需要結構化 skill stack
用 Bun 重新實現命令                 用 SKILL.md 定義結構化規則
結構化輸出規範                      artifact flow + types.ts 契約
模型理解力 > 格式簡單性             SKILL.md 可以複雜（給模型讀的）
                                    UI 必須簡單（給人類用的）
                                    代理是翻譯層
```

**SKILL.md 不需要簡單** — 它是 AI-native 的工具定義，給模型讀的。可以有 gotchas、7 維度表演設計、15D 品質評分。模型能處理。

**UI 需要簡單** — 它是 human-native 的操作介面。一張卡片、幾個按鈕。

**代理是翻譯層** — 把 AI-native 的 skill stack 翻譯成 human-native 的 UI 事件。

### 天猪的預測

「只要一個格式能被模型完整訓練和學習到，AI 就有能力處理好它的全部 edge case。格式的簡單性不再是硬約束，模型的理解力才是。」

意味著：未來 SKILL.md 的格式可以更豐富（不只 Markdown），artifact 的契約可以更嚴格（不只路徑約定），只要模型能訓練到。Markdown 和 Bash 是過渡期的最佳選擇，但不是終點。

---

## POC 驗證結果（2026-03-27）

### 測試方案

用 `claude -p` + `--output-format stream-json --verbose` spawn Claude Code CLI 作為子進程。
解析 stream-json 的逐行 JSON 事件，攔截 AskUserQuestion tool call。
用 `--resume <session_id>` 送回用戶選擇，繼續執行。

POC 程式碼：`C:\ai_project\jimeng-auto\src\agent-poc.mjs`

### 測試結果

**Skill**: /script-breakdown（腳本拆解師）
**輸入**: 「宮女進宮後被懲罰的搞笑廣告」，6鏡頭，ad_short，--skip-assets --skip-performance

```
Turn 1:
  claude -p "讀 SKILL.md 並執行拆鏡..." --output-format stream-json --verbose
  → 模型讀取 SKILL.md（8900 chars）
  → 執行 Phase 1 拆鏡（6 個鏡頭）
  → 到 STOP gate → 呼叫 AskUserQuestion
  → stream-json 攔截到完整結構：
    {
      header: "Phase 1",
      question: "[Re-ground]...[Simplify]...RECOMMENDATION: 選 A...",
      options: [
        { label: "A) 繼續 (Recommended)", description: "..." },
        { label: "B) 調整鏡頭數量", description: "..." },
        { label: "C) 修改某個鏡頭", description: "..." },
        { label: "D) 先停在這裡", description: "..." }
      ]
    }
  → 拿到 session_id: e5a61897-...
  → Tokens: input=8, output=1845
  → Tool calls: Read, Read, ToolSearch, AskUserQuestion

Turn 2:
  claude -p "A" --resume e5a61897-... --output-format stream-json --verbose
  → 模型接續 Phase 2 增強（對白 + 文字設計 + 敘事優化）
  → 產出完整的分析報告 JSON + 對白表 + 文字設計表
  → 到 STOP gate → 再次呼叫 AskUserQuestion
  → 結構同樣完整，options 映射到 Phase 2 的選擇
  → 同一 session_id，可繼續 --resume
  → Tokens: input=4, output=2630

Turn 3（可執行，未實測）:
  --resume + "A" → 輸出最終 artifact → pipeline 完成
```

### 驗證結論

| 假設 | 結果 | 備註 |
|------|------|------|
| claude -p 能讀 SKILL.md 規則並遵循 | ✅ | 完整遵循 Phase 結構、STOP gate、skip flags |
| stream-json 能攔截 AskUserQuestion | ✅ | header + question + options 完整結構化 |
| --resume 能續跑同一 session | ✅ | Phase 1 → Phase 2 無縫銜接，context 保留 |
| AskUserQuestion options 可映射成 UI 按鈕 | ✅ | label + description，直接可渲染 |
| 用訂閱制 CLI，不用 API token | ✅ | 零額外費用 |
| 模型遵循四段格式（Re-ground, Simplify, Recommend） | ✅ | 因為 SKILL.md 的 shared/ask-format.md 有指引 |

### 關鍵發現

1. **AskUserQuestion 是原生 Claude Code 工具** — 不需要自定義 tool，模型直接會呼叫它。輸出結構是 `{ questions: [{ header, question, options: [{ label, description }] }] }`。

2. **stream-json 事件類型**：`assistant`（含 tool_use blocks）和 `result`（含 session_id + usage）。AskUserQuestion 出現在 `assistant.message.content` 的 `tool_use` block 中。

3. **session_id 跨 turn 不變** — 整條 pipeline 是同一個 session，context 自動累積。

4. **模型會主動搜尋工具** — Turn 1 中模型呼叫了 `ToolSearch` 來找 AskUserQuestion 工具，說明它在積極嘗試遵循 SKILL.md 的互動指令。

### Phase B 驗證：Express Pipeline Server（2026-03-27）

**已建置**：`C:\ai_project\jimeng-auto\src\server/`（pipeline-runner.mjs + index.mjs）

**Express endpoint 測試**：

```
curl POST /api/pipeline/start
  body: { ads: ["PR001"], excel: "...", type: "image", flags: ["--no-generate"] }
  ↓
Express spawn claude -p → 讀 ad-pipeline/SKILL.md → 跑 pipeline
  ↓
SSE 事件流：
  event: tool_use    → Read SKILL.md, Glob, Read cache
  event: text        → Phase 1 Extract 完成
  event: phase       → { phase: 1 }
  event: status_table → 完整狀態表
  event: tool_use    → ToolSearch (找 AskUserQuestion)
  event: stop_gate   → { toolName: "AskUserQuestion", input: { questions: [...] } }
  event: result      → sessionId + usage
  event: close       → exit code 0
```

**STOP gate 可靠觸發的關鍵修正**：

SKILL.md 中的 STOP gate 語法從：
```
🛑 STOP Gate：AskUserQuestion
> A) 選項...
```
改成 gstack 的可靠模式：
```
**STOP.** AskUserQuestion to confirm XXX:
> question text + RECOMMENDATION
> A) option  B) option  C) option
**One question only. Wait for answer before proceeding.**
```

`**STOP.**` + blockquote + 字母選項 = 模型可靠呼叫 AskUserQuestion 工具。

**Resume 測試**（POC v3 已驗證）：
```
curl POST /api/pipeline/respond
  body: { sessionId: "058579af-...", choice: "A" }
  → Phase 3 sub-agent 啟動
  → 讀 ad-prompt/SKILL.md + ad-layout-blueprint references
  → 產出完整 prompt → Write 到 pipeline/ad-prompts/PR001-jimeng.txt
```

**ad-pipeline 完整測試**（之前手動跑通）：
```
Pipeline 測試結果：
  輸入：2 支圖片廣告
  Phase 1 Extract:  2/2 ✅
  Phase 3 Produce:  2/2 ✅ (PR003 第一輪 FAIL，重做後通過)
  Phase 4 Gate:     2/2 ✅ PASS
  Phase 5 Fix:      PR003 用了 1 輪修正
  Phase 6 Generate: 2/2 ✅ 各 4 張圖片
  成品：8 張圖片在 output/
```

### 未驗證（下一步）

1. [x] ~~多 skill pipeline（編排 → 串多個 skill 的 sub-agent）~~ ✅ ad-pipeline 已跑通
2. [x] ~~把 spawn + parse + resume 包進 Express endpoint~~ ✅ src/server/
3. [x] ~~Express → SSE 事件流~~ ✅ stop_gate + phase + status_table + text + result
4. [ ] Quick Action 卡片觸發 Express endpoint（接 conversapix-edit 前端）
5. [ ] 批量模式（多個腳本並行跑 pipeline）
6. [ ] 哪些步驟可以用 TS 跑（不過代理）
7. [ ] 混合模式切換
8. [ ] 影片 pipeline 端到端測試

### 已有參考架構

**karvi issue-pipeline**（`C:\ai_agent\karvi\.claude\skills\issue-pipeline`）已驗證：
- 一個編排 skill 可以 spawn 多個 sub-agent（各帶不同 skill）
- worktree isolation 實現並行
- phase barrier（等全部完成才進下一 phase）
- --z.ai flag 可切換到 Karvi server dispatch（不同 runtime）

**karvi dispatch**（`C:\ai_agent\karvi\.claude\skills\dispatch`）已驗證：
- 多 runtime 支援（claude / opencode / codex / openai-api）
- CLI 和 curl 兩種觸發方式
- cross-project dispatch
- model selection chain

**CodePilot**（`C:\ai_project\CodePilot`）已驗證：
- Claude Agent SDK + SSE streaming 完整實現
- permission_request → UI 按鈕（= STOP gate → UI 按鈕）
- IM bridge（Telegram/飛書 inline buttons = 遠端 STOP gate 按鈕）
- stream-session-manager 解耦串流生命週期和 UI 組件生命週期

### 推薦的實現路徑

```
Phase A（已完成）: POC 驗證 — spawn + stream-json + AskUserQuestion 攔截 ✅

Phase B: Express 包裝
  - 把 agent-poc.mjs 的 spawn/parse/resume 邏輯包成 Express endpoint
  - /api/agent-pipeline/start → spawn claude -p → 返回 SSE stream
  - /api/agent-pipeline/respond → --resume + 用戶選擇 → 返回 SSE stream
  - 參考 CodePilot 的 stream-session-manager 模式

Phase C: Quick Action 整合
  - conversapix-edit 的 templates.ts 加新 provider: 'agent-pipeline'
  - 前端：AskUserQuestion options → 按鈕組件
  - 前端：串流文字 → 進度顯示

Phase D: Pipeline 編排
  - video-produce skill 改成編排層（參考 karvi issue-pipeline）
  - 一張卡片觸發整條 pipeline
  - 每個 STOP gate 回到 UI

Phase E: 混合模式
  - 固定步驟用 TS（extract-scripts 的 Excel 讀取）
  - 判斷步驟用代理（shot-review 的多樣性審查）
  - 路由邏輯在 Express 層決定
```

---

## 待測試（更新 2026-03-27 final）

1. [x] ~~Claude Code CLI spawn 能不能穩定跑 skill pipeline？~~ ✅ 已驗證
2. [x] ~~STOP gate 的 AskUserQuestion 能不能攔截？~~ ✅ 已驗證，結構完整
3. [x] ~~--resume 能不能續跑？~~ ✅ 已驗證，session 跨 turn 保持
4. [x] ~~多 skill pipeline 編排~~ ✅ ad-pipeline 跑通（2 支圖片，8 張成品）
5. [x] ~~Express endpoint 包裝 + SSE 推送~~ ✅ src/server/，stop_gate 事件完整
6. [x] ~~STOP gate 可靠觸發~~ ✅ `**STOP.**` gstack 語法 + ToolSearch 自動找到工具
7. [x] ~~pipeline-gateway 獨立服務~~ ✅ Bun + bun:sqlite，5/5 測試通過
8. [x] ~~Quick Action 卡片觸發 agent pipeline~~ ✅ conversapix-edit 已接入 PipelineGatewayPanel
9. [ ] 端到端測試（conversapix-edit UI → gateway → claude → 即夢 → 成品回 UI）
10. [ ] 批量模式和並行執行
11. [ ] TS / 代理混合模式切換
12. [ ] 影片 pipeline 端到端測試
13. ~~[ ] Claude API + SKILL.md 壓縮成 system prompt？~~ → 不需要，直接用 CLI 訂閱制

---

## 相關參考

- conversapix-edit Quick Action 部署指南：`docs/2025/1215/QUICK_ACTION部署指南.md`
- conversapix-edit OpenRouter 部署指南：`docs/2025/1215/QUICK_ACTION_OPENROUTER部署指南.md`
- conversapix-edit ad-layout service（skill → TS service 的重量級做法）：`server/services/ad-layout/`
- jimeng-auto skill stack：`skills/` 目錄（11 個 skill + shared/）
- jimeng-auto POC：`src/agent-poc.mjs`
- karvi issue-pipeline（pipeline 編排參考）：`C:\ai_agent\karvi\.claude\skills\issue-pipeline`
- karvi dispatch（多 runtime 調度參考）：`C:\ai_agent\karvi\.claude\skills\dispatch`
- CodePilot（Agent SDK + SSE + permission flow 參考）：`C:\ai_project\CodePilot`
- Prismstack brownfield mode：`skills/domain-plan/SKILL.md`（Brownfield Path 章節）
