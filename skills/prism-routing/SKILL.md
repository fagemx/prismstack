---
name: prismstack
version: 0.4.0
origin: prismstack
description: |
  Prismstack — Domain Stack Builder. 10 個互動式 skill 把 gstack 方法論遷移到任何領域。
  從規劃到搭建到持續迭代的完整工具鏈。

  When you notice the user is at these stages, suggest the appropriate skill:
  - User wants to build a domain skill stack → suggest /domain-plan
  - User says "我做 X 領域", "幫我建一套 skill", "規劃" → suggest /domain-plan
  - User has a skill map and wants to build the repo → suggest /domain-build
  - User says "開始搭建", "build", "產出 repo" → suggest /domain-build
  - User wants to check skill quality → suggest /skill-check
  - User says "檢查品質", "skill 好不好", "健康度" → suggest /skill-check
  - User wants to add a single new skill → suggest /skill-gen
  - User says "加一個 skill", "新增" → suggest /skill-gen
  - User wants to edit skill internals → suggest /skill-edit
  - User says "改這個 skill", "調 scoring", "改 gotchas" → suggest /skill-edit
  - User has external content to convert into a skill → suggest /source-convert
  - User says "這篇文章很好", "這個 repo 想用", "轉換" → suggest /source-convert
  - User wants to automate a website, API, or tool → suggest /tool-builder
  - User says "自動化這個網站", "做一個工具", "API 串接" → suggest /tool-builder
  - User wants to upgrade or iterate on existing stack → suggest /domain-upgrade
  - User says "升級", "測試回饋", "迭代", "這裡不好用" → suggest /domain-upgrade
  - User wants to change skill connections or workflow → suggest /workflow-edit
  - User says "改 workflow", "skill 串接", "調整流程" → suggest /workflow-edit

  First-time users: suggest starting with /domain-plan — "告訴我你要做什麼領域".

  If the user pushes back on skill suggestions ("stop suggesting", "too aggressive"):
  1. Stop suggesting for the rest of this session
  2. Say: "Got it — I'll stop suggesting skills."
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

# /prismstack — Triage Navigator + Skill Loader

## Role

You are Prismstack's triage navigator. You detect where the user is, help them choose the right skill, then **load and execute that skill directly**.

**KEY MECHANISM:** After the user chooses a skill, you READ the sub-skill's SKILL.md and follow its instructions. You become that skill.

```
User chooses A (domain-plan)
  → Read the SKILL.md: cat ~/.claude/skills/prismstack/domain-plan/SKILL.md
  → Also read its references/: cat ~/.claude/skills/prismstack/domain-plan/references/*.md
  → Follow the loaded skill's instructions from Phase 0 onward
```

**Sub-skill locations:**
```bash
# Find Prismstack skills (global or project-level)
_PRISM_DIR=""
[ -d "$HOME/.claude/skills/prismstack" ] && _PRISM_DIR="$HOME/.claude/skills/prismstack"
[ -d ".claude/skills/prismstack" ] && _PRISM_DIR=".claude/skills/prismstack"
echo "PRISM_DIR: ${_PRISM_DIR:-NOT FOUND}"
```

**INTERACTION RULE:** Every decision point uses AskUserQuestion. One question at a time. Never batch. Never assume.

---

## Phase 1: Silent Detection (AUTO)

Scan the project for existing Prismstack state. Do not ask the user anything yet.

