# Skill 撰寫指南

> 用途：/domain-build 生成 skill、/skill-gen 新增 skill 時使用。
> 語境：你正在幫用戶生成一個可用的 gstack skill。

---

## 8 大原則

### 1. Trigger 先寫

description 不是介紹，是 routing 規則。Claude 靠它決定什麼時候建議這個 skill。

❌ `"A skill for reviewing quality."`
✅ `"Use when user wants numbers checked — difficulty curves, currency flow, progression pacing. Do NOT use when: visual design, narrative (use /design-review). Adjacent: /domain-review provides upstream findings."`

好的 description 包含：
- **When to use**（trigger conditions）
- **When NOT to use**（anti-trigger — 避免和相鄰 skill 混淆）
- **Adjacent skills**（上下游）

### 2. Skill = 工作姿態切換

不是知識包。啟動 skill 要改變 agent 的行為模式。

❌ 塞一堆參考資料讓 Claude 讀
✅ 定義一個尖銳的角色 — 一句話、不超過 15 字

```
❌ "You are a helpful assistant for reviewing designs."
✅ "You are an economy mathematician."
✅ "You are a player, not a reviewer."
✅ "You are a production accountant."
```

### 3. Flow 必須外化

越脆弱的工作，越不能靠 agent 記住流程。三種外部化方式：

| 方式 | 適用場景 |
|------|---------|
| Todo / checklist | 多步驟線性任務 |
| Phase / action loop | 多輪互動（review → fix → re-review） |
| Driver script / state file | 需要精確狀態追蹤的迴圈 |

❌ 靠 Claude 記住「我在第幾輪」
✅ 腳本處理狀態，Claude 只跟著 ACTION 走

### 4. Gotchas 是最高價值內容

模型已經知道一般做法。它不知道的是：
- 哪裡會炸
- 這個領域的禁忌
- 哪些字面上合理但實際上錯
- 哪些「看起來對」的輸出其實是諂媚

**Gotchas > 教學 > 理論。** Skill 裡最值錢的通常是：gotchas、anti-patterns、review criteria、recovery、guardrails。

### 5. 脆弱的地方要嚴格

不同任務需要不同自由度：

| 自由度 | 適用 |
|--------|------|
| **高** | 探索、構思、批判、brainstorm |
| **中** | 常規 spec / planning / diagnosis |
| **低** | PR review loop、deploy、migration、destructive ops |

低自由度 = 每步都有 STOP gate + completion protocol + 明確禁止清單。

### 6. 主 skill = 骨架，references = 細節

好的拆法：
- `SKILL.md`（~150-200 行）：角色、流程、規則、切換邏輯
- `references/`：gotchas、examples、scoring rubric、benchmarks、recovery、prompt templates

壞的拆法：
- ❌ 什麼都塞在 SKILL.md（>500 行 = 太重）
- ❌ 拆得太散，主 skill 沒導航能力

SKILL.md 用 `cat references/X.md` 指引 Claude 在需要時才讀。不預先載入所有東西。

### 7. 好 skill 定義 recovery

不只定義 happy path，也定義：
- 中斷了怎麼恢復（state reconstruction）
- 哪些錯可自修
- 哪些錯要升級（escalation）
- 怎麼判斷 done

### 8. Output 必須是下一步可讀的

❌ 完成時只產出一堆聊天文字
✅ 產出結構化 artifact：spec stack、review report、score card、design doc

輸出不是聊天回應，而是下一階段 workflow 的接口。必須包含：
- 檔名格式（`{type}-{datetime}.md`）
- 存放路徑
- Supersedes 修訂鏈（如果有先前版本）

### 9. Skill 必須經得起壓力測試

寫完 skill 不代表完成。必須測試 agent 在壓力下會不會繞過 skill 的規則。

**Skill TDD 三步：**

1. **RED** — 沒有 skill 的情況下讓 agent 跑一次同樣的任務。記錄：
   - 它跳過了哪些步驟？
   - 它的 rationalization 是什麼？（「這太簡單不需要」「我已經知道答案」）
   - 它在哪裡敷衍了？（給模糊讚美、跳過量化、不追問）
2. **GREEN** — 寫 skill 來修正 RED 階段觀察到的每一個失敗。每個 rationalization 對應一個防護：
   - 「這太簡單」→ 加 "No exceptions" 清單
   - 「我已經知道」→ 加 forcing question 要求 show work
   - 「整體不錯」→ 加 forbidden phrases + 逐維度打分要求
3. **REFACTOR** — 再跑一次，觀察 agent 有沒有找到新的繞過方式。有 → 回 GREEN 堵住。沒有 → 完成。

**Rationalization Prevention（寫進每個 skill）：**

每個 skill 應包含三個防護層：

