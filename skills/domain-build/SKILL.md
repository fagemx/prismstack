---
name: domain-build
version: 0.1.0
origin: prismstack
description: |
  根據 /domain-plan 產出的 skill map，自動搭建完整的 domain gstack repo。
  Trigger: /domain-plan 完成後、用戶說「開始搭建」、「build」。
  Do NOT use when: 還沒規劃 skill map（先用 /domain-plan）。
  Do NOT use when: 要加單一 skill（用 /skill-gen）。
  上游：/domain-plan（讀取 skill-map-*.md）。
  下游：/skill-check pack（Wave 2）。Wave 1 內建輕量 pack health 替代。
  產出：完整的 domain gstack repo。
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# Domain Stack Builder

你是領域 stack 搭建引擎。快速搭建、完整搭建。品質目標：「可用，不求完美」。

## Recovery（中斷恢復）

如果被中斷：
1. 檢查目標目錄是否已存在
2. 讀取 `build-progress.md`（如果有）
3. 從最後一個未完成的 Phase 續跑
4. **不要重新生成已存在的 skill**

---

## Phase 0: Artifact Discovery + 進度追蹤

1. 搜尋 `~/.gstack/projects/*/skill-map-*.md`，找到最新的 skill map
2. 若找不到 → **STATUS: BLOCKED** — 建議先用 `/domain-plan`
3. 搜尋目標目錄是否已有部分建置（`build-progress.md`、`skills/` 目錄）：
   - 如果有 `build-progress.md` → 讀取，從最後一個 `pending` 狀態的 skill 繼續
   - 如果有 `skills/` 但沒有 progress file → 列出已存在的 skill，問用戶要接續還是重建
4. 搜尋 `~/.gstack/projects/` 其他 domain 的已建 stack，列出可能相關的（用戶可能想參考）
5. 讀取 skill map，用 AskUserQuestion 確認：
   - 確認 skill 清單正確
   - 詢問 repo 建立位置（預設：當前目錄）
   - 詢問 domain slug（用於 artifact 路徑）
4. 建立 `build-progress.md` — 狀態追蹤表：

```
| Skill | Type | Status | Notes |
|-------|------|--------|-------|
| routing | Control | pending | |
| {skill-1} | {type} | pending | |
| ... | ... | ... | ... |
```

**STOP: 確認 skill map + 建置位置後才繼續。**

---

## Phase 1: Repo Scaffold

讀取 `references/repo-scaffold-spec.md`。

1. 建立完整目錄結構
2. 生成根目錄檔案：README.md, CLAUDE.md, VERSION, CHANGELOG.md, LICENSE, .gitignore
3. 生成 bin/install.sh（chmod +x）+ bin/{domain}-slug.sh
4. `git init` + 第一次 commit
5. 更新 `build-progress.md`

**STOP: 呈現已建立的目錄樹，確認後繼續。**

---

## Phase 2: Shared Resources

讀取 `references/preamble-template.md`。

1. 根據領域知識生成 `skills/shared/preamble.md`（LLM 產生領域詞彙）
2. 生成 `skills/shared/completion-protocol.md`
3. 生成 `skills/shared/ask-format.md`
4. 生成 `skills/shared/artifact-conventions.md`
5. 更新 `build-progress.md`

---

## Phase 3: 依序生成 Skills

讀取 `references/skill-template-guide.md` + `references/quality-standards.md` + `references/ecc-compat-guide.md`。

### 建置順序

```
3a: Routing skill（第一個）
3b: 通用底盤 skills（fork gstack patterns + 領域詞彙）
3c: 規劃視角 skills（策略/設計/工程）
3d: 領域專屬 skills（LLM 根據領域知識生成）
3e: 入口 skills（import/conversion）
3f: 工具型 skills（如果有）
```

### 每個 skill 的生成流程

1. 根據類型選擇模板（skill-template-guide.md）
2. 生成 YAML frontmatter（含完整 description）
3. 生成 SKILL.md 主體
4. 若內容 > 200 行 → 拆分到 references/
5. ECC 相容性檢查（ecc-compat-guide.md 自檢清單）
6. 更新 `build-progress.md`

### STOP Gate

**每生成 5 個 skill 後暫停：**
- 呈現進度表
- 列出已知問題
- 用 AskUserQuestion 詢問：繼續 / 調整 / 停止

---

## Phase 4: System Integration

1. 檢查每個 skill 的 artifact discovery（讀上游）
2. 檢查每個 skill 的 artifact save（寫到 `~/.gstack/projects/{slug}/`）
3. 檢查每個 skill 的 workflow position（推薦下一步）
4. 修復斷裂的 artifact flow

---

## Phase 5: Validation

1. 執行 `scripts/validate-repo.sh`（從 prismstack skill 目錄複製到生成的 repo）
2. 自動修復失敗項目
3. 重新執行驗證

Score the build output using `references/build-benchmarks.md`.
Report: Build Quality Score X/10, average skill quality Y/30.
If Build Quality Score < 5, fix the weakest dimension before completing.

**STOP: 呈現驗證結果。全部通過才繼續。**

---

## Phase 6: 輕量 Pack Health（替代 Wave 2 的 /skill-check）

快速健康報告：

1. **類型分布** — 各類型 skill 數量（Review/Bridge/Production/Control/Runtime Helper）
2. **Artifact Flow 連通性** — 有產出但沒有消費者的 artifact？有消費但沒有來源的 artifact？
3. **明顯缺口** — 沒有 Bridge 層？Review 過多但 Production 不足？前重後輕？
4. 呈現報告，標記 WARNING 項目

---

## Phase 7: Completion

1. `git add -A && git commit -m "feat: initial domain gstack generation"`
2. 呈現最終摘要：

```
STATUS: DONE

Domain: {name}
Skills: {count} ({by-type breakdown})
Validation: {pass}/{total}
Pack Health: {warnings count} warnings

建議下一步：
1. 安裝: bash bin/install.sh
2. 測試: 用真實工作流跑一輪
3. 迭代: 根據使用回饋調整（/skill-edit, /domain-upgrade）
```

---

## Gotchas

1. **Claude 生成太 generic 的 skill** — 替換測試：把領域名稱換掉，如果 skill 還能用，就太 generic 了。每個 skill 必須有領域專屬的 gotchas、scoring formula、vocabulary
2. **Claude 忘記 artifact discovery/save** — 每個 skill 都必須在 Phase 0 搜尋上游 artifact，結尾寫出 artifact
3. **Claude 一口氣跑完不停** — 必須在每 5 個 skill 後 STOP，呈現進度表
4. **Claude 跳過 Review skill 的 scoring formula** — Review 型 skill 必須有明確的評分公式（不是「整體 7/10」）
5. **Claude 把所有內容塞進 SKILL.md** — 超過 200 行就拆到 references/

## Anti-Sycophancy

- 不要說「這個 domain stack 已經可以投入生產」— 它是 Draft 品質
- 不要跳過 Phase 6 的 pack health report — 即使一切看起來沒問題
- 不要說「所有 skill 都符合高品質標準」— 誠實報告每個 skill 的預估等級
