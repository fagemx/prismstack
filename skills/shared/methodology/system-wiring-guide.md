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

## Pipeline 組合模式

Artifact flow 教的是「怎麼串」（機械層）。這裡教的是「什麼時候該用什麼串法」（策略層）。

### 模式 1: Sequential Chain（順序鏈）

```
/plan → /build → /review → /ship
```

**特徵：** 每一步的產出是下一步的唯一輸入。線性、簡單、可預測。
**適用：** 工作流程有明確的先後順序，每步只需要上一步的結果。
**範例：** 內容產製（構思 → 撰寫 → 審查 → 發布）

### 模式 2: Fan-Out（扇出）

```
/brief → /ad-layout
       → /ad-copy
       → /ad-video
```

**特徵：** 一個 skill 的產出被多個下游 skill 消費。並行展開。
**適用：** 一份 spec 需要產出多種格式、多個變體、或多個維度的產出。
**範例：** 廣告 brief 產出後，同時生成圖片版、文案版、影片版。
**注意：** Fan-out 的下游 skill 必須各自獨立（不互相依賴），否則用 Sequential。

### 模式 3: Fan-In（扇入）

```
/market-data  →
/user-survey  → /strategy-synthesis
/competitor   →
```

**特徵：** 多個 skill 的產出匯聚到一個下游 skill。
**適用：** 決策需要綜合多個來源的資訊。
**範例：** 策略規劃需要市場數據 + 用戶調研 + 競品分析。
**注意：** 匯聚 skill 的 Phase 0 要搜尋多種 artifact type（不是只找一種）。

### 模式 4: Review Loop（審查迴圈）

```
/generate → /review → 通過? → /ship
                ↓ 不通過
           /generate（帶 review feedback）
```

**特徵：** 生成和審查之間形成迴圈，直到品質達標。
**適用：** 產出品質需要多輪迭代。審查者和生成者是不同角色。
**範例：** 素材生成 → 品質審查 → 修改 → 再審。
**注意：** 必須有停止條件（最大輪數或目標分數），否則死循環。可嵌入 `iteration-loop-guide.md` 的 8 phase 迴圈。

### 模式 5: Gateway（閘門）

```
/intake → /classify → type A → /process-a
                    → type B → /process-b
                    → type C → /process-c
```

**特徵：** 一個 Control 類 skill 根據輸入特徵路由到不同的處理 skill。
**適用：** 輸入類型多樣，需要不同的處理方式。
**範例：** 素材入庫 → 分類（圖片/影片/文字）→ 各走不同審查流程。
**注意：** Gateway skill 不處理內容，只做路由。保持輕量。

### 模式 6: Feedback Injection（回饋注入）

```
/operate → /retrospect → insights → /operate（下一輪帶 insights）
```

**特徵：** 後期 skill 的發現回流到前期 skill，形成改進循環。
**適用：** 長期運營的 stack，需要越用越好。
**範例：** 投放 → 數據分析 → 發現 CTA 轉換率低 → 下次生成時帶著這個 insight。
**注意：** 回饋注入透過 `domain-config.json` 的 `accumulated` section，不是直接修改上游 skill。

### 選擇模式的判斷

| 你的情境 | 推薦模式 |
|---------|---------|
| 工作是線性流程 | Sequential Chain |
| 一份 spec 要產出多種東西 | Fan-Out |
| 決策需要多個來源 | Fan-In |
| 品質需要多輪迭代 | Review Loop |
| 輸入類型多樣 | Gateway |
| 需要越用越好 | Feedback Injection |
| 複合情境 | 組合使用（例：Gateway + Review Loop） |

### 常見組合

```
完整產製線：Gateway → Fan-Out → Review Loop → Fan-In → Ship
快速原型：Sequential Chain（3-5 個 skill）
品質導向：Sequential + Review Loop（每個階段都有審查迴圈）
數據驅動：Sequential + Feedback Injection（每輪帶歷史 insights）
```

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