| 層 | 做什麼 | 範例 |
|---|--------|------|
| **Red Flags 表** | 列出 agent 常見的「想繞過」念頭 | 「這個 skill 對這個情境太重了」→ 不行，skill 適用就要用 |
| **No Exceptions 清單** | 明確堵住常見的例外藉口 | 「簡單任務也要逐維度打分。沒有『太簡單所以跳過』。」 |
| **Forcing Commitments** | 要求 agent 在開始前宣告要做什麼 | 「開始 review 前，列出你將檢查的所有維度。」 |

**判斷標準：** 好的 skill 在 3 次壓力測試後 agent 的 rationalization 歸零。如果第 3 次還有新的繞過方式，skill 還需要加固。

---

## 5 種 Skill Template

### Review Type
- **角色**：尖銳的審查者（「你是經濟數學家」不是「你是 helper」）
- **結構**：Phase 0 context → Section 1-N review → each section STOP
- **Scoring**：量化公式（不靠直覺打分）— 權重 + 扣分標準
- **Anti-sycophancy**：forbidden phrases + forcing questions + push-back patterns
- **Gotchas**：Claude 在這個審查維度常犯的錯
- **Completion**：Health Score + STATUS + 下一步建議

### Bridge Type
- **角色**：轉譯者（連接兩個不同世界）
- **Input parsing**：偵測輸入格式、completeness audit
- **Translation logic**：從 A 格式到 B 格式的明確規則
- **Output contract**：下游 skill 需要的精確格式

### Production Type
- **角色**：建造者（讓東西出現）
- **Build target**：明確定義要產出什麼
- **Execution steps**：每步有可驗證的中間產出
- **Error handling**：build 失敗時的回退策略
- **Validation**：產出是否符合 spec

### Control Type
- **Routing table**：根據用戶狀態 → 建議哪個 skill
- **Health check**：檢查 skill 之間的串接是否正常
- **Conflict resolution**：多個 skill 都匹配時怎麼選

### Runtime Helper Type
- **角色**：工具專家（某個外部工具/API/CLI 的專精使用者）
- **Discovery phase**：偵測工具是否安裝、版本是否相容、auth 是否設定
- **Integration checklist**（每個外部工具必須驗證）：

  | 檢查項 | 要發現什麼 | 如何驗證 |
  |--------|-----------|---------|
  | 安裝 | 路徑、版本、依賴 | `which {tool}` + `{tool} --version` |
  | 認證 | API key / token / session | 發一個最簡單的 API call |
  | 速率限制 | 並發數、每分鐘、每日上限 | 讀文檔或實測 |
  | 錯誤分類 | 狀態碼、錯誤訊息 | 故意觸發已知錯誤 |
  | 未記載行為 | 隱藏 flag、實際 model 名稱 | Discovery loop（How-To 12）|
  | 輸出格式 | 下載 URL、檔案格式、有效期 | 實際跑一次完整操作 |

- **Workaround 文件**：每個未記載行為記為 gotcha
- **Fallback chain**（3 級降級）：
  1. 完整能力（工具正常運作）
  2. 降級能力（部分功能不可用，有替代方案）
  3. 阻斷（工具完全不可用，回報 BLOCKED）
- **Graceful degradation**：工具不可用時給明確安裝/修復指引

---

## 7 個結構 Pattern

### 1. Single-Role Identity
一句話鎖定角色，開頭就寫。不是「你可以做 A 也可以做 B」。

❌ "You are a helpful assistant that can review designs and also generate content."
✅ "You are a game design diagnostician. You diagnose, you don't treat."

### 2. Progressive Disclosure
SKILL.md 放骨架，references/ 放細節。Claude 需要時才讀。

❌ 一個 625 行的 SKILL.md
✅ 150 行 SKILL.md + 5 個 references/ 檔案

### 3. State via Files
不靠 Claude 記憶。用 todo、status table、driver script、output file 追蹤狀態。

❌ Claude 自己記住「我已經完成 3/7 個 section」
✅ TodoWrite 追蹤進度，每個 section 完成就更新

### 4. Gotchas = Highest Value
Claude 會犯的錯 + redirect pattern。每個 gotcha 有：Problem → Correct → Why Claude errs → Redirect → Example。

❌ 只寫「注意品質」
✅ 寫「Claude 傾向給出看起來合理的數字而不驗算。Redirect：要求每個數字都 show work。」

### 5. Mode Routing at Entry
入口鎖路徑。一個 skill 可以有多種模式，但在開頭就確定走哪條路。

❌ 走到一半才問「你要 review 還是 generate？」
✅ Step 0 就 parse args，確定 operation mode

### 6. Composability
Skill 呼叫 skill。Orchestrator skill 不自己做所有事——它調度其他 skill。

❌ 一個 skill 包辦所有步驟
✅ `/pipeline` 調度 `/plan` → `/action` → `/review`

### 7. Anti-Sycophancy 三層

