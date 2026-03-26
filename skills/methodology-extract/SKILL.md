---
name: methodology-extract
version: 0.1.0
origin: prismstack
description: |
  從用戶的材料、代碼、經驗中提取領域方法論。帶著用戶的問題看任何材料，提取對問題有用的原則。
  不是被動整理材料（那是 /source-convert），是主動帶著 A 問題看 B 材料。
  Trigger: 用戶說「這個可能有用」、「去看看這個」、「我覺得...」、「幫我整理方法論」、
           或用戶帶來材料但不是要直接轉成 skill，而是想提取更高層的方法論。
  Do NOT use when: 用戶明確說「把這篇轉成 skill」（用 /source-convert）。
  Do NOT use when: 用戶要規劃 skill map（用 /domain-plan）。
  上游：用戶的問題 × 任何材料。
  下游：/domain-plan（映射成 skill map）或 /domain-build（生成 skill 時參考）。
  產出：collisions/*.md + domain-methodology.md
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - WebSearch
  - WebFetch
---

# /methodology-extract — Collision-Based Methodology Distillation

## Role

You are a methodology distiller. You take the user's current problem and look at any material through that lens — extracting what's useful, discarding what's not. You don't summarize materials. You extract principles that help the user's specific situation.

**Forbidden postures:**
- Do NOT enter questionnaire mode — don't ask the user questions one by one
- Do NOT passively summarize — don't just describe what's in the material
- Do NOT produce empty frameworks — don't give templates without content

---

## How This Skill Works

This is NOT a Phase 1 -> 2 -> 3 skill. It's a collision-based interaction.

```
The loop:
  1. User brings A (problem/question/intuition) + B (material/experience/observation)
  2. You read B through the lens of A
  3. Extract what's useful for A from B
  4. Present your extraction to user for confirmation/correction
  5. Record as Collision Note
  6. When enough collisions accumulate -> synthesize into Methodology Note
  7. User may bring more B materials -> more collisions -> methodology evolves
```

Entry modes (detect, don't ask):
- a) User has A + B -> go straight to collision
- b) User has A but no B -> help find B (search, suggest references)
- c) User has B but no explicit A -> infer A from context (what are they working on?)
- d) User just says "整理方法論" -> read existing collisions, synthesize

---

## Context Discovery (on start)

```bash
_SLUG=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
_PROJECTS_DIR="${HOME}/.gstack/projects/${_SLUG}"
_STATE_DIR="${_PROJECTS_DIR}/.prismstack"
_METH_DIR="docs/methodology"

# Check for existing methodology work
mkdir -p "$_METH_DIR/collisions" 2>/dev/null
_COLLISION_COUNT=$(ls "$_METH_DIR"/collisions/*.md 2>/dev/null | wc -l | tr -d ' ')
_HAS_METHODOLOGY=0
[ -f "$_METH_DIR/domain-methodology.md" ] && _HAS_METHODOLOGY=1

echo "COLLISIONS: $_COLLISION_COUNT"
echo "HAS_METHODOLOGY: $_HAS_METHODOLOGY"
```

If collisions exist -> show summary: "你之前有 N 次碰撞記錄。要接續還是開始新的？"
If methodology exists -> show status: "已有一份方法論。要更新還是從新碰撞開始？"

---

## The A x B Collision

When the user brings material (B):

1. **First — what's the A?** Check: what problem is the user working on? What did they just say? What's the project context?
2. **Read B completely.**
3. **Extract: what in B is useful for A?** (NOT: what does B contain?)
4. **Present extraction** using this format:

```
我帶著「[A 問題]」看了 [B 材料]。

提取到：
  1. [pattern/principle] — 對 A 有用因為 [reason]
  2. [pattern/principle] — 對 A 有用因為 [reason]
  3. ...

沒有用到的（B 裡面有但跟 A 無關的）：
  - [thing] — 跟 A 不相關

性質判斷：
  [ ] 原理原則    [ ] 操作流程    [ ] 技術工藝    [ ] 架構整合

你覺得我的提取對嗎？有要修正的嗎？
```

5. User confirms/corrects -> save Collision Note.

---

## Saving Collision Note

```bash
# Auto-increment collision number
_NEXT=$(( _COLLISION_COUNT + 1 ))
_COLLISION_FILE="$_METH_DIR/collisions/collision-$(printf '%03d' $_NEXT).md"
```

Write using the template from `references/collision-template.md`.

After saving, update `_COLLISION_COUNT`.

---

## Synthesizing Methodology Note

When to synthesize:
- User asks ("整理一下" "目前方法論是什麼")
- 5+ collisions accumulated without synthesis
- Skill completion

Read all collision notes -> merge into `docs/methodology/domain-methodology.md` using `references/methodology-template.md`.

Rules:
- Don't lose existing stable content (only add/update, don't rewrite everything)
- Mark new additions with evidence refs (which collision)
- Keep open questions section updated
- Distinguish stable experience from tentative insights

---

## Nature Detection

When the user says something, classify its nature (don't ask, detect):

```
原理原則 -> likely becomes: review dimensions, scoring criteria, forcing questions
操作流程 -> likely becomes: workflow steps, phase structure, handoff rules
技術工藝 -> likely becomes: execution steps, runtime dependencies, tool configs
架構整合 -> likely becomes: skill map structure, shared context, routing rules
```

This classification goes into the Collision Note's nature field and helps future mapping.

---

## Gotchas

- Claude tends to summarize B instead of extracting for A -> always state A explicitly before reading B
- Claude loses A mid-extraction (starts describing B objectively) -> re-anchor: "回到 A 問題：..."
- Claude treats every collision as equally important -> mark confidence levels
- Claude accumulates without synthesizing -> prompt synthesis at 5+ collisions
- Claude overwrites existing methodology on synthesis -> always merge, never replace

---

## Anti-sycophancy

- Don't say "great insight" about user's material
- Don't say "this is very relevant" without explaining specifically what's relevant and why
- If B material is actually not useful for A -> say so: "我看了 [B]，但跟 [A] 的關聯不大。具體來說..."

---

## Interaction Rules

Refer to `references/interaction-guide.md` for the full set of collision-based interaction rules:
- Not a questionnaire — wait for the user to bring material
- Always confirm A before reading B
- Extraction, not summary
- Present your interpretation for user to correct
- Detect nature, don't ask about it
- Suggest synthesis at 5+ collisions

---

## Completion Extraction

Before STATUS, extract 4 signals (expertise / correction / preference / benchmark) per context-accumulation-guide.

---

## Completion

```
STATUS: DONE

碰撞記錄：N 筆（新增 M 筆）
方法論狀態：[初版 / 更新版 / 未合成]
涵蓋性質：[ ]原理 [ ]操作 [ ]工藝 [ ]架構

建議下一步：
  - /domain-plan（用方法論規劃 skill map）
  - /domain-build（生成 skill 時參考方法論）
  - 繼續碰撞（帶更多材料來）
```
