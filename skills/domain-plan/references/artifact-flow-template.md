# Artifact Flow 模板

> 用途：/domain-plan Phase 3，畫 skill 之間的 artifact 傳遞關係

---

## 格式規則

### 基本語法

```
/skill-a → artifact-name-{datetime}.md → /skill-b
```

### 命名規則

- artifact 檔名：`{type}-{datetime}.md`
- 儲存位置：`~/.gstack/projects/{slug}/`
- datetime 格式：`YYYYMMDD-HHmmss`

範例：
```
skill-map-20260325-143000.md
workflow-graph-20260325-143100.md
game-review-report-20260325-150000.md
```

### 版本鏈（Supersedes Chain）

當同一類型的 artifact 被重新產出時，新版 artifact 在檔頭標記它取代了哪個舊版：

```yaml
---
supersedes: skill-map-20260325-143000.md
---
```

消費者永遠讀最新版。

---

## 規則

1. **每個 artifact 至少有一個 consumer** — 沒人消費的 artifact = 浪費。如果畫完發現某個 artifact 沒有下游，要嘛砍掉它，要嘛找到它的消費者。

2. **每個 skill 至少產出一個 artifact** — 如果一個 skill 什麼都不產出，它不是 skill，是一段對話。

3. **不要有環** — artifact flow 是 DAG（有向無環圖）。如果出現環，代表 workflow 有循環依賴，需要拆解。迭代用新版 artifact 而不是回頭餵。

4. **標記 entry point** — 沒有上游 artifact 的 skill = entry point。通常是入口 skill 或 ideation skill。

5. **標記 terminal** — 沒有下游 consumer 的 artifact = 最終交付物。通常是 ship/release 的產出。

---

## 範例：行銷領域 artifact flow

```
[Entry Points]
/market-research → market-brief-*.md → /campaign-strategy
/competitor-analysis → competitor-report-*.md → /campaign-strategy

[Strategy Layer]
/campaign-strategy → campaign-plan-*.md → /creative-brief
                                        → /media-plan
                                        → /content-calendar

[Production Layer]
/creative-brief → brief-*.md → /ad-layout
                             → /copy-review
/ad-layout → layout-draft-*.md → /creative-review
/copy-review → copy-report-*.md → /ad-layout (revision)

[Review Layer]
/creative-review → creative-verdict-*.md → /media-plan
/brand-review → brand-report-*.md → /creative-brief (revision)

[Execution Layer]
/media-plan → media-schedule-*.md → /ship
/content-calendar → content-plan-*.md → /ship

[Terminal]
/ship → release-log-*.md
/analytics-review → performance-report-*.md → /retro
/retro → retro-notes-*.md → /campaign-strategy (next cycle)
```

---

## 繪製步驟

1. 列出所有 skill
2. 每個 skill 旁邊寫它產出什麼 artifact
3. 每個 artifact 旁邊寫誰消費它
4. 按 workflow 階段分組（entry → strategy → production → review → execution → terminal）
5. 檢查：有沒有孤兒 artifact？有沒有沒產出的 skill？
6. 用文字畫出流向圖

---

## 給 /domain-plan 的輸出格式

Phase 3 結束時，artifact flow 要存成 `workflow-graph-{datetime}.md`，格式如上。

同時在 `skill-map-{datetime}.md` 裡，每個 skill 條目都要標記：
```
- /skill-name (type: review)
  - 產出: artifact-name-*.md
  - 消費: 上游-artifact-*.md
  - 下游: /consuming-skill
```