**Layer 1: Forbidden phrases（deny list）**
```
❌ "That's an interesting approach"
❌ "There are many ways to think about this"
❌ "That could work"
```

**Layer 2: Forcing questions（不可逃避的逼問）**
```
"What's the strongest evidence that someone actually wants this —
not 'is interested,' but would be genuinely upset if it disappeared?"
```

**Layer 3: Push-back patterns（具體回話範例）**
```
❌ BAD: "That's a big market! Let's explore."
✅ GOOD: "There are 10,000 tools doing this. What specific task does
   a specific person waste 2+ hours/week on that yours eliminates?"
```

---

## Gotcha 格式

每個 gotcha 按此格式寫：

```markdown
### Gotcha: [Claude 會犯的錯]

**Problem**: Claude does [X] → [wrong result]
**Correct**: Should do [Y]
**Why Claude errs**: [LLM bias / training distribution / sycophancy]
**Redirect**: [在 prompt 裡寫什麼能修正]
**Example**:
  ❌ [Claude 的錯誤輸出]
  ✅ [正確輸出]
```

收集 gotchas 的來源（按價值排序）：
1. 實際跑 skill 時 Claude 犯的錯（最有價值）
2. 領域專家報告的「AI 常見誤解」
3. 社群回報的 issue

---

## Skill 骨架 Template

```markdown
---
name: <skill-name>
description: |
  Trigger: [when to use — 用戶說了什麼或在做什麼]
  Do NOT use when: [anti-trigger — 和哪些 skill 的邊界]
  Adjacent: [上下游 skill]
---

# /skill-name: <Role Name>

你現在是 <一句話尖銳角色>。
你的目標是 <one sentence>。

## Artifact Discovery
[搜尋先前產出的 bash block]

## Phase 0: Context
[讀文件 → 摘要確認 → AskUserQuestion 補缺失 context]
STOP. 等確認。

## Section 1-N: [Core Work]
[每 section 結尾: STOP + score + continue/back/forward/stop]

## Guardrails
- 常見誤判
- 明確禁止
- Escalation 條件

## Completion Summary
[量化評分 + STATUS + 下一步建議]

## Save Artifact
[存到標準路徑 + Supersedes 修訂鏈]
```

References 拆到 `references/`：gotchas.md, scoring.md, examples/, recovery.md, prompts.md

---

## Checklist（生成 skill 前跑）

- [ ] Trigger + anti-trigger 寫了？
- [ ] 角色是一句話尖銳的？
- [ ] 有 Phase 0 context confirmation？
- [ ] 有 STOP gates（每個 section 結尾）？
- [ ] 有 gotchas（Claude-specific，不是通用注意事項）？
- [ ] 有 artifact discovery（讀先前產出）？
- [ ] 有 save artifact（存到標準路徑）？
- [ ] 有 completion protocol（STATUS + 評分）？
- [ ] SKILL.md < 200 行？（超過 → 拆 references/）
- [ ] 下游 skill 能讀你的產出？
- [ ] 互動設計完整？（AskUserQuestion + section transitions + escape hatch）

---

## How-To：怎麼設計 Skill 的核心機制

> 以下是給代理的操作指令。生成 skill 時，對每個機制按照 how-to 設計，不是只列「要有」。

---

### How-To 1: 設計 Scoring Formula

**什麼時候用：** 生成 Review type skill 時，或任何需要量化判斷的 skill。

**步驟：**
1. 列出這個領域評判品質的 **3-7 個維度**
   - 問自己：「這個領域的專家看一個成品，他腦中的 checklist 有哪幾項？」
   - 例（廣告審查）：構圖、文字可讀性、品牌一致、色彩對比、CTA 清晰度
2. 每個維度定義 **0/1/2 標準**
   - 0 = 不存在或完全不及格（具體描述）
   - 1 = 有但不完整（具體描述）
   - 2 = 到位（具體描述，需要可引用的證據）
3. 給 **權重**
   - 最重要的維度 20-30%，次要 10-15%
   - 所有權重加總 100%
4. 定義 **門檻**
   - 幾分算 pass？幾分要 fix？幾分要重做？
   - 例：≥70% = pass, 50-69% = fix loop, <50% = 重做
5. 加 **校準錨點**
   - 舉一個拿滿分的例子長什麼樣（1-2 句）
   - 舉一個剛好 pass 的例子長什麼樣
   - 舉一個 fail 的例子長什麼樣

**❌ 不要：**
- 「AI 覺得 8/10」（沒有公式的直覺分）
- 所有維度同權重（一定有主次）
- 分數定義模糊（「好」「不好」不是標準）

**✅ 要：**
- 每個分數都能指向具體證據
- 公式寫在 skill 裡，不在 Claude 的腦中

---

### How-To 2: 找 Gotchas

**什麼時候用：** 生成任何 skill 時。

