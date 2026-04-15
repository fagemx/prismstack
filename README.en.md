# Prismstack

**Turn your domain expertise into an AI skill system**

[繁體中文](README.md)

You're a marketing expert, educator, game designer, or any domain professional. You have your own workflows, judgment criteria, and quality standards. Prismstack turns all of that into a runnable, shareable, continuously improvable AI skill system.

One beam of light (your expertise) goes in, a spectrum of colors (actionable AI skills) comes out.

> **What this IS:** Your knowledge and processes, structured into a working system that AI can follow — with quality scoring, fix loops, and anti-sycophancy built in.
> **What this is NOT:** A generic AI toolkit — it generates skills *specific to your domain*, not one-size-fits-all templates.

**Who this is for:**
- **Teams with workflows** — upgrade from "everyone uses AI differently" to "team shares one AI work system"
- **Domain experts** — your three sentences contain a complete scoring formula and judgment criteria; Prismstack understands and converts them
- **Anyone who wants AI to follow their process** — not generic advice, your actual workflow

---

## Quick Start: 10 Minutes

1. Install Prismstack (30 seconds — see below)
2. Run `/prismstack` — auto-detects your project state and guides you
3. Tell it your domain: "I do marketing" or hand it a detailed spec — both work
4. Choose **interactive** (step by step) or **auto** (runs Plan → Build → Check → Fix automatically)
5. You get a complete domain skill repo with install.sh, ready to use

---

## Install — 30 Seconds

