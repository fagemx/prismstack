# Prismstack Wave 1 — Scaffold + Core Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the minimum viable Prismstack — a working project scaffold with 3 skills (`/prism-routing`, `/domain-plan`, `/domain-build`) that can take a domain description and produce a complete domain gstack repo.

**Architecture:** Prismstack is a set of Claude Code skills (SKILL.md files with YAML frontmatter) installed to `~/.claude/skills/prismstack/`. Each skill follows gstack patterns (AskUserQuestion 4-segment format, STOP gates, completion protocol, artifact discovery/save) while maintaining ECC format compatibility. No template engine in Wave 1 — skills are plain SKILL.md with patterns written directly.

**Tech Stack:** Markdown (SKILL.md), Bash (install.sh, bin/ tools), Node.js (cross-platform install)

**Spec:** `docs/prismstack-v2-spec.md`

**Reference materials:**
- gstack skills: `C:\ai_project\Project\.claude\skills\gstack\` (for pattern reference)
- ECC skills: `C:\ai_project\everything-claude-code\skills\` (for format compatibility)
- gstack 知識庫: `C:\ai_project\guardian\docs\tech\gstack\` (方法論、品質 rubric、skill 寫作指南全在這)

**Wave 1 scope decisions:**
- No template engine — skills are plain SKILL.md (domain repos `/domain-build` produces will also start as plain SKILL.md, template engine is a future upgrade)
- Install via pure bash + PowerShell (not Node.js) — noted deviation from spec, aligns with simpler Wave 1 scope
- `/skill-check` does not exist yet — `/domain-plan` embeds the 7-question design check inline, `/domain-build` includes lightweight pack health
- explore-site: `C:\ai_project\jimeng-auto\skills\explore-site\SKILL.md` (for tool-builder reference, Wave 3)

---

## File Structure

```
C:\ai_project\prismstack\
├── README.md                          — 使用者文件（中英雙語）
├── CLAUDE.md                          — Claude Code 開發者指引
├── VERSION                            — 版本號
├── CHANGELOG.md                       — 變更記錄
├── LICENSE                            — MIT
├── bin/
│   ├── install.sh                     — Unix 安裝腳本
│   ├── install.ps1                    — Windows 安裝腳本
│   └── prism-slug.sh                  — 取得 repo slug（用於 artifact 路徑）
├── skills/
│   ├── prism-routing/
│   │   └── SKILL.md                   — Routing skill：引導用戶到正確的 Prismstack skill
│   ├── domain-plan/
│   │   ├── SKILL.md                   — 推導 skill map + workflow + artifact flow
│   │   └── references/
│   │       ├── skill-map-derivation.md    — Skill map 推導方法論
│   │       ├── skill-type-guide.md        — 5 種 skill 類型說明
│   │       └── artifact-flow-template.md  — Artifact flow 模板
│   ├── domain-build/
│   │   ├── SKILL.md                   — 自動搭建完整 domain gstack repo
│   │   ├── references/
│   │   │   ├── repo-scaffold-spec.md      — Repo 結構規格
│   │   │   ├── skill-template-guide.md    — Skill 模板撰寫指南
│   │   │   ├── preamble-template.md       — 領域 preamble 模板
│   │   │   ├── quality-standards.md       — 品質標準（15D rubric 摘要）
│   │   │   └── ecc-compat-guide.md        — ECC 格式相容指南
│   │   └── scripts/
│   │       └── validate-repo.sh           — 驗收檢查腳本（5 條驗收標準）
│   └── shared/
│       ├── completion-protocol.md     — DONE/DONE_WITH_CONCERNS/BLOCKED/NEEDS_CONTEXT
│       ├── ask-format.md              — AskUserQuestion 四段格式規範
│       ├── artifact-conventions.md    — Artifact 命名與存儲規範
│       ├── anti-sycophancy.md         — 三層反諂媚系統（deny list + forcing Qs + push-back）
│       └── stop-gates.md             — STOP gate 放置規範與互動設計
├── docs/
│   ├── prismstack-v2-spec.md          — 完整規格書
│   └── plans/
│       └── 2026-03-25-wave1-scaffold-and-core-skills.md  — 本計畫
└── test/
    └── install-test.sh                — 安裝測試腳本