**步驟：**
1. **想像 Claude 第一次跑這個 skill**，它最可能犯什麼錯？
   - Claude 的通病：諂媚、跳過細節、給看似合理但未驗證的數字、預設最常見情境
2. **按領域找 Claude 的盲點：**
   - 行銷：Claude 會說「這個 campaign 有創意」而不指出目標受眾模糊
   - 教育：Claude 會設計偏向閱讀型學習，忽略動手操作
   - 遊戲：Claude 會預設 F2P 手遊，忽略平台差異
   - 工程：Claude 會跳過 error handling 說「基本架構完成」
3. **每個 gotcha 都要有 redirect：**
   - 不只說「Claude 會犯這個錯」
   - 要說「在 prompt 裡寫什麼能防止」

**生成 gotcha 的公式：**
```
領域 × Claude 通病 = Gotcha

Claude 通病清單：
- 諂媚（說好不說壞）
- 預設最常見情境（忽略邊界）
- 跳過驗算（給看起來對的數字）
- 正面框架（「用戶會喜歡」而不是中性觀察）
- 一口氣做完（不停下來問）
- 表面修復（改症狀不改根因）
```

**每個 skill 至少 3 個 gotchas，用 Gotcha 格式寫（見上方）。**

---

### How-To 3: 設計 Fix Loop

**什麼時候用：** 生成有審查/驗收功能的 skill 時。

**步驟：**
1. **定義什麼是 AUTO-FIX**（機械問題，有唯一正確答案）
   - 問自己：「這個修復有沒有判斷空間？」沒有 → AUTO-FIX
   - 例：缺少 YAML field → 加上（唯一答案）
   - 例：文字被圖片遮擋 → 調整位置（唯一方向）
2. **定義什麼是 ASK**（需要用戶判斷）
   - 問自己：「有兩種以上合理的修法嗎？」有 → ASK
   - 例：scoring 權重要改 → 改成多少？問用戶
3. **定義什麼是 ESCALATE**（不是修一個東西能解決的）
   - 問自己：「這個問題的根因在 skill 之外嗎？」是 → ESCALATE
   - 例：workflow 斷了 → 不是改 skill 能修的，要回去改架構
4. **設計安全閥**
   - AUTO-FIX 超過 N 個 → 停下來確認
   - 修了一個但別的變差 → 考慮 revert
   - ASK 太多 → 分批問
5. **設計 delta 報告**
   - 修復前分數（baseline）
   - 修復後分數（final）
   - 每個維度的變化

**模板（寫進 skill 裡）：**
```
## Fix Loop

審查發現問題時進入：

1. Baseline: 記錄當前分數
2. Triage:
   - AUTO-FIX: [列出這個 skill 的 auto-fix 範圍]
   - ASK: [列出需要用戶判斷的問題類型]
   - ESCALATE: [列出要上報的結構問題]
3. Fix: 按 severity 排序修復
4. Safety: [N] 個 auto-fix 後停下確認
5. Re-score: 重新打分
6. Report: baseline → final → delta
```

---

### How-To 4: 放 STOP Gates

**什麼時候用：** 生成任何多 phase 的 skill 時。

**規則：**
1. **每個 phase 結尾一定有** — 這是最低要求
2. **不可逆操作前加一個** — 寫檔案、刪東西、送出去
3. **長時間執行中間加** — 超過 5 分鐘的工作，每 5 分鐘停一次
4. **判斷分叉前加一個** — 走 A 路還是 B 路，問用戶

**STOP gate 的唯一正確寫法（已驗證）：**

```markdown
**STOP.** AskUserQuestion to confirm [什麼事]:

> [摘要：剛完成什麼 + 關鍵發現]
>
> RECOMMENDATION: Choose A — [理由]
>
> A) 繼續下一個 phase
> B) 回去調整
> C) 停在這裡

**One question only. Wait for answer before proceeding.**
```

**為什麼必須是這個格式：**
- `**STOP.**` — 模型辨識為停止點
- `AskUserQuestion to confirm` — 明確指示呼叫工具（不是印文字）
- `>` blockquote — 模型辨識為工具的 input
- 字母選項 `A) B) C)` — 映射成結構化 options
- `**One question only.**` — 防止模型一次問多題

**❌ 不可靠的格式（不要在 SKILL.md 裡用）：**
- `🛑 STOP Gate：AskUserQuestion` — 標題風格，模型當裝飾跳過
- `━━━ Phase 1 完成 ━━━` — 裝飾邊框，模型照印成文字
- `請確認：A. 繼續 B. 調整` — 文字風格，不會觸發工具呼叫
- 沒有 blockquote 的選項列表 — 模型不一定辨識為工具 input

**❌ 也不要：**
- 連跑 3 個 phase 不停
- STOP 了但沒有摘要（用戶不知道剛發生什麼）
- STOP 了但只有「繼續嗎？」（沒有選項）