**Requirements:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Git](https://git-scm.com/)

### Option A: Paste to Claude (recommended)

Open Claude Code and paste:

> Install Prismstack: run **`git clone https://github.com/fagemx/prismstack.git ~/.claude/skills/prismstack`** then tell the user Prismstack is ready — run `/prismstack` to start.

### Option B: Project install

```bash
git clone https://github.com/fagemx/prismstack.git
cd prismstack
bash bin/install.sh --project    # installs to current project's .claude/skills/
```

All sub-skills (`/domain-plan`, `/skill-check`, etc.) become independently invocable.

### Option C: Global install

```bash
bash bin/install.sh --global     # installs to ~/.claude/skills/
```

Only `/prismstack` is directly invocable; it loads sub-skills internally.

---

## See It Work

### Interactive mode — step by step

```
You:    /prismstack

Claude: Detecting project state...
        State: BLANK — no domain stack found.

        How do you want to build?
        A) Interactive — I'll walk you through step by step
        B) Auto — tell me the domain, I'll run the full pipeline

You:    A

Claude: What's your domain?

You:    Marketing, mainly social media ad creatives

Claude: I derived the work lifecycle:
        Strategy → Ideation → Spec → Production → Review → Launch → Analytics

        18 skills planned:

        | # | Skill | Type | Layer |
        |---|-------|------|-------|
        | 1 | /market-research | Review | Strategy |
        | 2 | /campaign-strategy | Bridge | Strategy |
        | ... | ... | ... | ... |

        Skill Map Quality Score: 8/10

        A) Looks good, start building
        B) I want to add skills
        C) I want to modify

You:    A

Claude: Building... (pauses every 5 skills for confirmation)
        → 18 skills generated
        → validate-repo.sh: 5/5 pass
        → Install to your project?

You:    Yes

Claude: ✅ Installed. Try /market-research or /campaign-strategy.
```

### Auto mode — one command

```
You:    /prismstack

Claude: State: BLANK

        How do you want to build?
        A) Interactive
        B) Auto

You:    B

Claude: Domain?
You:    Education course design

Claude: Quality threshold?
        A) Draft (12/30) — fastest
        B) Usable (18/30) — recommended
        C) Production (24/30) — slowest

You:    B

Claude: Starting auto-build. You can step away.

        ⏳ PLAN... 16 skills mapped
        ⏳ BUILD... 16 skills generated
        ⏳ CHECK... avg 15/30 (Draft+) — below threshold
        ⏳ FIX round 1... 12 auto-fixes applied
        ⏳ RE-CHECK... avg 19/30 (Usable) ✅

        ✅ Done.
        Skills: 16 | Quality: 19/30 (Usable) | Fix rounds: 1
        Repo: ./education-stack/
        Install: cd education-stack && bash bin/install.sh --project
```

---

## Workflow

Prismstack is a process, not a collection of tools. Skills follow the order a domain stack gets built:

**Extract → Plan → Build → Check → Fix → Iterate**

Each skill's output feeds the next. `/methodology-extract` distills your expertise into structured methodology. `/domain-plan` uses it to design a skill map. `/domain-build` generates skills. `/skill-check` audits quality. Low scores trigger the fix loop. All outputs are saved to `~/.prismstack/projects/` so downstream skills find them automatically — even across sessions.

| Skill | Your Specialist | What They Do |
|-------|----------------|--------------|
| `/prismstack` | **Triage Navigator** | Detects project state (BLANK / PLANNED / BUILT / ITERATING), guides you to the right skill. Supports interactive and auto modes. |
| `/methodology-extract` | **Methodology Distiller** | Looks at any material through the lens of your current problem, extracts useful methodology. Collision-based interaction: your intuition × any source = structured principles. Not a questionnaire — a thinking collision. |
| `/domain-plan` | **Domain Architect** | Derives skill map from your domain: lifecycle mapping, gap analysis, independence tests. References your methodology if available. |
| `/domain-build` | **Stack Builder** | Auto-generates complete domain repo: scaffold, all skills, install.sh, artifact flow wiring. Runs validation. |
| `/skill-check` | **Quality Inspector** | 3 modes: `design` (7Q planning check), `review` (15D + 6 mines), `pack` (structure health). Batch mode with `--all`. Fix loop built in. |
| `/skill-gen` | **Skill Craftsman** | Add a single new skill to existing stack. Independence tests + 7Q design check + workflow wiring. |
| `/skill-edit` | **Skill Surgeon** | Edit skill internals: gotchas, scoring formulas, forcing questions, anti-sycophancy. Before/after scoring delta. |
| `/source-convert` | **Knowledge Translator** | Convert a specific source (article, video, book, repo, prompt, SOP) into skill content. 5-level target placement. |
| `/tool-builder` | **Tool Craftsman** | Build automation skills: browser, API, CLI, file processing. Dual-layer: hands-on mode + meta mode (builds a skill that can do it). |
| `/domain-upgrade` | **Stack Steward** | Persistent improvement: listen to needs, collect test feedback, dispatch to the right skill. 3 modes: feedback / upgrade / listen. |
| `/workflow-edit` | **Workflow Architect** | View/edit artifact flow, skill connections, workflow graph. Validates: no orphans, no cycles, bridge coverage. |
| `/super-guide` | **Hands-On Coach** | Stuck? Don't know the next step? The coach uses your own stack as teaching material. 3 modes: contextual teaching / Q&A / diagnosis. |

---

## Why Not Just Write Prompts?

You can write a good prompt. But your team has 5 people, each writing different prompts, inconsistent quality. Someone leaves, and the prompt is gone.

Prismstack turns your expertise into a **manageable system**:

| | Scattered Prompts | Prismstack Skills |
|---|---|---|
| **Ownership** | In someone's head — gone when they leave | In shared directory — anyone can use |
| **Quality** | By feel ("looks fine") | Scoring formulas, dimensions, evidence |
| **AI attitude** | AI agrees with everything | Forbidden empty praise + forcing questions + push-back |
| **Flow** | Runs to completion in one shot | Stops at every judgment point to ask you |
| **Chaining** | Each on its own | Previous step's output feeds the next |
| **Improvement** | Starts from zero next time | Remembers what you said, gets better over time |
| **Errors** | No idea what's wrong | Auto-detect → classify → fix → verify |

---

## Methodology

Prismstack includes 9 built-in methodology files that teach AI how to build good skills:

**Building scaffolds (how to build):**

| Methodology | What It Solves |
|-------------|---------------|
| **Skill Map Derivation** | How to figure out which skills your workflow needs |
| **Skill Craft Guide** | How to write a good skill: 10 principles + 7 structural patterns + 5 templates (each with smart defaults derivation rules) |
| **System Wiring Guide** | How to chain skills together + 6 pipeline composition patterns (Sequential / Fan-Out / Fan-In / Review Loop / Gateway / Feedback Injection) |
| **Iteration Loop Guide** | In-skill iterative improvement: 8-phase loop (Review → Ideate → Modify → Snapshot → Verify → Guard → Decide → Log) |

**Quality assurance (how to improve):**

| Methodology | What It Solves |
|-------------|---------------|
| **Quality Standards** | How to judge skill quality: 15 dimensions + calibration benchmarks + 6 common traps |
| **Fix Loop Guide** | How to fix issues: detect → classify → fix → guard check → verify → compare |
| **Functional Test Guide** | Test skills with real tasks: 9-step test loop + 8-dimension stress test matrix (advanced, for mature stacks) |

**System automation (how to run automatically):**

| Methodology | What It Solves |
|-------------|---------------|
| **Auto Decision Guide** | 6 decision principles for auto mode + 3 decision classifications (Mechanical / Taste / User Required) |
| **Context Accumulation Guide** | Remember user expertise across sessions: 5 signal types + confidence decay + auto-injection at startup |

The 10 principles in Skill Craft Guide cover: trigger-first, role switching, flow externalization, gotchas as highest value, strict where fragile, main+references split, recovery definition, readable output, pressure testing (Production tier), and adversarial refinement for generation.

---

## Technical Background

Prismstack's engineering methodology is derived from [gstack](https://github.com/garrytan/gstack) (Garry Tan's AI engineering workflow), fully digested and rewritten for the context of "helping users build skill stacks." No gstack installation required.