```

---

## Task 1: Project Scaffold

**Files:**
- Create: `README.md`
- Create: `CLAUDE.md`
- Create: `VERSION`
- Create: `CHANGELOG.md`
- Create: `LICENSE`

- [ ] **Step 1: Initialize git repo**

```bash
cd C:\ai_project\prismstack
git init
```

- [ ] **Step 2: Create VERSION**

```
0.1.0
```

- [ ] **Step 3: Create LICENSE**

MIT license with current year and user info.

- [ ] **Step 4: Create CLAUDE.md**

Developer handoff for Claude Code — project structure, how to build, how to test, writing guidelines. NOT a project introduction (that's README). Key content:
- Project overview (Prismstack = 10-skill builder tool)
- Directory structure
- How to install: `bash bin/install.sh`
- How to test: `bash test/install-test.sh`
- Skill format: YAML frontmatter + Markdown body
- Commit style: conventional commits
- Language: skill content in 繁體中文, code/comments in English

- [ ] **Step 5: Create README.md**

User-facing documentation. Sections:
- What is Prismstack（一句話 + 稜鏡隱喻）
- Quick Start（3 步驟）
- Skills（10 個 skill 的表格，Wave 1 標記 ✅，其餘 🚧）
- How It Works（5 步循環：Plan → Build → Upgrade → Test → Iterate）
- Relationship to gstack / ECC
- License

- [ ] **Step 6: Create CHANGELOG.md**

```markdown
# Changelog

## [0.1.0] - 2026-03-25

### Added
- Project scaffold
- `/prism-routing` — builder routing skill
- `/domain-plan` — domain skill map planning
- `/domain-build` — auto-generate domain gstack repo
```

- [ ] **Step 7: Create .gitignore**

```
node_modules/
.env
.prismstack/
.claude/skills/
*.log
```

- [ ] **Step 8: Commit scaffold**

```bash
git add README.md CLAUDE.md VERSION CHANGELOG.md LICENSE .gitignore
git commit -m "feat: initialize Prismstack project scaffold"
```

---

## Task 2: Install System + Shared Resources

**Files:**
- Create: `bin/install.sh`
- Create: `bin/install.ps1`
- Create: `bin/prism-slug.sh`
- Create: `skills/shared/completion-protocol.md`
- Create: `skills/shared/ask-format.md`
- Create: `skills/shared/artifact-conventions.md`
- Create: `test/install-test.sh`

- [ ] **Step 1: Create `bin/prism-slug.sh`**

Utility to get repo slug for artifact paths. Used by skills for `~/.prismstack/projects/{slug}/`.

```bash
#!/usr/bin/env bash
# Output the repo slug (basename of git remote or directory)
set -euo pipefail
remote=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$remote" ]; then
  basename "${remote%.git}"
else
  basename "$(pwd)"