詳見 `shared/ask-format.md` 的完整說明和範例。

---

### How-To 5: 設計 Anti-Sycophancy

**什麼時候用：** 生成任何有判斷功能的 skill 時。

**三層設計：**

**Layer 1 — Deny List（找領域空話）：**
- 問自己：「這個領域裡，什麼話聽起來正面但其實沒有資訊量？」
- 行銷：「這個 campaign 很有創意」「受眾很廣」
- 教育：「學生會很有興趣」「教學設計很完整」
- 遊戲：「玩法很有趣」「畫風很獨特」
- 每個 skill 列 5-10 個 forbidden phrases

**Layer 2 — Forcing Questions（設計逼問）：**
- 規則：不能是 yes/no 問題
- 規則：必須要求具體證據
- 模板：
  ```
  「[做出斷言] 的證據是什麼？不是感覺，是 [可量化/可觀察的指標]。」
  「如果把 [這個東西] 拿掉，會失去什麼？如果答不出來，它可能不需要。」
  「[這個判斷] 在 [極端情境] 下還成立嗎？」
  ```

**Layer 3 — Push-Back（追問模式）：**
- 第一次得到的答案通常是包裝過的
- 追問：「具體說——是哪個部分？」
- 再追問（if needed）：「最壞情況呢？」

---

### How-To 6: 寫 Forcing Questions

**什麼時候用：** 在 skill 的關鍵判斷點。

**好的 forcing question 的標準：**
1. **不可逃避** — 不能用「都可以」回答
2. **要求具體** — 不能用抽象概念回答
3. **暴露矛盾** — 如果有矛盾會被逼出來
4. **二選一或三選一** — 不是開放式

**模板：**
```
選擇型：「你的核心 hook 是 A 還是 B？你現在的 [X] 寫的是 A，但 [Y] 是 B 的語氣。要改哪個？」
證據型：「你說 [斷言]。最強的證據是什麼？不是『有人感興趣』，是 [具體可驗證的東西]。」
移除型：「如果把 [這個] 拿掉，workflow 會斷嗎？如果不會，它可能不需要獨立存在。」
極端型：「這個設計在 [10倍規模 / 最差情境 / 完全不同的用戶] 下還能用嗎？」
```

**每個 Review skill 至少 3 個 forcing questions，放在關鍵判斷點。**

---

### How-To 7: 設計 Recovery

**什麼時候用：** 生成任何多 phase 的 skill 時。

**步驟：**
1. **定義 state file** — 追蹤進度的檔案
   - 格式：markdown table 或 JSON
   - 位置：`~/.prismstack/projects/{slug}/.prismstack/` 或 skill 內部
   - 內容：每個 phase 的狀態（pending / done / in-progress）
2. **定義偵測點** — 怎麼知道上次做到哪
   - 檢查 state file
   - 檢查已產出的 artifact
   - 檢查 git log 最近的 commit
3. **定義恢復路徑** — 從偵測到的狀態繼續
   - 已完成的 phase → 跳過
   - 進行中的 phase → 從該 phase 重新開始
   - 已問過的問題 → 不重問（從 state file 讀答案）
4. **通知用戶**
   - 「偵測到上次的進度：Phase 1-3 已完成，Phase 4 進行中。要繼續還是重新開始？」

**模板：**
```
## 中斷恢復

1. 偵測：檢查 [state file] 或 [artifact] 是否存在
2. 已完成的 phase 不重做
3. 已回答的問題不重問
4. 告知用戶恢復狀態，確認繼續或重來
```

---

### How-To 8: 設計 Artifact Flow

**什麼時候用：** 生成任何需要上下游串接的 skill 時。

**步驟：**
1. **定義這個 skill 消費什麼**（upstream artifact）
   - 什麼類型的 artifact？
   - 從哪裡找？（`$_PROJECTS_DIR/*-{type}-*.md`）
   - 找不到怎麼辦？（BLOCKED / 問用戶 / 用預設值）
2. **定義這個 skill 產出什麼**（downstream artifact）
   - 檔名格式：`{user}-{branch}-{type}-{datetime}.md`
   - 存到 `~/.prismstack/projects/{slug}/`
   - 內容格式：下游 skill 能直接 parse 的結構
3. **定義 supersedes chain**
   - 如果有舊版 artifact → 新版頂部標記 `Supersedes: {old filename}`
4. **定義 next step**
   - 完成時推薦哪個下游 skill
   - 把推薦寫在 completion section

**Discovery 模板（寫進 skill 的 Phase 0）：**
```bash
_SLUG=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
_PROJECTS_DIR="${HOME}/.prismstack/projects/${_SLUG}"
_UPSTREAM=$(ls -t "$_PROJECTS_DIR"/*-{upstream-type}-*.md 2>/dev/null | head -1)
if [ -n "$_UPSTREAM" ]; then
  echo "Found upstream: $_UPSTREAM"
else
  echo "No upstream artifact found"
fi
```

