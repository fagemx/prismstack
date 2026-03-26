# Preamble 模板 — 領域共享語境

> 每個 domain gstack 的 `skills/shared/preamble.md` 都從此模板生成。
> LLM 根據領域知識填充佔位內容。

---

## 模板

```markdown
# {Domain Name} — 共享語境

> 此檔案被所有 skill 共享，提供領域專屬的詞彙和慣例。
> 由 prismstack /domain-build 自動生成，可手動修改。

## 領域詞彙

以下術語在此 domain stack 中有特定含義：

| 術語 | 定義 | 範例 |
|------|------|------|
| {term-1} | {definition} | {example} |
| {term-2} | {definition} | {example} |
| ... | ... | ... |

> LLM 生成指引：根據領域特性，列出 10-20 個核心術語。
> 重點是消除歧義 — 同一個詞在不同領域意思不同。
> 例：「Balance」在遊戲是數值平衡，在財務是資產負債。

## 品牌/專案資產

（若不適用可留空或標記 N/A）

- Logo 位置: {path or N/A}
- 風格指南: {path or N/A}
- 角色/IP 資產: {path or N/A}
- 品牌色彩: {hex codes or N/A}

## Artifact 存儲

所有 artifact 存儲在: `~/.prismstack/projects/{slug}/`

命名規則: `{user}-{branch}-{type}-{datetime}.md`

| artifact 類型 | type 前綴 | 產出者 | 消費者 |
|--------------|----------|--------|--------|
| {type-1} | {prefix} | /{skill-a} | /{skill-b} |
| {type-2} | {prefix} | /{skill-c} | /{skill-d} |
| ... | ... | ... | ... |

> LLM 生成指引：從 skill map 的 artifact flow 提取所有 artifact 類型。
> 每個 artifact 必須有明確的產出者和消費者。

## 互動格式

參見 `shared/ask-format.md`（可靠觸發語法 + 四段內容格式）。

**STOP gate 必須用此格式才能可靠觸發 AskUserQuestion 工具：**

```markdown
**STOP.** AskUserQuestion to confirm [什麼事]:

> [摘要 + RECOMMENDATION + 字母選項]

**One question only. Wait for answer before proceeding.**
```

❌ 不要用 `🛑`、`━━━` 邊框、`請確認：` — 這些格式模型不會可靠呼叫工具。

## 完成協議

參見 `shared/completion-protocol.md`。

每個 skill 結束時必須回報：
- `STATUS: DONE` — 已完成，附產出路徑 + 推薦下一步
- `STATUS: BLOCKED` — 缺少前置條件，說明缺什麼
- `STATUS: NEEDS_CONTEXT` — 需要更多資訊，列出具體問題

## 工作流概覽

（從 skill map 生成，讓每個 skill 知道自己在流程中的位置）

```
{workflow-graph — 文字版，從 /domain-plan 的 workflow graph 複製}
```
```

---

## 生成指引

LLM 在生成 preamble 時應：

1. **詞彙表必須具體** — 不是字典定義，是「在這個 domain stack 中的含義」
2. **Artifact 表必須完整** — 每個 skill 的產出都要列出
3. **工作流圖必須從 skill map 衍生** — 不可自行編造
4. **品牌/資產段落** — 如果用戶沒提供就寫 N/A，不要假設
5. **篇幅控制** — preamble 不超過 100 行（被所有 skill 載入，太長會浪費 context）
