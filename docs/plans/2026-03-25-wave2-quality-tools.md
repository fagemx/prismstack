# Prismstack Wave 2 — Quality Tools Implementation Plan

> **For agentic workers:** Use subagent-driven-development to implement task-by-task.

**Goal:** Add 3 quality-focused skills: `/skill-check` (quality review), `/skill-gen` (single skill generation), `/skill-edit` (skill internals editing).

**Spec:** `docs/prismstack-v2-spec.md`
**Reference:** `C:\ai_project\guardian\docs\tech\gstack\` (knowledge base)

---

## Task 1: /skill-check Skill

**Files:**
- Create: `skills/skill-check/SKILL.md`
- Create: `skills/skill-check/references/design-check-7q.md`
- Create: `skills/skill-check/references/review-9d-6mines.md`
- Create: `skills/skill-check/references/pack-health-7eval.md`

3 modes: `design` (planning stage 7Q), `review` (post-build 9D+6 mines), `pack` (structure health 7 evaluations).

---

## Task 2: /skill-gen Skill

**Files:**
- Create: `skills/skill-gen/SKILL.md`
- Create: `skills/skill-gen/references/generation-workflow.md`

Generates a single new skill (not whole repo). Reads skill map, determines type, generates SKILL.md + references/, runs /skill-check design, wires into workflow.

---

## Task 3: /skill-edit Skill

**Files:**
- Create: `skills/skill-edit/SKILL.md`
- Create: `skills/skill-edit/references/editable-sections.md`

Edit skill internals: gotchas, scoring, forcing questions, references, anti-sycophancy, role identity, mode routing. Runs /skill-check review after edit.

---

## Task 4: Integration + Commit

- Run install test
- Verify all 6 skills install correctly
- Update CHANGELOG.md
- Commit + tag v0.2.0