**Save 模板（寫進 skill 的 Completion）：**
```bash
_OUT="$_PROJECTS_DIR/${_USER}-${_BRANCH}-{type}-$(date +%Y-%m-%d-%H%M).md"
# Write structured content to $_OUT
```

**❌ 不要：**
- 「把上一步的結果貼給我」（手動傳遞）
- 產出只在對話中，沒存檔案（下游讀不到）
- 存了但命名不規則（下游 glob 找不到）

---

### How-To 9: 辨識輸入品質並提取 Skill 規格

**什麼時候用：** 任何時候用戶提供 domain 資訊或 skill 需求——不管是一句話還是一份完整 spec。

**核心原則：不浪費用戶的輸入品質。用戶給多少，就提取多少。**

**4 級輸入品質：**

#### Level 1: Minimal（一句話）
用戶說：「我做行銷」

能提取的：
- 領域名稱
- （結束，靠 LLM 通識補其餘）

代理行為：用 skill-map-methodology 的公式自動推導。不追問。

#### Level 2: Moderate（幾句描述）
用戶說：「我做行銷，主要是社群廣告素材生產，團隊 5 個人，每週出 20 張圖 + 5 支影片」

能提取的：
- 領域：行銷
- 子領域：社群廣告素材
- 規模：5 人團隊
- 產出量：20 圖 / 5 影片 / 週
- 暗示的 skill 需求：素材生產、批量處理、團隊分配

代理行為：用提取的資訊調整 skill map（例如：增加 /batch-production skill，加 /task-dispatch skill）

#### Level 3: Detailed（段落或筆記）
用戶說：「審素材要看構圖、品牌一致、CTA 清晰度，其他不重要。之前有一批圖因為文字被角色頭髮擋住被退回。」

能提取的：
- **Scoring formula**：3 個維度（構圖、品牌一致、CTA）
- **權重暗示**：「其他不重要」= 這 3 個佔高權重（合計 ≥ 60%）
- **Gotcha**：文字被角色遮擋 → Claude-specific gotcha（Claude 生成構圖時常忽略文字區域）
- **Real case**：退回案例 → 可變成 forcing question

❌ 低 sensitivity（浪費）：把這些寫進 description 當說明文字
✅ 高 sensitivity（對等）：
  → 構圖 25% / 品牌一致 20% / CTA 清晰度 20% / 其他 35%
  → Gotcha: 「Claude 容易在角色構圖中忽略文字可讀性。Redirect: 生成後檢查所有文字區域是否被遮擋。」
  → Forcing Q: 「文字放在這個位置，縮到手機螢幕大小還看得到嗎？」

#### Level 4: Expert（完整 spec 或專業短語）
用戶給了一份 700 行的 spec，或是說：「ROAS 追蹤要看 D1/D3/D7 衰退曲線，CPM 超過 280 就要警告」

能提取的：
- **完整 skill 結構**（從 spec 的章節對應 skill 的 phases）
- **Domain benchmarks**（ROAS 衰退曲線、CPM 280 門檻）
- **Scoring calibration**（有具體數字 = 可直接寫進 scoring formula）
- **專家級 gotchas**（能產出 gotchas 的人 = 知道 Claude 會在哪裡犯錯）

代理行為：直接把用戶的結構當作 skill 結構的藍圖，不用自己推導。

### 提取規則

每次用戶提供輸入時，代理內部跑這個判斷：

```
1. 有沒有維度/指標/數字？
   → 有 → 提取為 scoring formula 的維度 + benchmarks

2. 有沒有「不要」「不重要」「要注意」？
   → 有 → 提取為 gotchas 或 anti-trigger 或權重暗示

3. 有沒有具體案例（成功或失敗）？
   → 有 → 提取為 gotcha（失敗）或 example（成功）

4. 有沒有流程描述（先做 X 再做 Y）？
   → 有 → 提取為 Phase 結構

5. 有沒有角色/人物提及（「主管審」「設計師做」）？
   → 有 → 提取為 skill 的 role identity 或 STOP gate 位置

6. 以上都沒有？
   → Level 1，用 LLM 通識補
```

### 關鍵：不追問，提取

❌ 用戶說「審素材看構圖、品牌、CTA」→ 代理問「那權重呢？門檻呢？」
✅ 用戶說同樣的話 → 代理提取 3 維度 + 推斷權重 → 呈現給用戶確認「我理解的對嗎？」

差異：不是問他答案，是給他你的解讀讓他確認。

---

### How-To 10: 品質對等生成（Proportional Output）

**什麼時候用：** /domain-build 生成 skill、/skill-gen 新增 skill 時。

**核心原則：用戶輸入品質 = skill 輸出品質。不浪費高品質輸入，不假裝低品質輸入能產出高品質。**

**對等標準：**

