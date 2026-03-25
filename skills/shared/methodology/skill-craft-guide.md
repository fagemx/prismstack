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
- **Runtime dependency**：需要什麼外部工具 / API / 腳本
- **Graceful degradation**：外部依賴不可用時怎麼辦

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
