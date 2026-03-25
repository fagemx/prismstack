# Domain Gstack Repo — 完整結構規格

> /domain-build 搭建的 repo 必須符合此結構。
> 每個檔案都有明確的內容要求。

---

## 目錄結構

```
{domain-name}/
├── README.md
├── CLAUDE.md
├── VERSION
├── CHANGELOG.md
├── LICENSE
├── .gitignore
├── bin/
│   ├── install.sh
│   └── {domain}-slug.sh
├── skills/
│   ├── shared/
│   │   ├── preamble.md
│   │   ├── completion-protocol.md
│   │   ├── ask-format.md
│   │   └── artifact-conventions.md
│   ├── routing/
│   │   └── SKILL.md
│   ├── {skill-1}/
│   │   ├── SKILL.md
│   │   └── references/          ← 若 skill 內容 > 200 行
│   │       ├── gotchas.md
│   │       ├── scoring-rubric.md
│   │       └── ...
│   └── ...
└── docs/
    ├── skill-map.md
    └── workflow-graph.md
```

---

## 每個檔案的內容要求

### 根目錄檔案

**README.md**
- 領域概述（一段話）、skill 清單（表格：名稱 / 類型 / 用途）、Quick Start（3 步：clone → install → 用第一個 skill）、安裝說明。
- 不超過 150 行。

**CLAUDE.md**
- Claude Code 交接文件。結構說明、常用命令（install、validate）、skill 開發慣例（YAML frontmatter 必填欄位、references/ 拆分規則、artifact 路徑慣例）。
- 讓新 Claude session 立刻理解 repo。

**VERSION**
- 單行：`0.1.0`

**CHANGELOG.md**
- 初始條目：`## 0.1.0 — {date}` + `- Initial generation by prismstack /domain-build`

**LICENSE**
- MIT License，年份 + 作者佔位。

**.gitignore**
- `node_modules/`, `.env`, `.gstack/`, `.claude/skills/`, `*.log`, `.DS_Store`, `tmp/`

### bin/ 目錄

**bin/install.sh**
- 複製 `skills/` 到 `~/.claude/skills/{domain}/`。
- 檢查目標目錄是否存在，若存在則詢問覆蓋。
- 成功後印出已安裝的 skill 清單。
- 必須 `chmod +x`。

**bin/{domain}-slug.sh**
- 從 repo 名稱產生 slug（小寫、連字號分隔）。
- 用於 artifact 路徑：`~/.gstack/projects/{slug}/`。

### skills/shared/ 目錄

**shared/preamble.md**
- 領域專屬語境：詞彙定義、品牌/專案資產、artifact 存儲路徑、互動格式參照、完成協議參照。
- 由 LLM 根據領域知識生成。參見 `preamble-template.md`。

**shared/completion-protocol.md**
- 三種完成狀態：DONE（已完成 + 產出路徑 + 推薦下一步）、BLOCKED（缺什麼 + 建議解法）、NEEDS_CONTEXT（缺什麼資訊 + 具體問題）。
- 每個 skill 結尾必須使用。

**shared/ask-format.md**
- AskUserQuestion 四段格式：1) 情境說明、2) 選項（A/B/C/D）、3) 預設建議、4) 如何回答。
- 每次互動只問一個問題。

**shared/artifact-conventions.md**
- 命名規則：`{user}-{branch}-{type}-{datetime}.md`。
- 存儲路徑：`~/.gstack/projects/{slug}/`。
- 讀取規則：最新檔案優先、glob 搜尋 pattern。
- 寫入規則：永遠新建、不覆蓋舊檔。

### skills/routing/ 目錄

**routing/SKILL.md**
- 領域路由 skill。根據用戶輸入意圖，推薦正確的 skill。
- 包含完整的 skill 清單、觸發條件、互斥表。
- 從 /domain-plan 的 skill map 生成。

### skills/{skill-N}/ 目錄

**{skill-N}/SKILL.md**
- 依據 `skill-template-guide.md` 的類型模板生成。
- YAML frontmatter 必須包含：name, version, origin, description, allowed-tools。
- 主體不超過 200 行。超過拆到 references/。

**{skill-N}/references/**
- 僅在 skill 內容 > 200 行時建立。
- 常見拆分：gotchas.md, scoring-rubric.md, benchmarks.md, examples/。

### docs/ 目錄

**docs/skill-map.md**
- 直接複製 /domain-plan 產出的 skill map artifact。
- 包含所有 skill 的名稱、類型、描述、上下游關係。

**docs/workflow-graph.md**
- 直接複製 /domain-plan 產出的 workflow graph。
- 文字版工作流圖 + 說明。

---

## 驗收標準

1. Routing skill 存在且包含完整 skill 清單
2. 至少 3 個 skill 有 SKILL.md（first slice 可用）
3. 每個 skill 的 artifact 路徑使用 `~/.gstack/projects/{slug}/`
4. install.sh 可執行
5. 至少 3 個 skill 包含 AskUserQuestion 互動
6. shared/ 四個檔案齊全
7. YAML frontmatter 包含 description + origin: prismstack-generated