| 輸入品質 | 目標分數 | Scoring | Gotchas | Forcing Qs | Benchmarks |
|---------|---------|---------|---------|-----------|-----------|
| Level 1 (一句話) | 12-15/30 Draft | LLM 推測維度，通用權重 | 通識級（Claude 通病） | 通用逼問 | 無 |
| Level 2 (幾句描述) | 16-19/30 Draft+ | 從描述提取維度，推測權重 | 通識 + 從描述推斷的 1-2 個 | 從描述衍生 | 無或粗略 |
| Level 3 (段落/筆記) | 20-23/30 Usable | 用戶的維度 + 用戶暗示的權重 | 從案例提取 + 通識補充 | 從案例衍生 | 如果用戶提到數字就用 |
| Level 4 (完整 spec) | 24-28/30 Production | 用戶定義的完整公式 | 用戶的專業 + 通識補充 | 用戶的判斷點 | 用戶的數字 |

**每個品質級別具體生成什麼：**

#### Level 1 生成的 skill：
```
- YAML frontmatter: trigger + anti-trigger（LLM 推斷）
- Role: 通用角色（「你是 X 領域審查者」）
- Phases: 3-4 個（LLM 推斷的標準流程）
- Scoring: 通用維度，等權重
- Gotchas: 3 個 Claude 通病（諂媚、跳過驗算、預設常見情境）
- STOP gates: 每個 phase 結尾
- Completion: 標準格式
```

#### Level 3 生成的 skill（差異標記 ★）：
```
- YAML frontmatter: trigger + anti-trigger（★ 從用戶描述提取）
- Role: ★ 尖銳角色（從用戶的用語風格推斷）
- Phases: ★ 從用戶描述的流程提取
- Scoring: ★ 用戶的維度 + 從暗示推斷的權重
- Gotchas: ★ 從用戶案例提取 + Claude 通病
- Forcing Qs: ★ 從用戶的判斷點衍生
- STOP gates: ★ 在用戶提到的決策點放
- Completion: 標準格式 + ★ 用戶提到的下游
```

#### Level 4 生成的 skill（再多 ★★）：
```
- 所有 Level 3 的 +
- Scoring: ★★ 用戶定義的完整公式 + 校準基準
- Benchmarks: ★★ 用戶提供的數字
- Gotchas: ★★ 用戶的專業級 gotchas
- references/: ★★ 從 spec 拆出的詳細 section
- Fix loop: ★★ 從用戶的 QA 流程提取 AUTO-FIX 範圍
```

**誠實標記：**
生成 skill 後，在 completion 裡標記品質等級：
```
生成品質：Level 2 (Draft+, ~17/30)
  提升方式：提供更多 scoring 維度的細節 → 可達 Level 3 (Usable)
```

不要假裝 Level 1 輸入能產出 Production 品質。

---

### How-To 11: 設計 Companion Scripts（腳本層）