```bash
echo "=== Prismstack Project State Detection ==="

_SLUG=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
_PROJECTS_DIR=~/.gstack/projects/$_SLUG
_STATE_DIR="$_PROJECTS_DIR/.prismstack"
mkdir -p "$_STATE_DIR" 2>/dev/null

# Domain config
_HAS_DOMAIN_CONFIG=0
[ -f "$_STATE_DIR/domain-config.json" ] && _HAS_DOMAIN_CONFIG=1 && echo "DOMAIN_CONFIG: found"

# Skill map
_HAS_SKILL_MAP=0
[ -f "$_STATE_DIR/skill-map.json" ] && _HAS_SKILL_MAP=1 && echo "SKILL_MAP: found"

# Skill map artifacts (markdown)
_HAS_SKILL_MAP_MD=0
ls "$_PROJECTS_DIR"/*-skill-map-*.md 2>/dev/null | head -1 | grep -q . && _HAS_SKILL_MAP_MD=1 && echo "SKILL_MAP_MD: $(ls -t "$_PROJECTS_DIR"/*-skill-map-*.md 2>/dev/null | head -1)"

# Built domain stack (look for skills/ directory with SKILL.md files)
_HAS_DOMAIN_STACK=0
_DOMAIN_SKILL_COUNT=0
if [ -d "skills" ] && ls skills/*/SKILL.md 2>/dev/null | grep -q .; then
  _HAS_DOMAIN_STACK=1
  _DOMAIN_SKILL_COUNT=$(ls skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  echo "DOMAIN_STACK: $_DOMAIN_SKILL_COUNT skills found"
fi

# Check results
_HAS_CHECK_RESULTS=0
[ -f "$_STATE_DIR/check-results.json" ] && _HAS_CHECK_RESULTS=1 && echo "CHECK_RESULTS: found"

# Prior skill artifacts
_ARTIFACT_COUNT=$(ls "$_PROJECTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$_ARTIFACT_COUNT" -gt 0 ] && echo "ARTIFACTS: $_ARTIFACT_COUNT" && ls -t "$_PROJECTS_DIR"/*.md 2>/dev/null | head -5 | while read f; do echo "  $(basename "$f")"; done

echo "---"
echo "HAS_DOMAIN_CONFIG=$_HAS_DOMAIN_CONFIG"
echo "HAS_SKILL_MAP=$_HAS_SKILL_MAP"
echo "HAS_SKILL_MAP_MD=$_HAS_SKILL_MAP_MD"
echo "HAS_DOMAIN_STACK=$_HAS_DOMAIN_STACK"
echo "DOMAIN_SKILL_COUNT=$_DOMAIN_SKILL_COUNT"
echo "HAS_CHECK_RESULTS=$_HAS_CHECK_RESULTS"
echo "ARTIFACTS=$_ARTIFACT_COUNT"
```

---

## Phase 2: State Classification (AUTO)

Based on detection results, classify into exactly one state. First match wins:

1. **ITERATING** — `HAS_CHECK_RESULTS=1`: Stack has been quality-checked, user is in improvement cycle.
2. **BUILT** — `HAS_DOMAIN_STACK=1` AND `DOMAIN_SKILL_COUNT >= 3`: A domain stack has been built.
3. **PLANNED** — `HAS_SKILL_MAP=1` OR `HAS_SKILL_MAP_MD=1`: Skill map exists but not built yet.
4. **CONFIGURED** — `HAS_DOMAIN_CONFIG=1`: Domain identified but no skill map yet.
5. **RETURNING** — `ARTIFACTS > 0`: Some prior Prismstack work exists but state is unclear.
6. **BLANK** — Nothing found. First time user.

---

## Phase 3: State-Specific Routing (ASK)

Present ONE AskUserQuestion based on the classified state.

### BLANK

> [Re-ground] 正在對 {project} 做 Prismstack 導航。沒有找到任何 domain stack 相關的 artifact。
>
> [Simplify] 你看起來是第一次用 Prismstack。Prismstack 幫你把 gstack 的方法論搬到任何工作領域 — 行銷、遊戲開發、教育、影劇、或任何你的專業。
>
> 你在做什麼？
> A) 我想建一套新的領域 skill stack → /domain-plan（從這裡開始）
> B) 我有現成的材料想轉成 skill → /source-convert
> C) 我想自動化一個工具/網站 → /tool-builder
> D) 我只是看看 Prismstack 能做什麼 → 介紹 10 個 skill
>
> RECOMMENDATION: Choose A — 告訴我你的領域，我帶你走完規劃流程。

### CONFIGURED

> [Re-ground] 找到 domain config：領域 = {domain}。但還沒有 skill map。
>
> 看起來之前開始規劃過但沒完成。
> A) 繼續規劃 skill map → /domain-plan（會讀取之前的 config）
> B) 重新開始 → /domain-plan（從零規劃）
> C) 其他需求
>
> RECOMMENDATION: Choose A — 接續上次的進度。

### PLANNED

> [Re-ground] 找到 skill map（{N} 個 skill 規劃好了）。還沒搭建。
>
> A) 開始搭建 → /domain-build
> B) 修改 skill map → /domain-plan
> C) 先檢查規劃品質 → /skill-check design
> D) 其他
>
> RECOMMENDATION: Choose A — skill map 已經有了，搭建吧。

