# Skill 類型模板指南

> 根據 skill 類型生成對應結構。
> 遵循 8 大寫作原則（skill-writing-doctrine）。

---

## 通用 YAML Frontmatter

所有類型的 skill 都必須包含：

```yaml
---
name: {skill-name}
version: 0.1.0
origin: prismstack-generated
description: |
  {一句話說明做什麼}
  Trigger: {何時用 + 用戶會怎麼說}
  Do NOT use when: {何時不用 + 應該用什麼替代}
  上游: {哪些 skill 的產出是我的輸入}
  下游: {我的產出給誰用}
  產出: {artifact 命名 pattern}
allowed-tools:
  - [依據類型選擇]
---
```

**description 是 routing rule，不是功能摘要。**（原則 1）

---

## 8 大寫作原則速查

1. **先寫 trigger** — description 決定 skill 被觸發的準確度
2. **Skill = 工作姿勢** — 不是知識包，是行為模式切換器
3. **流程外部化** — TodoWrite / driver / status table，不靠記憶
4. **最高價值 = gotchas** — Claude 不知道的坑比教學有用 10 倍
5. **該死板就死板** — 高風險操作用低自由度
6. **主 skill = 骨架** — SKILL.md < 200 行，細節放 references/
7. **好 skill 定義 recovery** — 中斷後怎麼恢復、哪些錯可自修
8. **輸出必須可接下一步** — 不是聊天回應，是下游 workflow 的接口

---

## Type 1: Review（審查型）

**用途：** 審查某種 artifact 的品質，產出評分 + 改善建議。
**allowed-tools:** `Read`, `Glob`, `Grep`, `Write`, `AskUserQuestion`

### 模板結構

```markdown
# {Role Name}

你是 {一句話角色定義 — 例：「遊戲經濟數學家 — 用數字說話，不用感覺」}。

## Mode Routing

解析參數：
- `{skill} {target}` → 審查指定 artifact
- `{skill} compare {a} {b}` → 比較兩版
- 無參數 → AskUserQuestion 詢問

## Phase 0: Artifact Discovery

搜尋上游 artifact：
- `~/.gstack/projects/{slug}/{upstream-type}-*.md` — 取最新
- 讀取上次 review 紀錄（如果有）
- STOP: 找不到 artifact → STATUS: BLOCKED

## Phase 1-N: 審查維度

每個維度：
1. 維度名稱 + 定義
2. 評分公式（明確，例：`完整性 = 已覆蓋面向 / 必要面向 × 10`）
3. 0/5/10 基準說明
4. STOP gate: 此維度有 P0 問題 → 呈現問題 → 等用戶確認才繼續

## Scoring

```
{維度1} ×{權重} = _
{維度2} ×{權重} = _
...
加權總分 = _ / 100
```

門檻：
- ≥70 = PASS（可進下游）
- 50-69 = CONDITIONAL（列修改項）
- <50 = FAIL（重做）

## Anti-Sycophancy

禁止用語：
- ❌ "整體來說做得不錯"
- ❌ "有一些小問題"
- ❌ "{領域}方面很有想法"

Forcing questions（每次 review 至少問一個）：
- "如果這個 {artifact} 明天上線，最先出事的是哪裡？"
- "這裡面最弱的假設是什麼？"

## Gotchas

（拆到 references/gotchas.md，SKILL.md 只放 3 條最關鍵的）

## Completion

STATUS: DONE
- 總分: {score}/100
- P0 issues: {count}
- 產出: `~/.gstack/projects/{slug}/{type}-review-{datetime}.md`
- 推薦下一步: {downstream skill}
```

---

## Type 2: Bridge（橋接型）

**用途：** 讀取上游 artifact，轉換格式，產出下游可讀的 artifact。
**allowed-tools:** `Read`, `Write`, `Glob`, `Grep`, `Bash`, `AskUserQuestion`

### 模板結構

```markdown
# {Role Name}

你是 {格式轉換專家 — 例：「劇本格式標準化工程師」}。

## Input Parsing

輸入來源：
- 檔案路徑（用戶提供）
- 上游 artifact（自動搜尋 `~/.gstack/projects/{slug}/{type}-*.md`）
- 剪貼簿內容（用戶貼入）

支援格式：{列出所有支援的輸入格式}

STOP: 無法辨識輸入格式 → 詢問用戶

## Translation Logic

轉換規則：
1. {輸入欄位 A} → {輸出欄位 X}
2. {輸入欄位 B} → {輸出欄位 Y}
3. 缺失欄位 → 用 AskUserQuestion 補充 / 標記 [TODO]

不可遺失的欄位：{列出}
可選欄位：{列出}

## STOP Gates

- 必要欄位缺失 > 3 個 → STOP，呈現缺失清單
- 輸入格式無法解析 → STOP，建議手動修正

## Output Contract

輸出格式：{描述結構}
存儲路徑：`~/.gstack/projects/{slug}/{output-type}-{datetime}.md`
下游消費者：{哪些 skill 會讀這個}

## Completion

STATUS: DONE
- 轉換: {input-type} → {output-type}
- 遺失欄位: {count} 個標記 [TODO]
- 產出: {artifact path}
- 推薦下一步: {downstream skill}
```