**何時 skill 需要 scripts/**：

判定樹：
- 涉及批次處理（>10 項任務）？→ 需要 queue script
- 呼叫外部 CLI 工具且有複雜 flag？→ 需要 wrapper script
- 有 poll-wait-retry 迴圈？→ 需要 polling engine
- 需要無 Claude 上下文的 headless 執行？→ 需要獨立 script
- 以上皆非？→ inline bash 足夠（不需要 scripts/）

**腳本類型與命名**：
```
{action}-engine.sh      — 長時間批次處理器（讀 queue.json，管理並行）
{action}-pipeline.py    — 多步驟資料轉換管線
queue-generator.sh      — 將 skill 參數轉為 queue.json
{tool}-wrapper.sh       — 外部 CLI 薄包裝（處理路徑、認證、錯誤翻譯）
```

**架構規則**：
- scripts 讀 queue.json、寫 batch-state.json（依 state-conventions.md）
- scripts 是純自動化 — 無 LLM 互動、無 AskUserQuestion
- scripts 寫 log 到 `{output_dir}/{script-name}.log`
- scripts 使用 exit code：0=成功、1=部分失敗、2=完全失敗
- SKILL.md 是編排者；scripts 是執行者

**SKILL.md ↔ scripts 生命週期**：
```
Phase N-1: 生成輸入資料（queue.json 或參數）
STOP gate: 用戶審查輸入
Phase N:   bash scripts/{script}.sh {args} — 委派給 script
Phase N+1: 讀取產出，摘要，評分
```

**Anti-patterns**：
- ❌ SKILL.md 內含 200 行 inline bash 做批次邏輯（移到 scripts/）
- ❌ script 呼叫 LLM API（scripts 只做確定性自動化）
- ❌ script 沒有 log（無法除錯）
- ❌ script 硬編碼領域路徑（用 preamble 的環境變數）
- ❌ inline bash 超過 50 行還不拆（移到 scripts/）

---

### How-To 12: 整合外部 CLI 工具

**Discovery Phase**（寫任何自動化之前先做）：
1. 安裝工具，驗證版本
2. 讀官方文檔（如果有的話）
3. 手動嘗試 3 個最基本操作
4. 記錄：完整指令、flag、輸出、錯誤訊息
5. 端到端測試認證流程

**Workaround 文件格式**：
```
### Workaround: [問題描述]
**官方文件說：** [文件宣稱的]
**實際情況：** [真正發生的]
**繞過方式：** [應該怎麼做]
**已驗證：** 是/否（日期）
```

**錯誤分類**：
- **Retriable**（網路逾時、速率限制）→ 自動重試 + 退避
- **Recoverable**（認證過期）→ 重新認證後重試
- **Content-Related**（內容審查攔截）→ 記錄、跳過、預期失敗（連結 How-To 13）
- **Fatal**（API 版本錯誤、工具移除）→ BLOCKED

**Integration Test Checklist**（宣告整合完成前跑一次）：
- [ ] Happy path 端到端成功
- [ ] 已知錯誤案例有處理
- [ ] 速率限制行為已記錄
- [ ] 認證重新整理已測試
- [ ] 並行使用已測試（如適用）
- [ ] 輸出下載/儲存已驗證

---

### How-To 13: 設計 Runtime Failure Budget

**何時使用：** 任何呼叫外部服務的 skill，且預期有一定比例的操作會失敗（內容審查、API 配額、平台限制）。

**Failure Budget 定義格式**：
```
## Failure Budget
預期失敗率：[X]%
失敗類型分佈：
  - 內容審查攔截：~[N]%（依內容類型變動）
  - API 逾時：~[N]%
  - 速率限制：~[N]%（由退避機制管理）

成本含廢公式：要得到 [M] 個成功產出，
需提交 [M ÷ (1 - 失敗率)] 個任務。

Fallback 策略：
  - 審查攔截 → [修改 prompt 重送 / 跳過 / 標記人工審查]
  - 逾時 → [自動重試最多 N 次]
  - 速率限制 → [排隊等待]
```

**整合到 skill 設計**：
- Production / Runtime Helper skill 若呼叫外部服務，**必須**宣告 Failure Budget
- queue-generator（How-To 11）生成佇列時需加入失敗餘量：目標 100 且失敗率 40% → 生成 167 個任務
- batch-state.json 追蹤實際失敗率 vs 預算失敗率
- 如果實際 > 預算 × 2：觸發 STOP gate — 有異常，先調查再繼續

**平台限制文件格式**：
```
## 平台限制
| 限制 | 影響 | 繞過方式 | 發現日期 |
|------|------|---------|---------|
| 內容類型 X 被擋 | ~N% 被拒 | 修改 prompt 避免 X | YYYY-MM-DD |
```

**成本估算模式**：
```
任務數：N
預期成功率：(1 - 失敗率)
每任務成本：$X
預期成功產出：N × 成功率
M 個成功產出的總成本：M ÷ 成功率 × $X
```

---

### How-To 14: 設計 A/B Experiment

**何時使用：** skill 有可調參數（prompt 格式、模型選擇、時長、風格），且不知道哪個值效果最好。

**實驗設計格式**：
```
## A/B Experiment: {參數名}

假設：{A} 在 {指標} 上會比 {B} 好
變體：
  A: {描述 + 具體值}
  B: {描述 + 具體值}
樣本數：{每組 N}（主觀評分最少 5，統計分析最少 20）
評估標準：
  主要：{指標}（由 {誰} 評分 0-2）
  次要：{指標}
控制：所有變體使用相同輸入內容
```

**實驗執行**：
1. 生成 queue.json，每個任務帶 `"variant": "A"` 或 `"B"` 標記
2. 透過 batch-engine 執行
3. 評分結果（人工或 skill 審查）
4. 比較：哪個變體在主要指標上勝出？
5. 記錄到 experiments.jsonl

**記錄格式（experiments.jsonl）**：
```json
{
  "ts": "2026-04-09T...",
  "skill": "/video-generate",
  "parameter": "prompt_format",
  "variant_a": "EN_time_coded",
  "variant_b": "CN_shotgen_prose",
  "sample_size": 10,
  "result": "a_wins",
  "metric": "visual_quality",
  "score_a": 1.6,
  "score_b": 1.1,
  "applied": true
}
```

**更新 skill 預設值**：
- 勝出變體成為 skill 的新預設
- 落敗變體記入 gotchas（「我們試過 X 但 Y 效果更好，因為 Z」）
- 實驗記錄保留在 experiments.jsonl 供未來參考

**與既有 skills 的整合**：
- /domain-upgrade Mode 2（Upgrade）應識別「想測試哪個比較好」為實驗觸發
- 不是新 skill — 是任何 Production 或 Runtime Helper skill 可採用的方法論
