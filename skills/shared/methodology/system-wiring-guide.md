# Skill 串接指南

> 用途：/domain-build 串接 skills、/workflow-edit 調整串接。
> 語境：你正在幫用戶讓 skill 之間自動串起來。

---

## Artifact Flow

### 存儲
所有 artifact 存在 `~/.prismstack/projects/{slug}/`。

命名：`{user}-{branch}-{type}-{datetime}.md`

Slug 從 git repo 計算：
```bash
_SLUG=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
_PROJECTS_DIR="${HOME}/.prismstack/projects/${_SLUG}"
mkdir -p "$_PROJECTS_DIR"
```

### Discovery Pattern
每個 skill 在 Phase 0 自動搜尋上游產出：
```bash
_LATEST=$(ls -t "$_PROJECTS_DIR"/*-{type}-*.md 2>/dev/null | head -1)
```
找到 → 讀取並使用。沒找到 → fall back 到其他方式（git diff 分析等）。

### Save Pattern
每個 skill 完成時存 artifact：
```bash
_OUT="$_PROJECTS_DIR/${_USER}-${_BRANCH}-{type}-$(date +%Y-%m-%d-%H%M).md"
```

### Supersedes Chain
新 artifact 頂部標記取代了誰：
```
Supersedes: nox-main-skill-map-2026-03-24-0900.md
```
這形成修訂鏈——可以追蹤一個 artifact 在多次執行之間怎麼演化。

### 規則
- 每個 artifact 必須有 producer 和 consumer
- 0 個孤立 artifact（有人寫沒人讀 = 浪費）
- 0 個斷點（skill 找不到上游 artifact）

---

## Skill Chaining

Skill 之間透過 shared filesystem 串接，不是 API：
- Skill A 產出 artifact → 存到 `$_PROJECTS_DIR`
- Skill B 啟動時 discover → 讀到 A 的 artifact
- 不需要手動傳檔案

❌ 在 skill 裡寫「把上一步的結果貼給我」
✅ 在 Phase 0 自動搜尋 `$_PROJECTS_DIR/*-{upstream-type}-*.md`

每個 skill 仍然可以獨立運行（只是少了上游 context）。獨立性是刻意的——用戶不一定按順序跑。

### 串接範例
```
/skill-A ──產出 design-*.md──→ /skill-B
    ↓                              ↓
  存到 $_PROJECTS_DIR         Phase 0 搜尋 *-design-*.md
    ↓                              ↓
/skill-C ──讀 A + B 的產出──→ 綜合判斷
```

### Producer-Consumer 表（建 stack 時必填）
| Producer Skill | Artifact Type | Consumer Skill |
|---------------|---------------|----------------|
| /skill-name | {type}-*.md | /skill-name |
| ... | ... | ... |

---

## Completion Protocol

每個 skill 結束必須報告：

| Status | 意思 | 下游行為 |
|--------|------|---------|
| DONE | 全部完成 | 繼續 workflow |
| DONE_WITH_CONCERNS | 完成但有疑慮 | 顯示疑慮，問是否繼續 |
| BLOCKED | 無法繼續 | 停下來，報告原因 + ESCALATION_REASON |
| NEEDS_CONTEXT | 缺資訊 | 要求補充，明確說出需要什麼 |

下游 skill 消費上游狀態：
- DONE → 繼續
- DONE_WITH_CONCERNS → 顯示 concerns，問用戶要不要繼續
- BLOCKED → 中止，顯示 blocking reason
- NEEDS_CONTEXT → 等待補充

---

## Next Step Routing

完成後推薦下一個 skill：
```
Next Step:
  PRIMARY: /skill-name — reason
  (if condition): /alternate — reason
```

規則：
- 必須有 PRIMARY（最常見的下一步）
- 條件分支用 `(if ...)` 標注
- 不要推薦超過 3 個選項

---

## Preamble 共享

所有 skill 共享 preamble（見 shared/preamble.md）：
- Project slug + branch
- `$_PROJECTS_DIR` 路徑
- `$_STATE_DIR` 路徑
- Session tracking（多 session 時自動 re-ground）
- 上游 artifact summary

Preamble 確保每個 skill 啟動時都知道自己在哪個 project、什麼 branch、有哪些上游產出可用。

---

## Workflow Validation Checklist

搭建完或修改後跑：

- [ ] 每個 artifact 有 producer + consumer？
- [ ] 沒有孤立 skill（沒上游也沒下游）？
- [ ] 沒有 circular dependency？
- [ ] Bridge skill 連接 design artifact → production artifact？
- [ ] 所有 skill 有 completion protocol？
- [ ] 所有 skill 有 next step routing？
- [ ] Discovery 腳本能找到上游？（dry run 測試）
- [ ] Save 腳本命名正確？（下游的 glob pattern 能 match）