---

## Type 3: Production（生產型）

**用途：** 根據輸入產出新的 artifact（不是審查，是建造）。
**allowed-tools:** `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`, `AskUserQuestion`

### 模板結構

```markdown
# {Role Name}

你是 {建造者角色 — 例：「遊戲設計文件工程師 — 結構先於靈感」}。

## Build Target

產出物：{描述最終 artifact}
品質基準：{明確的完成標準}

## Mode Routing

- `{skill} {topic}` → 從零建造
- `{skill} iterate {path}` → 迭代現有 artifact
- 無參數 → AskUserQuestion

## Phase 0: Context Gathering

必要資訊（缺任何一項 → AskUserQuestion）：
1. {必要輸入 1}
2. {必要輸入 2}
3. ...

搜尋上游 artifact 補充 context。

## Phase 1-N: 建造步驟

每步：
1. 明確的建造目標
2. 具體的執行動作
3. 品質檢查點
4. STOP gate（每 phase 結束呈現進度 + 問題）

## Error Handling

| 錯誤 | 處理 |
|------|------|
| 上游 artifact 矛盾 | 呈現矛盾 → AskUserQuestion |
| 建造中發現新需求 | 記錄到 TODO → 不中斷主流程 |
| 品質檢查未過 | 自動修正一次 → 仍未過則 STOP |

## Output Validation

完成前自檢：
- [ ] 所有必要段落存在
- [ ] 無 [TODO] 標記殘留
- [ ] artifact 可被下游 skill 解析

## Completion

STATUS: DONE
- 產出: `~/.gstack/projects/{slug}/{type}-{datetime}.md`
- 品質: {自檢結果}
- 推薦下一步: {downstream skill}
```

---

## Type 4: Control（控制型）

**用途：** 路由、調度、健康檢查。不產出 domain artifact，產出狀態報告。
**allowed-tools:** `Read`, `Glob`, `Grep`, `Bash`, `AskUserQuestion`

### 模板結構

```markdown
# {Role Name}

你是 {調度角色 — 例：「領域工作流路由器」}。

## Routing Table

| 用戶意圖 | 推薦 Skill | 條件 |
|----------|-----------|------|
| {intent-1} | /{skill-1} | {前置條件} |
| {intent-2} | /{skill-2} | {前置條件} |
| ... | ... | ... |

互斥表：
- /{skill-a} 和 /{skill-b} 不同時使用
- ...

## Health Check

檢查項目：
1. 所有 skill 的 SKILL.md 存在
2. shared/ 四個檔案齊全
3. artifact 路徑一致性
4. 最近的 artifact 產出時間

## Conflict Resolution

| 衝突 | 解決方式 |
|------|---------|
| 兩個 skill 都適用 | 推薦 {優先規則} |
| 上游 artifact 過時 | 建議重新跑上游 |
| skill 缺失 | 建議安裝 / 替代方案 |

## Status Report

```
Domain: {name}
Skills: {installed}/{total}
Last activity: {datetime}
Health: {OK/WARNING/ERROR}
Issues: {list}
Recommended next: {skill}
```

## Completion

STATUS: DONE（總是 DONE，因為 Control skill 只報告狀態）
```

---

## Type 5: Runtime Helper（工具型）

**用途：** 提供特定功能（搜尋、計算、格式化），不參與主工作流。
**allowed-tools:** 依據功能而定（通常包含 `Bash`）

### 模板結構

```markdown
# {Role Name}

你是 {工具角色 — 例：「經濟模擬計算器」}。

## Runtime Dependency

需要：{列出外部依賴}
- {dependency-1}: {用途} — 缺失時退化行為: {fallback}
- {dependency-2}: {用途} — 缺失時退化行為: {fallback}

## Graceful Degradation

如果 runtime 不可用：
1. 嘗試 {替代方案 1}
2. 嘗試 {替代方案 2}
3. 最後：告知用戶需要安裝 {dependency}，給出安裝指令

## Usage

```
/{skill} {args}
```

參數：
- `{arg-1}`: {說明}
- `{arg-2}`: {說明}

## Output

輸出格式：{描述}
- 如果被其他 skill 調用：輸出到 stdout（structured）
- 如果用戶直接調用：輸出到 chat（formatted）

## Completion

STATUS: DONE
- 結果: {summary}
- 如果被其他 skill 調用，不推薦下一步
```

---

## 附錄：類型選擇決策樹

```
這個 skill 主要做什麼？
├─ 評估/審查某個東西 → Review
├─ 把 A 格式轉成 B 格式 → Bridge
├─ 從零建造新的 artifact → Production
├─ 調度/路由/狀態檢查 → Control
└─ 提供計算/搜尋/格式化功能 → Runtime Helper
```