fi
```

- [ ] **Step 2: Create `bin/install.sh`**

Install script that:
1. Detects target directory (`~/.claude/skills/prismstack/`)
2. Creates directory structure
3. Copies all `skills/*/SKILL.md` to target
4. Copies `skills/*/references/` directories
5. Copies `skills/*/scripts/` directories
6. Copies `skills/shared/` to target
7. Reports what was installed

Key: Must work on macOS + Linux. Windows users use `install.ps1`.

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TARGET="${TARGET:-${HOME}/.claude/skills/prismstack}"

echo "Installing Prismstack to ${TARGET}..."

# Create target
mkdir -p "$TARGET"

# Copy each skill
for skill_dir in "$REPO_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  [ "$skill_name" = "shared" ] && continue  # shared is handled separately

  dest="$TARGET/$skill_name"
  mkdir -p "$dest"

  # Copy SKILL.md
  [ -f "$skill_dir/SKILL.md" ] && cp "$skill_dir/SKILL.md" "$dest/"

  # Copy references/ if exists
  [ -d "$skill_dir/references" ] && cp -r "$skill_dir/references" "$dest/"

  # Copy scripts/ if exists
  [ -d "$skill_dir/scripts" ] && cp -r "$skill_dir/scripts" "$dest/"

  echo "  ✓ $skill_name"
done

# Copy shared resources
mkdir -p "$TARGET/shared"
cp -r "$REPO_DIR/skills/shared/"* "$TARGET/shared/" 2>/dev/null || true
echo "  ✓ shared resources"

echo ""
echo "Prismstack installed successfully."
echo "Skills available: $(ls -d "$TARGET"/*/  2>/dev/null | wc -l | tr -d ' ')"
```

- [ ] **Step 3: Create `bin/install.ps1`**

Windows equivalent of install.sh using PowerShell. Same logic, different syntax.

- [ ] **Step 4: Create shared resources**

**`skills/shared/completion-protocol.md`** — Completion status definitions:
- DONE: all steps completed, evidence provided
- DONE_WITH_CONCERNS: completed but user should know about issues
- BLOCKED: cannot continue, escalation reason + suggestion
- NEEDS_CONTEXT: missing information, explicit requirements

**`skills/shared/ask-format.md`** — AskUserQuestion 4-segment format:
1. Re-ground (project + branch + what we're doing, assume 20min away)
2. Simplify (16-year-old language)
3. Recommend (stance + completeness score)
4. Options (A/B/C with human time / CC time)

**`skills/shared/artifact-conventions.md`** — Naming and storage:
- Path: `~/.prismstack/projects/{slug}/`
- Filename: `{user}-{branch}-{type}-{datetime}.md`
- Supersedes chain
- Discovery bash pattern

**`skills/shared/anti-sycophancy.md`** — Three-layer anti-sycophancy system:
- Layer 1: Deny list (forbidden empty praise phrases)
- Layer 2: Forcing questions (inescapable, specific questions)
- Layer 3: Push-back cadence (first answer is wrapped, real answer on 2nd/3rd push)
- Domain-specific adaptation guide (how each domain skill customizes these)
- Reference: `c:\ai_project\guardian\docs\tech\gstack\gstack-review-methodology.md` Principle 6

**`skills/shared/stop-gates.md`** — STOP gate placement and interaction design:
- One STOP gate per phase boundary (minimum)
- What to present at each gate (summary + options)
- When to add extra gates (long phases, risky decisions)
- How to combine with AskUserQuestion format
- Reference: `c:\ai_project\guardian\docs\tech\gstack\skill-quality-rubric.md` B5

- [ ] **Step 5: Create `test/install-test.sh`**

Test script that:
1. Creates a temp directory
2. Runs install.sh with `TARGET` overridden to temp
3. Checks all expected files exist
4. Checks no placeholder remnants (`{{...}}`)
5. Cleans up

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_TARGET=$(mktemp -d)

echo "Testing Prismstack install to $TEMP_TARGET..."

# Run install with overridden target
TARGET="$TEMP_TARGET" bash "$REPO_DIR/bin/install.sh"

# Check skills exist
EXPECTED_SKILLS=("prism-routing" "domain-plan" "domain-build")
for skill in "${EXPECTED_SKILLS[@]}"; do
  if [ ! -f "$TEMP_TARGET/$skill/SKILL.md" ]; then
    echo "FAIL: $skill/SKILL.md not found"
    rm -rf "$TEMP_TARGET"
    exit 1
  fi
  echo "  ✓ $skill/SKILL.md exists"
done

# Check shared resources
for shared_file in completion-protocol.md ask-format.md artifact-conventions.md anti-sycophancy.md stop-gates.md; do
  if [ ! -f "$TEMP_TARGET/shared/$shared_file" ]; then
    echo "FAIL: shared/$shared_file not found"
    rm -rf "$TEMP_TARGET"
    exit 1
  fi
done
echo "  ✓ shared resources exist (5 files)"

# Check no unresolved placeholders
if grep -r '{{[A-Z_]*}}' "$TEMP_TARGET" 2>/dev/null; then
  echo "FAIL: unresolved placeholders found"
  rm -rf "$TEMP_TARGET"
  exit 1
fi
echo "  ✓ no unresolved placeholders"

# Cleanup
rm -rf "$TEMP_TARGET"
echo ""
echo "All install tests passed."
```

- [ ] **Step 6: Run install test**

```bash
bash test/install-test.sh
```

