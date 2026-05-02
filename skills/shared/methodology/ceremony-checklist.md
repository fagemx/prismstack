# Skill Ceremony Checklist

> 用途：brownfield 改造現有 skill、`/skill-check review`、`/source-convert` 移植外部 skill 時，
> 用來判斷一個 skill 是否符合 prismstack 的格式深度。
>
> 不是「有沒有寫」的清單，是「品質級別需要哪些 ceremony」的對照表。

---

## 為什麼需要這個

外部 skill（不論來源是 ECC、其他 framework、或 prompt 文件）通常缺少 prismstack 的互動 ceremony：
STOP gates、AskUserQuestion 四段格式、scoring rubric、Anti-Sycophancy。
brownfield 改造時，沒有清單就會「補一半」— 新舊風格不一致、品質參差。

**核心原則：** ceremony 不是裝飾，是讓 agent 在壓力下不繞過規則的防護。

---

## 14 項 Ceremony（按必要性分級）

| # | Ceremony | Draft | Usable | Production | 來源 |
|---|---------|:-----:|:------:|:----------:|------|
| 1 | YAML frontmatter（trigger + anti-trigger + adjacent） | ✅ | ✅ | ✅ | skill-craft #1 |
| 2 | Single-role identity（一句話 ≤15 字） | ✅ | ✅ | ✅ | skill-craft #2 |
| 3 | Phase / 結構外化 | ✅ | ✅ | ✅ | skill-craft #3 |
| 4 | Mode routing at entry | ⚪ | ✅ | ✅ | skill-craft Pattern 5 |
| 5 | STOP gates（AskUserQuestion 四段格式） | ⚪ | ✅ | ✅ | ask-format.md |
| 6 | Artifact discovery（讀上游） | ⚪ | ✅ | ✅ | How-To 8 |
| 7 | Save artifact（標準路徑 + supersedes） | ⚪ | ✅ | ✅ | How-To 8 |
| 8 | Gotchas（含 redirect） | ✅(3) | ✅(3-5) | ✅(5+) | How-To 2 |
| 9 | Scoring formula（量化 + 權重 + 門檻） | ⚪ | ✅ | ✅ | How-To 1 |
| 10 | Anti-Sycophancy 三層 | ⚪ | ⚪ | ✅ | How-To 5 |
| 11 | Forcing questions | ⚪ | ⚪ | ✅(3+) | How-To 6 |
| 12 | Recovery / 中斷恢復 | ⚪ | ✅ | ✅ | How-To 7 |
| 13 | Completion protocol（STATUS + 下一步） | ✅ | ✅ | ✅ | preamble.md |
| 14 | Completion 萃取（context signals） | ⚪ | ⚪ | ✅ | context-accumulation-guide.md |

✅ = 必須有 ｜ ⚪ = 選配 ｜ 數字 = 最少數量

---

## 級別判斷

| 級別 | 分數 | 適用情境 |
|------|------|---------|
| **Draft** | 12-17/30 | 探索期、一次性 skill、用戶輸入 Level 1 |
| **Usable** | 18-23/30 | 個人/小團隊日常用、用戶輸入 Level 2-3 |
| **Production** | 24-30/30 | 多人團隊共用、面向用戶、用戶輸入 Level 4 |

對應 `quality-standards.md` 的 15D rubric。

---

## Brownfield 補齊流程

當 brownfield 改造遇到外部 skill 時：

### Step 1: 評定當前級別

對來源 skill 跑這份 checklist，標記每項為 ✅ / ⚪。
分數 = 已有 ceremony / 該級別必須項。

### Step 2: 決定目標級別

不是所有 skill 都要拉到 Production。問用戶：
- 這個 skill 多久用一次？週用 → Usable 夠｜日用且共用 → Production
- 用戶輸入 Level 是多少？決定上限（不浪費高品質輸入，也不假裝低品質）

### Step 3: 補齊缺口

按優先序補（高 ROI 在前）：

1. **YAML frontmatter** — 最便宜，最高 ROI（讓 routing 生效）
2. **STOP gates** — 直接套 `ask-format.md` 的格式
3. **Gotchas** — 從來源的「常見錯誤」+ Claude 通病推導
4. **Save artifact** — 加 Phase 結尾的 save block
5. **Scoring formula** — 只有 Review type 必補
6. **Anti-Sycophancy** — 只有 Production 級必補

### Step 4: 風格一致性檢查

補齊後，檢查：
- ✅ 全文是繁體中文（prismstack 標準）
- ✅ Phase 命名 `Phase 0 / Phase 1 / ...`（不是 Step 1 / Stage 1）
- ✅ STOP gate 用 `**STOP.** AskUserQuestion to confirm` 觸發語法
- ✅ Gotchas 用「Problem / Correct / Why Claude errs / Redirect / Example」格式
- ✅ Completion 有 STATUS + 下一步推薦

---

## 常見補齊陷阱

| 陷阱 | 後果 | 修正 |
|------|------|------|
| 只補 STOP gate 不補 AskUserQuestion 格式 | 模型把選項印成文字，gate 失效 | 套 `ask-format.md` 的精確語法 |
| 加 scoring 但沒定權重 | Claude 用直覺打分，等於沒打 | 權重總和 100%，每維度 0/1/2 標準 |
| 加 forbidden phrases 但沒 forcing question | 只擋了表面諂媚，沒逼出證據 | Anti-Sycophancy 三層全套 |
| 補了 Gotchas 但沒 redirect | Claude 知道有坑但不知道怎麼避 | 每個 Gotcha 必須有 Redirect 行 |
| 完整度高但無 trigger | routing 不會生效 | YAML frontmatter 是必備（Draft 也要）|

---

## 自動化檢查（可選）

`/skill-check review` 會跑這份 checklist。手動驗證時：

```bash
# 1. 檢查 frontmatter 完整性
grep -A5 "^---$" SKILL.md | head -10

# 2. 檢查 STOP gate 語法
grep -c "AskUserQuestion to confirm" SKILL.md  # 應 ≥ 每個 phase 1 個

# 3. 檢查 Gotchas 格式
grep -c "^### Gotcha:" SKILL.md  # Draft ≥3, Production ≥5

# 4. 檢查行數（SKILL.md 應 < 200 行）
wc -l SKILL.md
```

---

## 引用此 checklist 的 skill

- `/domain-plan` brownfield path（BF Phase 1 完整度評估）
- `/skill-check review`（15D 品質判定）
- `/source-convert`（Level 6 Stack Import 後的 ceremony 補齊）
- `/skill-edit`（補機制時對照）