**Core difference:**
- gstack = 25 fixed Web/SaaS engineering skills
- Prismstack = 12 builder skills (including hands-on coach) that generate 10–50 domain-specific skills

**Unique to Prismstack:**
- Methodology extraction (look at any material through your problem's lens, distill structured principles)
- Dual mode (interactive + autonomous, with generator-evaluator separation)
- Input sensitivity (give one sentence or a full spec — output quality matches input quality)
- Context accumulation (remembers what you said, improves across sessions, confidence decay prevents stale info)
- Tool building (dual-layer: automate directly + produce a skill that can automate)
- Adversarial refinement (Author-A → Critic → Author-B → Synthesize — debate produces better skill content)
- Smart defaults (auto-derive scoring weights, gotchas, role identity from domain signals — less user input needed)
- Pipeline pattern library (6 composition patterns + selection guide for effective workflows)
- Auto mode upgrade (state machine + backtrack + 6 decision principles + approval gate)

---

## How It Works Under the Hood

### What's inside a skill

Each skill Prismstack generates isn't a prompt — it's a complete work node:

```
Your /ad-check skill (creative QA) contains:

Role lock       →  "You are an ad quality inspector, not a helper"
Trigger         →  When to use, when NOT to use, adjacent skills
Scoring         →  Composition 25% / Brand 20% / CTA 20% / Color 15% / ...
Stop gates      →  Pauses after each dimension for your confirmation
Anti-sycophancy →  Forbidden: "looks good overall" — must score per dimension with evidence
AI blind spots  →  "Claude tends to ignore text obscured by characters" + redirect
Forcing Qs      →  "Can you still read this CTA at mobile screen size?"
Fix loop        →  Issue found → auto-classify → fix what's fixable → re-score → delta
Upstream/down   →  Auto-finds /ad-layout output, recommends /compliance-review next
```

### How skills chain together

```
/brief-intake produces brief-001.md
    ↓ auto-saved to shared directory
/creative-direction auto-discovers the brief on startup
    ↓ review complete, produces direction-001.md
/production-plan auto-discovers the review
    ↓ splits into tasks, produces task-batch-001.md
/ad-layout auto-discovers the task list
    ↓ ...chains all the way to launch
```

You never need to tell AI "go read that file." Each skill knows where to find upstream output.

### How quality is guaranteed

```
After generation, auto-review (15 dimensions, 0-2 points each):

Entry layer:    Clear trigger? Role locked? Mode routing?
Flow layer:     Progress tracked? Stop gates? Interrupt recovery?
Knowledge layer: AI blind spots? Scoring formula? Benchmarks?
Structure layer: Files split well? Helper scripts? State memory?
System layer:   Finds upstream? Output format correct? Knows next step?

Below threshold → auto fix loop:
  1. Record baseline score
  2. Classify issues (auto-fix / ask user / needs redesign)
  3. Auto-fix what's fixable
  4. Re-score
  5. Report delta (before 17 → after 23)
```

### How your knowledge enters the skill

```
You say: "Ad review should check composition, brand consistency, CTA — the rest doesn't matter"

Prismstack hears:
  → 3 scoring dimensions (composition, brand, CTA)
  → Weight hint ("the rest doesn't matter" = these three are high-weight)
  → Auto-generates: Composition 25% / Brand 20% / CTA 20% / Other 35%
  → Asks you to confirm (not asking what dimensions — showing its interpretation for correction)

One sentence → Draft quality (12-15/30)
Expert notes → Usable quality (18-22/30)
Full spec → Production quality (24-28/30)

Input quality = output quality. Won't waste your expertise, won't pretend one sentence produces perfection.
```

---

## Troubleshooting

**Skill not showing up?** Run `bash bin/install.sh --project` from your project root. Restart Claude Code.

**Only `/prismstack` works, sub-skills don't?** You're on global install. Sub-skills work through `/prismstack` triage, or use `--project` install for direct access.

**Windows?** Use Git Bash or WSL. Or use `pwsh bin/install.ps1 --project`.

**Test install:** `bash test/install-test.sh` — should show 72/72 pass.

---

## License

MIT — see [LICENSE](LICENSE).
