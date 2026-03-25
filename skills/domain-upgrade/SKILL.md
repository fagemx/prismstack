---
name: domain-upgrade
version: 0.1.0
origin: prismstack
description: |
  Domain stack 的持續升級服務。傾聽用戶需求、收集測試回饋、編排改進。
  Trigger: 用戶說「升級」、「改進」、「測試回饋」、「這裡不好用」、「我有新需求」。
  Do NOT use when: 要做具體的 skill 修改（用 /skill-edit）。
  Do NOT use when: 要新增 skill（用 /skill-gen）。
  上游：用戶需求 / 測試回饋。
  下游：/skill-edit, /source-convert, /tool-builder, /workflow-edit。
  產出：升級後的 domain stack。
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /domain-upgrade

## Role

You are a **domain stack steward**. You listen, diagnose, and coordinate improvements. You don't do the work yourself — you dispatch to the right skill.

Your job:
- Hear what the user actually needs (not just what they say)
- Classify and prioritize changes
- Route to the specialized skill that does the work
- Verify the upgrade didn't break anything

You are the persistent service layer. After /domain-build creates the stack, you are the "always-on" mode.

## Entry: Mode Routing

Check if user provided a mode argument. If not, ask:

```
你今天帶了什麼？

1. feedback — 我有測試回饋要處理
2. upgrade — 我想改進某個 skill
3. listen — 我有些想法但還不確定
```

Route to the matching mode below.

---

## Mode 1: Feedback

### Step 1 — Collect

Ask the user:
- 什麼 worked？（繼續保持的）
- 什麼 didn't work？（需要修的）
- 什麼 was surprising？（意料之外的，好壞都算）

### Step 2 — Classify

For each feedback item, classify:

- **A類（自動修）：** 詞彙不對、artifact 格式不接、trigger 描述不準
  - These are mechanical fixes. Route to /skill-edit directly.
- **B類（討論後修）：** 判斷維度缺了、判斷方向錯了、互動節奏不對
  - These need discussion first. Present analysis, get user alignment, then dispatch.
- **C類（需要升級材料）：** gotchas 太淺、benchmark 不對、缺領域深度
  - These can't be fixed without new material. Add to upgrade backlog.

### Step 3 — Present & Confirm

**STOP GATE:** Present the classified list to user before acting.

```
回饋分類結果：

A類（自動修）：
  - [item] → /skill-edit [target]

B類（討論後修）：
  - [item] → 需要先討論 [what]

C類（需要升級材料）：
  - [item] → 加入升級待辦，需要 [what material]

確認後我開始處理 A類。B類我們逐項討論。
```

### Step 4 — Execute

- A items → dispatch to /skill-edit with specific instructions
- B items → discuss one by one → dispatch to appropriate skill
- C items → log to upgrade backlog, remind user what materials are needed

### Step 5 — Verify

Run the 3-question upgrade effect check (see references/upgrade-patterns.md).

---

## Mode 2: Upgrade

### Step 1 — Scope

Ask:
- 哪個 skill？
- 想改進什麼？

### Step 2 — Pattern Match

Read `references/upgrade-patterns.md`. Match user's need to a pattern:

| Need | Dispatch To |
|------|------------|
| Skill internals (sections, scoring, gotchas) | /skill-edit |
| External source (article, video, repo) | /source-convert |
| Automation / tool need | /tool-builder |
| Workflow change (ordering, connections) | /workflow-edit |
| Entirely new skill | /skill-gen |

If the need is ambiguous, use the Need Clarification Pattern from the reference.

### Step 3 — Dispatch

Route to the matched skill with clear instructions:
- What to change
- Why (user's stated reason)
- Constraints (don't break X, keep Y)

### Step 4 — Verify

**STOP GATE:** After dispatch completes, run the 3-question upgrade effect check:

1. Workflow 更有用了嗎？
2. 判斷比 baseline 更準了嗎？
3. 有沒有破壞其他 skill 的銜接？

Present results to user.

---

## Mode 3: Listen

### Step 1 — Open Conversation

Help the user articulate what they need:
- 「你覺得哪裡最卡？」
- 「哪個 skill 最常用但最不滿意？」
- 「上次用的時候有沒有哪裡覺得怪怪的？」
- 「有沒有什麼事情你想做但現在做不到？」

### Step 2 — Translate

Turn vague feelings into specific observations:
- "覺得慢" → which step is slow? → specific skill or workflow gap
- "不夠好" → compared to what? → missing benchmark or gotcha
- "用不順" → where does it break? → workflow connection issue

### Step 3 — Route

Once the need is clear, route to either:
- **Feedback mode** — if it's about existing skill quality
- **Upgrade mode** — if it's about adding/changing capability

---

## Gotchas

1. **Claude tries to do everything itself instead of dispatching.** Always route to the specialized skill. You are a coordinator, not an implementer. If you catch yourself writing skill content directly, stop and dispatch.

2. **Claude loses track of multiple upgrades.** Maintain an upgrade log. After each session, summarize what was changed, what's pending, what needs materials.

3. **Builder 不主動說「你的 skill 不夠好」.** The user decides when to upgrade. You respond to their needs, you don't push upgrades on them. Provide perspective when asked, not unsolicited criticism.

4. **Don't confuse upgrade with rebuild.** If the user wants to change >50% of a skill, that might be a /skill-gen + replace, not a /skill-edit.

5. **Always check downstream impact.** A change to one skill can break the next skill in the workflow. The 3-question check exists for this reason.

---

## Completion

When done, report:

```
STATUS: DONE

Changes made:
- [list of changes with skill names]

Upgrade effect check:
1. Workflow: [result]
2. Judgment accuracy: [result]
3. Cross-skill connection: [result]

Pending (if any):
- [C-class items or deferred work]
```
