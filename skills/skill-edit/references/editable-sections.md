# Editable Sections Map

skill 的每個部分都可以獨立編輯。這份文件告訴你每個 section 在哪、做什麼、怎麼改。

---

## Section Index

| Section | Location | What It Controls |
|---------|----------|-----------------|
| Role Identity | SKILL.md top (after frontmatter) | Working persona |
| Mode Routing | SKILL.md (entry section) | How args are parsed |
| Trigger Description | YAML frontmatter `description:` | When to use / not use |
| STOP Gates | SKILL.md (phase boundaries) | Where skill pauses for user |
| Scoring Formula | references/scoring.md or inline | How quality is measured |
| Gotchas | references/gotchas.md or inline section | Claude-specific pitfalls |
| Forcing Questions | SKILL.md (anti-sycophancy section) | Questions that force real judgment |
| Anti-Sycophancy | SKILL.md or references/ | Deny list + push-back rules |
| Domain Benchmarks | references/benchmarks.md | Reference data tables |
| Artifact Discovery | SKILL.md (Phase 0) | How upstream output is found |
| Output Contract | SKILL.md (completion section) | What artifact is saved + format |
| Workflow Position | YAML description + completion | Upstream/downstream neighbors |

---

## Section Details

### Role Identity
- **位置：** SKILL.md，frontmatter 結束後的第一個 heading + 段落
- **作用：** 定義 Claude 的工作姿勢（judge / builder / surgeon / etc.）
- **好的例子：** "You are a skill quality inspector. You judge, you don't build." — 明確角色邊界
- **壞的例子：** "You are a helpful assistant that works with skills." — 無差異化
- **常見修改：** 收窄角色範圍、加入「你不做什麼」的聲明

### Mode Routing
- **位置：** SKILL.md，通常在 Role 之後的 `## Mode Routing` section
- **作用：** 定義 args 如何被解析成不同工作模式
- **好的例子：** 明確的 pattern matching + fallback（沒有 args → AskUserQuestion）
- **壞的例子：** 只有一個 mode 但寫了 routing 邏輯
- **常見修改：** 新增模式、修改 fallback 行為、調整 arg parsing

### Trigger Description
- **位置：** YAML frontmatter 的 `description:` 欄位
- **作用：** Routing skill 用這個判斷要不要觸發此 skill
- **好的例子：** 包含 Trigger + Do NOT use when + 上下游 + 產出
- **壞的例子：** 只有功能描述，沒有觸發/排除條件
- **常見修改：** 加 "Do NOT use when" 規則、調整觸發詞

### STOP Gates
- **位置：** SKILL.md 每個 Phase 結尾的 `**STOP gate:**` 行
- **作用：** 強制 Claude 暫停、等用戶確認才繼續
- **好的例子：** "STOP gate: 確認已理解現有 domain context" — 有明確 checkpoint
- **壞的例子：** "STOP gate: 繼續？" — 不知道在確認什麼
- **常見修改：** 加 STOP gate（通常 Phase 0→1 之間）、移除過度打斷的 gate

### Scoring Formula
- **位置：** references/scoring.md 或 SKILL.md 內嵌
- **作用：** 定義品質分數如何計算
- **好的例子：** 每個維度 0-2 分，有明確的 0/1/2 標準 + 校準規則
- **壞的例子：** "Overall quality: High/Medium/Low" — 無法操作化
- **常見修改：** 調整維度權重、細化某維度的 0/1/2 標準、加校準防膨脹

### Gotchas
- **位置：** SKILL.md `## Gotchas` section 或 references/gotchas.md
- **作用：** 記錄 Claude 會犯的具體操作錯誤
- **格式：**
  ```
  **Problem:** Claude 做了 X
  **Correct approach:** 應該做 Y
  **Why Claude errs:** 因為 Z（訓練偏差/上下文丟失/etc.）
  **Redirect pattern:** 遇到 X 情境時，先做 A 再做 B
  **Example:**
    ❌ [bad output]
    ✅ [good output]
  ```
- **好的例子：** "Claude 傾向給所有維度 2/2" — 可觀察、可修正
- **壞的例子：** "Always validate input" — 不是 Claude 特有的問題
- **常見修改：** 新增 gotcha（最常見）、細化 redirect pattern

### Forcing Questions
- **位置：** SKILL.md anti-sycophancy section 或散布在各 Phase
- **作用：** 不能用 yes/no 回答的問題，強迫真判斷
- **好的例子：** "如果把這個拿掉，會失去什麼？" — 如果答案是「沒什麼」，就該刪
- **壞的例子：** "Is this good enough?" — yes/no 逃避
- **常見修改：** 替換無效問題、加入 domain-specific 挑戰

### Anti-Sycophancy
- **位置：** SKILL.md `## Anti-Sycophancy` section 或引用 shared/anti-sycophancy.md
- **作用：** 禁用空洞讚美 + push-back cadence
- **好的例子：** 具體 deny list + domain-adapted forcing questions
- **壞的例子：** 只說「be honest」
- **常見修改：** 擴充 deny list（加 domain-specific 空話）、調整 push-back 次數

### Domain Benchmarks
- **位置：** references/benchmarks.md
- **作用：** 提供具體數據讓 Claude 對比判斷
- **好的例子：** 行業標準數字、真實案例數據
- **壞的例子：** 模糊的 "industry average" 無具體數字
- **常見修改：** 更新數字、加新 benchmark category

### Artifact Discovery
- **位置：** SKILL.md Phase 0
- **作用：** 定義如何找到上游 skill 的產出
- **好的例子：** 明確的 Glob pattern + fallback（找不到怎麼辦）
- **壞的例子：** 假設 artifact 一定存在
- **常見修改：** 修正 Glob pattern、加 fallback 策略

### Output Contract
- **位置：** SKILL.md completion section
- **作用：** 定義這個 skill 產出什麼 + 格式
- **好的例子：** STATUS + artifact path + 推薦下一步 + 格式範例
- **壞的例子：** "Output the results" — 不知道存哪、什麼格式
- **常見修改：** 調整 artifact 命名、加必含欄位

### Workflow Position
- **位置：** YAML description（上游/下游）+ completion（推薦下一步）
- **作用：** 定義這個 skill 在 workflow 中的位置
- **好的例子：** 上游：/domain-plan 的 skill-map。下游：/skill-check review。
- **壞的例子：** 沒提上下游，或者上下游 artifact 對不上
- **常見修改：** 接入新的上游/下游、修正 artifact 流

---

## Edit Granularity Levels

從小到大，四個層級：

### Level 1: 改一行
- 範例：更新 benchmark 數字、修正 typo、改一個觸發詞
- 風險：極低
- 驗證：目視確認即可

### Level 2: 改一個 section
- 範例：重寫 scoring formula、加 3 條 gotchas、改 mode routing
- 風險：中等 — 可能影響上下游銜接
- 驗證：跑 /skill-check review 對改動的維度

### Level 3: 改整個 references/ 檔案
- 範例：重建 benchmarks.md、重寫 gotchas.md
- 風險：較高 — 如果 SKILL.md 引用了舊結構會斷
- 驗證：確認 SKILL.md 的引用路徑仍正確 + /skill-check review

### Level 4: 替換整個 skill
- 範例：完全重寫 SKILL.md + references/
- 風險：高 — 等於重建，用 /skill-gen 更合適
- 驗證：/skill-check review + /skill-check pack
- **建議：** 如果改動量 > 60% 的行數，改用 /skill-gen 重建