Expected: All tests pass (will fail initially because skills don't exist yet — that's OK, we'll re-run after Task 3-5).

- [ ] **Step 7: Commit**

```bash
git add bin/ skills/shared/ test/
git commit -m "feat: add install system and shared resources"
```

---

## Task 3: /prism-routing Skill

**Files:**
- Create: `skills/prism-routing/SKILL.md`

This is the simplest skill — a routing table that helps users find the right Prismstack skill.

- [ ] **Step 1: Write `skills/prism-routing/SKILL.md`**

Structure:
```yaml
---
name: prism-routing
version: 0.1.0
origin: prismstack
description: |
  Prismstack 的導航 skill。當用戶不確定該用哪個 Prismstack skill 時使用。
  也用於首次接觸 Prismstack 時的介紹。
  Trigger: 用戶說「help」、「我要做什麼」、「Prismstack 有什麼」、或任何不明確的請求。
  Do NOT use when: 用戶已經知道要用哪個 skill（直接用該 skill）。
allowed-tools:
  - Read
  - Glob
  - AskUserQuestion
---
```

Body content:
- **Role:** You are Prismstack's navigator. Help users find the right skill.
- **Routing table:** 10 skills with trigger conditions, organized by wave (Wave 2-3 skills marked as 🚧 coming soon)
- **Intent detection:** Parse user's request → match to skill → recommend
- **First-time intro:** If user seems new, briefly explain Prismstack's 5-step cycle
- **AskUserQuestion format:** Follow shared/ask-format.md
- **Completion:** STATUS: DONE (routed to skill) or NEEDS_CONTEXT (ask user to clarify)

Key routing logic:
```
「我做 X 領域」/ 「幫我建一套 skill」     → /domain-plan
「開始搭建」/ 「build」                     → /domain-build
「檢查品質」/ 「skill 好不好」              → /skill-check 🚧
「加一個 skill」/ 「新增」                  → /skill-gen 🚧
「改這個 skill」/ 「調 scoring」            → /skill-edit 🚧
「這篇文章很好」/ 「這個 repo」             → /source-convert 🚧
「自動化這個網站」/ 「做一個工具」           → /tool-builder 🚧
「整體升級」/ 「測試回饋」                  → /domain-upgrade 🚧
「改 workflow」/ 「skill 串接」             → /workflow-edit 🚧
不確定                                      → AskUserQuestion 釐清
```

- [ ] **Step 2: Verify skill loads**

Read the SKILL.md and check:
- YAML frontmatter is valid
- Description includes trigger + anti-trigger
- Body has clear routing logic
- AskUserQuestion format referenced

- [ ] **Step 3: Commit**

```bash
git add skills/prism-routing/
git commit -m "feat: add /prism-routing navigation skill"
```

---

## Task 4: /domain-plan Skill

**Files:**
- Create: `skills/domain-plan/SKILL.md`
- Create: `skills/domain-plan/references/skill-map-derivation.md`
- Create: `skills/domain-plan/references/skill-type-guide.md`
- Create: `skills/domain-plan/references/artifact-flow-template.md`

This is the planning skill — takes a domain description and produces a skill map + workflow.

- [ ] **Step 1: Write `skills/domain-plan/references/skill-map-derivation.md`**

Content from spec's "Skill Map 規劃的具體方法" section + skill-orchestration-methodology.md:
- 8-step derivation process (lifecycle → gstack alignment → gap analysis → 3 tests → count check → artifact flow)
- Three gap methods (審查缺口、工作流缺口、交接缺口)
- 3 independence tests (姿態/產出/觸發)
- Merge vs split heuristics
- Example skill maps for different domains (遊戲/影劇/教育/行銷)

- [ ] **Step 2: Write `skills/domain-plan/references/skill-type-guide.md`**

The 5 skill types from spec's `/skill-check design`:
| Type | Core | Typical Output | Writing Focus |
| Review | 判斷/審查 | score, issue list | dimensions + scoring + anti-sycophancy |
| Bridge | 轉譯/handoff | spec, slice plan | translation logic + scope |
| Production | 生產/生成 | code, asset | build target + steps + fallback |
| Control | 路由/編排 | workflow map | routing + health + conflict |
| Runtime Helper | 依賴外部 runtime | varies | runtime dependency |

Plus freedom levels (high/medium/low) per type.

- [ ] **Step 3: Write `skills/domain-plan/references/artifact-flow-template.md`**

Template for artifact flow diagram:
- How to draw the flow (skill → artifact → consumer)
- Naming conventions
- Supersedes chain
- Example flow diagrams

- [ ] **Step 4: Write `skills/domain-plan/SKILL.md`**

```yaml
---
name: domain-plan
version: 0.1.0
origin: prismstack
description: |
  為目標領域推導完整的 gstack skill map + workflow + artifact flow。
  Trigger: 用戶說「我做 X 領域」、「幫我規劃 skill」、「我想建一套 domain stack」。
  Do NOT use when: 已經有 skill map，要搭建（用 /domain-build）。
  Do NOT use when: 要加單一 skill（用 /skill-gen）。
  上游：無（入口 skill）。
  下游：/domain-build。
  產出：skill-map-{datetime}.md + workflow-graph-{datetime}.md
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - WebSearch
---
```

Body structure (~150 lines, details in references/):

**Role identity:**
> You are a domain stack architect. Your job is to translate a domain description into a complete, runnable gstack skill map. You plan skill systems, not individual skills.

**Phase 0: Domain Discovery**
- Ask user: 「你的領域是什麼？」(one question)
- If user gives minimal answer (e.g., "我做行銷"), proceed — don't ask more
- If user gives detailed answer, use all of it
- STOP gate: confirm understanding before proceeding

**Phase 1: Lifecycle Mapping**
- Derive the domain's work lifecycle (5-8 stages)
- Map each stage to gstack's universal skill postures
- Read `references/skill-map-derivation.md` for methodology
- Present lifecycle to user, confirm

**Phase 2: Gap Analysis**
- Run 3 gap methods (review / workflow / handoff)
- Identify domain-specific skills needed
- Run 3 independence tests on each candidate
- Read `references/skill-type-guide.md` for type classification
- STOP gate: present candidates with type labels

**Phase 3: Skill Map Assembly + Design Check**
- Assemble complete map (target 10-25 skills)
- Categorize: 通用底盤 / 規劃視角 / 領域專屬 / 入口 / 工具型
- **7-question design check on each candidate** (inline, since /skill-check is Wave 2):
  ```
  1. 它是 review、bridge、production、control、還是 runtime helper？
  2. 它處理的 work unit 是什麼？
  3. 它做完留下什麼 artifact？
  4. 它的上游 / 下游是誰？
  5. 沒有它，workflow 會痛嗎？
  6. 它依賴什麼 runtime？
  7. 它是獨立 skill，還是某個 skill 的 section？
  ```
  → 7 全過 = 保留，第 7 問 fail = 合併到母 skill
- Read `references/artifact-flow-template.md`
- Draw artifact flow diagram
- STOP gate: present complete skill map with design check results

**Phase 4: User Confirmation**
- Present map with AskUserQuestion format:
  - A. 這樣可以，開始搭建
  - B. 我要加 skill
  - C. 我要刪/合併 skill
  - D. Workflow 要改
  - E. 我有些 skill 想用自己的版本
- Iterate until user picks A

**Phase 5: Save Artifacts**
- Save `skill-map-{datetime}.md` to `~/.prismstack/projects/{slug}/`
- Save `workflow-graph-{datetime}.md` to same location
- Completion: STATUS: DONE, recommend `/domain-build` as next step

**Anti-sycophancy:**
- 不說「這個領域很有潛力」
- 不說「這套 skill map 很完整」
- 如果 skill map 有明顯弱點（前深後淺、缺 bridge layer），直接指出

**Forcing questions（在 Phase 2 gap analysis 時問自己）：**
- 「這真的是一個獨立 skill，還是某個 skill 的一個 section？」
- 「如果把這個領域換成通用 web app，這個 skill 還有差異嗎？」（substitution test）
- 「後半段（實作/驗證/發布）有沒有用到這個領域自己的 runtime evidence？」

**Gotchas:**
- Claude 容易把所有東西都做成 Review skill — 檢查是否有足夠的 Production 和 Bridge
- Claude 容易忽略工具型 skill — 問用戶有沒有需要自動化的平台/工具
- Claude 容易產出太多 skill（>25）— 合併太薄的
- Claude 容易前深後淺 — 前半段領域化，後半段 generic。主動檢查 bridge layer

- [ ] **Step 5: Verify skill structure**

Check:
- SKILL.md < 200 lines (details in references/)
- references/ files exist and are substantive
- AskUserQuestion format used at each STOP gate
- Completion protocol at end
- Artifact save pattern included

- [ ] **Step 6: Commit**

```bash
git add skills/domain-plan/
git commit -m "feat: add /domain-plan skill with references"
```

---

## Task 5: /domain-build Skill

**Files:**
- Create: `skills/domain-build/SKILL.md`
- Create: `skills/domain-build/references/repo-scaffold-spec.md`
- Create: `skills/domain-build/references/skill-template-guide.md`
- Create: `skills/domain-build/references/preamble-template.md`
- Create: `skills/domain-build/references/quality-standards.md`
- Create: `skills/domain-build/references/ecc-compat-guide.md`
- Create: `skills/domain-build/scripts/validate-repo.sh`

This is the most complex skill — it auto-generates an entire domain gstack repo.

- [ ] **Step 1: Write `skills/domain-build/references/repo-scaffold-spec.md`**

Complete repo structure specification. What `/domain-build` creates:
```
{domain-name}/
├── README.md
├── CLAUDE.md
├── VERSION
├── CHANGELOG.md
├── LICENSE
├── bin/
│   ├── install.sh
│   └── {domain}-slug.sh
├── skills/
│   ├── shared/
│   │   └── preamble.md        ← 領域化 preamble
│   ├── routing/
│   │   └── SKILL.md           ← routing skill
│   ├── {skill-1}/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── {skill-2}/
│   │   ├── SKILL.md
│   │   └── references/
│   └── ...
└── docs/
    ├── skill-map.md           ← 從 /domain-plan 複製
    └── workflow-graph.md      ← 從 /domain-plan 複製
```

Include file-by-file specification of what each file should contain.

- [ ] **Step 2: Write `skills/domain-build/references/skill-template-guide.md`**

How to generate each skill type. For each of the 5 types (Review / Bridge / Production / Control / Runtime Helper):
- YAML frontmatter template
- Role identity pattern
- Mode routing pattern (if applicable)
- Section structure
- AskUserQuestion placement
- STOP gate placement
- Scoring template (for Review type)
- Gotchas template
- Anti-sycophancy template
- Forcing questions template
- Artifact discovery/save template
- Completion protocol

Include the skill-writing-doctrine principles:
1. Write trigger first
2. Skill = work posture, not knowledge
3. Externalize flow
4. Highest-value = gotchas
5. Rigid where fragile
6. Main skill = skeleton, refs = details
7. Define recovery
8. Output must be next-step readable

- [ ] **Step 3: Write `skills/domain-build/references/preamble-template.md`**

Template for generating domain-specific preamble:
- 領域詞彙定義（由 LLM 根據領域產出）
- 品牌資產位置（如適用）
- Artifact 存儲路徑 (`~/.prismstack/projects/{slug}/`)
- AskUserQuestion 格式（引用 shared/ask-format.md）
- Completion protocol（引用 shared/completion-protocol.md）

- [ ] **Step 4: Write `skills/domain-build/references/quality-standards.md`**

15D quality rubric summary (from skill-quality-rubric.md):
- A. Entry: trigger (2) + role (2) + mode routing (2)
- B. Flow: externalization (2) + STOP gates (2) + recovery (2)
- C. Knowledge: gotchas (2) + scoring (2) + benchmarks (2)
- D. Structure: progressive disclosure (2) + helper code (2) + config (2)
- E. System: artifact discovery (2) + output contract (2) + workflow position (2)

Target scores for `/domain-build` output:
- 通用底盤 skill: 18-23 (Usable)
- 規劃視角 skill: 15-20 (Draft-Usable)
- 領域專屬 skill: 12-17 (Draft)
- 入口 skill: 18-23 (Usable)

- [ ] **Step 5: Write `skills/domain-build/references/ecc-compat-guide.md`**

ECC format compatibility rules:
- YAML frontmatter must include `description:` (ECC requirement)
- `origin:` field set to `prismstack`
- Skills installable to `~/.claude/skills/{domain}/`
- No conflicts with existing ECC skills in `~/.claude/skills/`
- File structure compatible with ECC's scan system

- [ ] **Step 6: Write `skills/domain-build/scripts/validate-repo.sh`**

Validation script that checks the 5 minimum acceptance criteria from spec:
```bash
#!/usr/bin/env bash
# Validate a domain gstack repo meets minimum acceptance criteria
set -euo pipefail

REPO_DIR="${1:-.}"
PASS=0
FAIL=0

echo "Validating domain gstack repo: $REPO_DIR"
echo "========================================="

# 1. Routing skill works
if [ -f "$REPO_DIR/skills/routing/SKILL.md" ]; then
  echo "✅ 1. Routing skill exists"
  ((PASS++))
else
  echo "❌ 1. Routing skill missing"
  ((FAIL++))
fi

# 2. At least 1 first-slice path exists (check for 3+ skills with SKILL.md)
SKILL_COUNT=$(find "$REPO_DIR/skills" -name "SKILL.md" -not -path "*/shared/*" | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -ge 3 ]; then
  echo "✅ 2. First slice possible ($SKILL_COUNT skills found)"
  ((PASS++))
else
  echo "❌ 2. Not enough skills for first slice ($SKILL_COUNT found, need 3+)"
  ((FAIL++))
fi

# 3. Artifact paths consistent
if grep -r "~/.prismstack/projects/" "$REPO_DIR/skills/" >/dev/null 2>&1; then
  echo "✅ 3. Artifact discovery/save patterns found"
  ((PASS++))
else
  echo "❌ 3. No artifact discovery/save patterns"
  ((FAIL++))
fi

# 4. install.sh exists and is executable
if [ -x "$REPO_DIR/bin/install.sh" ]; then
  echo "✅ 4. install.sh exists and is executable"
  ((PASS++))
else
  echo "❌ 4. install.sh missing or not executable"
  ((FAIL++))
fi

# 5. At least 3 skills have AskUserQuestion interaction
AQ_COUNT=$(grep -rl "AskUserQuestion" "$REPO_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$AQ_COUNT" -ge 3 ]; then
  echo "✅ 5. Interactive skills found ($AQ_COUNT with AskUserQuestion)"
  ((PASS++))
else
  echo "❌ 5. Not enough interactive skills ($AQ_COUNT found, need 3+)"
  ((FAIL++))
fi

echo ""
echo "Result: $PASS/5 passed, $FAIL/5 failed"
if [ "$FAIL" -eq 0 ]; then
  echo "✅ All acceptance criteria met."
  exit 0
else
  echo "❌ Acceptance criteria NOT met."
  exit 1
fi
```

- [ ] **Step 7: Write `skills/domain-build/SKILL.md`**

```yaml
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
  產出：完整的 domain gstack repo（目錄結構 + 所有 skill + install.sh）。
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---
```

Body structure (~150 lines, details in references/):

**Role identity:**
> You are a domain stack builder. You take a skill map and produce a complete, runnable gstack repo. You build fast, build complete, and build correct. Quality is "usable, not perfect" — perfection comes from /domain-upgrade.

**Recovery: If interrupted mid-build:**
- Check what already exists in the target repo directory
- Read `build-progress.md` (status table created in Phase 0)
- Resume from last incomplete phase
- Do NOT regenerate skills that already have SKILL.md files

**Phase 0: Artifact Discovery + Progress Tracking**
- Search `~/.prismstack/projects/{slug}/` for `skill-map-*.md`
- If not found → STATUS: BLOCKED, recommend /domain-plan
- Read skill map, confirm with user
- Ask: where to create the repo? (default: current directory)
- **Create `build-progress.md` in the target repo** — status table tracking each skill:
  ```
  | Skill | Type | Status | Notes |
  |-------|------|--------|-------|
  | /routing | Control | pending | |
  | /game-review | Review | pending | |
  | ... | ... | ... | |
  ```
- STOP gate

**Phase 1: Repo Scaffold**
- Read `references/repo-scaffold-spec.md`
- Create directory structure
- Create README.md, CLAUDE.md, VERSION, LICENSE, CHANGELOG.md
- Create bin/install.sh (copy from Prismstack's template, adapt)
- Create .gitignore
- git init + first commit
- Update `build-progress.md`: scaffold = done
- STOP gate: show created structure

**Phase 2: Shared Resources**
- Read `references/preamble-template.md`
- Generate domain-specific preamble (領域詞彙 by LLM)
- Create shared/preamble.md
- Create shared/completion-protocol.md, ask-format.md, artifact-conventions.md
- Update `build-progress.md`: shared = done

**Phase 3: Generate Skills (batch, ORDERED)**
- Read `references/skill-template-guide.md`
- Read `references/quality-standards.md`
- Read `references/ecc-compat-guide.md`

**Build order (from spec, not arbitrary):**
```
Step 3a: Routing skill（first — needed for navigation）
Step 3b: 通用底盤 skills（fork gstack patterns + domain vocab replacement）
Step 3c: 規劃視角 skills（strategy / design / engineering, based on domain）
Step 3d: 領域專屬 skills（LLM generates based on domain knowledge）
Step 3e: 入口 skills（import/conversion for external materials）
Step 3f: 工具型 skills（if any in skill map）
```

For each skill:
  1. Determine type (Review / Bridge / Production / Control / Runtime Helper)
  2. Generate SKILL.md following type template from `references/skill-template-guide.md`
  3. Include `origin: prismstack-generated` and `version: 0.1.0` in YAML frontmatter
  4. Generate references/ if skill content would exceed 200 lines
  5. **ECC dual-format check:** Verify SKILL.md has valid `description:` with trigger/anti-trigger
  6. Update `build-progress.md`: skill = done

**STOP gate every 5 skills:** Present:
  - Skills generated so far (name + type + line count)
  - Skills remaining
  - Any issues encountered
  - Ask: continue / adjust / stop

**Phase 4: System Integration**
- Wire artifact discovery (each skill's Phase 0 searches upstream)
- Wire artifact save (each skill's completion writes to shared location)
- Wire workflow position (each skill recommends next step)
- Verify artifact flow matches skill map's workflow graph
- Update `build-progress.md`: integration = done

**Phase 5: Validation**
- Run `scripts/validate-repo.sh`
- Report results
- If any fail → fix automatically → re-run
- STOP gate: show validation results

**Phase 6: Pack Health Report**
- Note: Full `/skill-check pack` is Wave 2, but include a lightweight version:
  - Count skills by type
  - Check artifact flow connectivity
  - Flag obvious gaps (no bridge layer, front-heavy)
- Present report to user

**Phase 7: Completion**
- git add all + commit "feat: initial domain gstack generation"
- STATUS: DONE
- Recommend: install with `bash bin/install.sh`, then test with a real workflow
- Suggest `/skill-check pack` when available (Wave 2)

**Gotchas:**
- Claude 容易在 Phase 3 生成太 generic 的 skill — 檢查 substitution test
- Claude 容易忘記 artifact discovery/save — 每個 skill 都要有
- Claude 容易一口氣跑完不停 — 每 5 個 skill 要 STOP
- Claude 容易在 Review skill 裡不寫 scoring formula — 必須有顯式公式
- Claude 容易把所有內容塞進 SKILL.md — 超過 200 行要拆 references/

- [ ] **Step 8: Verify skill structure**

Check:
- SKILL.md < 200 lines
- 5 references/ files all substantive
- validate-repo.sh is executable and has all 5 checks
- Phases clearly separated with STOP gates
- Artifact discovery at Phase 0
- Completion protocol at Phase 7

- [ ] **Step 9: Commit**

```bash
git add skills/domain-build/
git commit -m "feat: add /domain-build skill with references and validation"
```

---

## Task 6: Integration Test + Final Validation

**Files:**
- Modify: `test/install-test.sh` (if needed)

- [ ] **Step 1: Run install test**

```bash
bash test/install-test.sh
```

Expected: All tests pass — 3 skills installed, shared resources present, no placeholders.

- [ ] **Step 2: Manual smoke test — install to real location**

```bash
bash bin/install.sh
ls ~/.claude/skills/prismstack/
```

Verify:
- `prism-routing/SKILL.md` exists
- `domain-plan/SKILL.md` exists
- `domain-plan/references/` exists with 3 files
- `domain-build/SKILL.md` exists
- `domain-build/references/` exists with 5 files
- `domain-build/scripts/validate-repo.sh` exists and is executable
- `shared/` exists with 3 files

- [ ] **Step 3: Verify YAML frontmatter validity**

```bash
# Check each SKILL.md has valid YAML frontmatter
for f in skills/*/SKILL.md; do
  echo "Checking $f..."
  head -1 "$f" | grep -q "^---$" || echo "FAIL: no frontmatter start"
done
```

- [ ] **Step 4: Verify ECC compatibility**

Each SKILL.md must have:
- `name:` in frontmatter
- `description:` in frontmatter (multi-line with trigger/anti-trigger)
- Content starts with `# Title` after frontmatter

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: Wave 1 complete — scaffold + 3 core skills"
```

- [ ] **Step 6: Tag release**

```bash
git tag v0.1.0
```

---

## Wave 1 Acceptance Criteria

```
✅ Project scaffold complete (README, CLAUDE.md, LICENSE, VERSION, CHANGELOG)
✅ install.sh works on Unix, install.ps1 works on Windows
✅ /prism-routing installed and has valid routing table
✅ /domain-plan installed with 3 reference files
✅ /domain-build installed with 5 reference files + validation script
✅ Shared resources (5 files: completion-protocol, ask-format, artifact-conventions, anti-sycophancy, stop-gates) installed
✅ All SKILL.md files have valid YAML frontmatter (name, version, origin, description, allowed-tools)
✅ All SKILL.md files < 200 lines (details in references/)
✅ All skills use AskUserQuestion format + STOP gates + completion protocol
✅ ECC format compatible (description with triggers, installable to ~/.claude/skills/)
✅ test/install-test.sh passes
✅ git history clean with conventional commits
```

## Next: Wave 2

After Wave 1 ships, write plan for:
- `/skill-check` (design / review / pack modes)
- `/skill-gen` (single skill generation)
- `/skill-edit` (skill internals editing)