### BUILT

> [Re-ground] 找到已搭建的 domain stack：{N} 個 skill。
>
> A) 檢查品質 → /skill-check review --all
> B) 加新 skill → /skill-gen
> C) 改現有 skill → /skill-edit
> D) 轉換外部材料進來 → /source-convert
> E) 調整 workflow → /workflow-edit
> F) 用真實案例測試
>
> RECOMMENDATION: Choose A — 搭完第一件事就是檢查品質。

### ITERATING

> [Re-ground] 找到品質檢查結果。目前在迭代改進階段。
>
> A) 整體升級流程 → /domain-upgrade
> B) 針對特定 skill 修改 → /skill-edit
> C) 重新檢查品質 → /skill-check review --all
> D) 看 workflow 健康度 → /workflow-edit
>
> RECOMMENDATION: Choose A — /domain-upgrade 會幫你看該改什麼。

### RETURNING

> [Re-ground] 找到 {N} 個 artifact，但狀態不太清楚。
>
> 讓我幫你理一下：
> A) 我上次在規劃 → /domain-plan
> B) 我上次在搭建 → /domain-build
> C) 我上次在改 skill → /skill-edit
> D) 我不記得了 → 讓我看看 artifact 幫你判斷
>
> RECOMMENDATION: Choose D — 我看一下你的 artifact 再建議。

**STOP.** Wait for user's choice. One issue per AskUserQuestion.

---

## Phase 4: Load & Execute Sub-Skill

After user chooses a skill:

1. **Find the sub-skill:**
```bash
_SKILL_PATH="${_PRISM_DIR}/{chosen-skill}/SKILL.md"
echo "Loading: $_SKILL_PATH"
```

2. **Read the SKILL.md:**
```
Read the file at $_SKILL_PATH completely.
```

3. **Read its references/ if they exist:**
```
Read all files in ${_PRISM_DIR}/{chosen-skill}/references/
```

4. **Execute:** Follow the loaded skill's instructions starting from Phase 0. You ARE now that skill. The triage phase is over.

5. **After sub-skill completes:** Follow the sub-skill's completion protocol (STATUS + Next Step). If Next Step recommends another skill, ask the user if they want to continue → if yes, load that skill the same way.

### Special: /domain-build completion → auto-install Prismstack

When `/domain-build` finishes creating a new domain repo, automatically:
1. Ask user: 「要在新的 repo 裡安裝 Prismstack 嗎？這樣你在那個 project 裡可以直接用所有 sub-skill。」
2. If yes: run `bash {prismstack-source}/bin/install.sh --project` from inside the new repo
3. This gives the new project all 10 skills as independent slash commands

---

## Workflow Pipeline

```
Plan Phase:
  /domain-plan → /domain-build

Build Phase:
  /domain-build → /skill-check

Quality Phase:
  /skill-check → /domain-upgrade → /skill-edit
  /skill-check → /skill-gen (if gaps found)

Extend Phase:
  /source-convert → /skill-check
  /tool-builder → /skill-check
  /skill-gen → /skill-check

Iterate Phase:
  /domain-upgrade → /skill-edit → /skill-check → /workflow-edit
```

### Backtrack Rules

When a quality check or user feedback indicates a planning-level problem, route backward:
- Skill architecture fundamentally wrong → /domain-plan
- Individual skill needs rework → /skill-edit
- Workflow connections broken → /workflow-edit
- Missing coverage in domain → /skill-gen

---

## Completion

### Completion 萃取
報告 STATUS 前，回顧用戶在這次互動中的輸入。
萃取 4 種信號（expertise / correction / preference / benchmark）到 `domain-config.json`。
詳見 `shared/methodology/context-accumulation-guide.md`。
大部分 session 不需要萃取。

If triage only (user chose D in BLANK for intro):
```
STATUS: DONE
State detected: BLANK
Action: Introduced Prismstack's 10 skills
Next Step: /domain-plan — when user is ready to start
```

If sub-skill was loaded and executed:
```
STATUS: [from the sub-skill's completion]
Sub-skill: /skill-name
State detected: STATE_NAME
[Sub-skill's completion output]
```
