# Prismstack

**把任何工作領域變成一套 AI skill 系統**

[繁體中文](#) | English

10 個互動式 skill，把 gstack 方法論遷移到任何領域 — 行銷、教育、影劇、遊戲開發、或你的專業。一束光（gstack）進去，分散成多色（domain skills）出來。Built on [gstack](https://github.com/garrytan/gstack)'s engineering architecture, fully rewritten as a domain stack builder.

> **What this IS:** A builder that creates complete, runnable skill stacks for any domain — with quality scoring, fix loops, and anti-sycophancy baked in.
> **What this is NOT:** A collection of pre-made skills — it *generates* skills tailored to your domain.

gstack is Garry Tan's AI engineering workflow for Web/SaaS. Prismstack takes that same methodology and makes it portable: instead of using gstack's 25 skills directly, Prismstack builds you a custom set (10-30 skills) designed for *your* workflow. The engineering backbone (quality rubric, review methodology, artifact flow, completion protocol) maintains gstack-level rigor.

**Who this is for:**
- **Teams moving to AI workflows** — structured skill system instead of scattered prompts
- **Domain specialists** — turn your expertise into a reusable, shareable skill pack
- **Anyone who wants AI to follow their process** — not generic advice, your actual workflow

---

## Quick start: your first 10 minutes

1. Install Prismstack (30 seconds — see below)
2. Run `/prismstack` — it detects your project state and guides you.
3. Tell it your domain: "我做行銷" or give it a detailed spec — either works.
4. Choose **interactive** (step by step) or **auto** (runs Plan → Build → Check → Fix automatically).
5. You get a complete domain stack repo with install.sh, ready to use.

---

## Install — 30 seconds

**Requirements:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Git](https://git-scm.com/)

### Option A: Paste to Claude (recommended)

Open Claude Code and paste this:

> Install Prismstack: run **`git clone https://github.com/fagemx/prismstack.git ~/.claude/skills/prismstack`** then tell the user Prismstack is ready — run `/prismstack` to start.

### Option B: Add to your project

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

## See it work

### Interactive mode — step by step

```
You:    /prismstack

Claude: 正在偵測 project 狀態...
        State: BLANK — 沒有找到 domain stack。

        你想怎麼建？
        A) 互動模式 — 我帶你一步一步走
        B) 自動模式 — 告訴我領域，我自動跑完

You:    A

Claude: 你的領域是什麼？

You:    行銷，主要做社群廣告素材

Claude: 我推導了工作生命週期：
        策略 → 發想 → 規格 → 生產 → 審查 → 投放 → 分析

        18 個 skill 規劃好了：

        | # | Skill | Type | Layer |
        |---|-------|------|-------|
        | 1 | /market-research | Review | Strategy |
        | 2 | /campaign-strategy | Bridge | Strategy |
        | ... | ... | ... | ... |

        Skill Map Quality Score: 8/10

        A) 這樣可以，開始搭建
        B) 我要加 skill
        C) 我要改

You:    A

Claude: 開始搭建... (每 5 個 skill 停一次確認)
        → 18 個 skill 生成完成
        → validate-repo.sh: 5/5 pass
        → 安裝到你的 project 嗎？

You:    好

Claude: ✅ 安裝完成。試試 /market-research 或 /campaign-strategy。
```

### Auto mode — one command

```
You:    /prismstack

Claude: State: BLANK

        你想怎麼建？
        A) 互動模式
        B) 自動模式

You:    B

Claude: 領域？
You:    教育課程設計

Claude: 品質門檻？
        A) Draft (12/30) — 最快
        B) Usable (18/30) — 推薦
        C) Production (24/30) — 最慢

You:    B

Claude: 開始自動搭建。你可以去做別的事。

        ⏳ PLAN... 16 skills mapped
        ⏳ BUILD... 16 skills generated
        ⏳ CHECK... avg 15/30 (Draft+) — below threshold
        ⏳ FIX round 1... 12 auto-fixes applied
        ⏳ RE-CHECK... avg 19/30 (Usable) ✅

        ✅ 完成。
        Skills: 16 | Quality: 19/30 (Usable) | Fix rounds: 1
        Repo: ./education-stack/
        Install: cd education-stack && bash bin/install.sh --project
```

---

## The workflow

Prismstack is a process, not a collection of tools. Skills are ordered the way a domain stack gets built:

**Plan → Build → Check → Fix → Iterate**

Each skill feeds the next. `/domain-plan` produces a skill map that `/domain-build` reads. `/domain-build` generates skills that `/skill-check` audits. Low scores trigger the fix loop. All outputs are saved to `~/.gstack/projects/` so downstream skills find them automatically — even across sessions.

| Skill | Your specialist | What they do |
|-------|----------------|--------------|
| `/prismstack` | **Triage Navigator** | Detects project state (BLANK/PLANNED/BUILT/ITERATING), guides you to the right skill. Run this first. Supports interactive and auto modes. |
| `/domain-plan` | **Domain Architect** | Derive skill map from your domain: lifecycle mapping, gap analysis, independence tests. Outputs skill-map.md + workflow-graph.md. |
| `/domain-build` | **Stack Builder** | Auto-generate complete domain repo: scaffold, all skills, install.sh, artifact flow wiring. Runs validation. |
| `/skill-check` | **Quality Inspector** | 3 modes: `design` (7Q planning check), `review` (15D + 6 mines), `pack` (structure health). Batch mode with `--all`. Fix loop built in. |
| `/skill-gen` | **Skill Craftsman** | Add a single new skill to existing stack. Independence tests + 7Q design check + workflow wiring. |
| `/skill-edit` | **Skill Surgeon** | Edit skill internals: gotchas, scoring, forcing questions, anti-sycophancy. Before/after scoring delta. |
| `/source-convert` | **Knowledge Translator** | Convert any source (article, video, book, repo, prompt, SOP, ECC skill) into skill content. 5-level target placement. |
| `/tool-builder` | **Tool Craftsman** | Build automation skills: browser, API, CLI, file processing. Dual-layer: hands-on mode + meta mode (builds a skill that can do it). |
| `/domain-upgrade` | **Stack Steward** | Persistent improvement: listen to needs, collect test feedback, dispatch to the right skill. 3 modes: feedback / upgrade / listen. |
| `/workflow-edit` | **Workflow Architect** | View/edit artifact flow, skill connections, workflow graph. Validates: no orphans, no cycles, bridge coverage. |

---

## What makes this different from 30,000 other skills

Most skills on the market are **knowledge packs** — best practices stuffed into markdown. Prismstack generates **interactive workflow systems**:

| | Market skills | Prismstack-generated skills |
|---|---|---|
| **Essence** | Knowledge (Claude reads and knows more) | Work posture (Claude's behavior changes) |
| **Interaction** | Runs to completion, dumps output | STOP gates, asks user at every judgment |
| **Quality** | "Looks good" (no scoring) | Scoring formula + 0/1/2 per dimension + evidence |
| **Error handling** | None | Fix loop: baseline → triage → fix → re-score → delta |
| **Anti-sycophancy** | None (Claude says "great job") | Deny list + forcing questions + push-back |
| **Connection** | Isolated (skills don't talk) | Artifact flow (upstream discovery → downstream consumption) |
| **Memory** | Fresh every time | Config + logs (remembers what user said) |

---

## Methodology

Prismstack's quality comes from 5 digested methodology files (834 lines total, adapted from gstack's knowledge base):

| File | What it teaches |
|------|----------------|
| `skill-map-methodology.md` | How to derive a skill map: lifecycle, gap analysis, independence tests |
| `skill-craft-guide.md` | How to write a good skill: 8 principles, 7 patterns, 10 how-to's (scoring, gotchas, fix loop, STOP gates, anti-sycophancy, forcing questions, recovery, artifact flow, input sensitivity, proportional output) |
| `quality-standards.md` | How to judge quality: 15D rubric, calibration benchmarks, 6 review principles |
| `system-wiring-guide.md` | How to connect skills: artifact flow, chaining, completion protocol |
| `fix-loop-guide.md` | How to fix issues: baseline → triage → AUTO-FIX/ASK/ESCALATE → re-score → delta |

---

## Relationship to gstack

| | gstack | Prismstack |
|---|--------|------------|
| **Purpose** | AI engineering workflow (Web/SaaS) | Domain stack builder (any domain) |
| **Skills** | 25 fixed skills (review, QA, ship...) | 10 builder skills that generate 10-30 domain skills |
| **Vocabulary** | user, feature, API, MRR, churn | domain-specific (generated per domain) |
| **Dependency** | Standalone | Standalone (no gstack required) |

**Borrowed from gstack:**
- Review methodology (classify → score → triage → fix → re-score)
- Anti-sycophancy 3-layer system
- Artifact flow (shared storage, discovery, supersedes chain)
- Completion protocol (DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT)
- AskUserQuestion 4-segment format

**Original to Prismstack:**
- Domain migration methodology (lifecycle → gap → independence → skill map)
- 10 how-to's for designing skill mechanisms (scoring, gotchas, fix loop...)
- Dual mode (interactive + autonomous with generator-evaluator separation)
- Input sensitivity (4-level quality detection → proportional output)
- Context accumulation (completion-time extraction, cross-session memory)
- Tool builder (dual-layer: hands-on + meta)

---

## File structure

```
prismstack/
├── README.md                              ← This file
├── CLAUDE.md                              ← Developer handoff
├── VERSION                                ← 0.5.0
├── CHANGELOG.md
├── LICENSE                                ← MIT
├── bin/
│   ├── install.sh                         ← Unix installer (--project / --global)
│   ├── install.ps1                        ← Windows installer
│   └── prism-slug.sh                      ← Repo slug utility
├── skills/
│   ├── prism-routing/SKILL.md             ← Triage + auto mode orchestrator
│   ├── domain-plan/                       ← + 4 reference files
│   ├── domain-build/                      ← + 6 reference files + validate script
│   ├── skill-check/                       ← + 3 reference files (15D rubric)
│   ├── skill-gen/                         ← + 2 reference files
│   ├── skill-edit/                        ← + 1 reference file
│   ├── source-convert/                    ← + 2 reference files
│   ├── tool-builder/                      ← + 2 reference files
│   ├── domain-upgrade/                    ← + 1 reference file
│   ├── workflow-edit/                     ← + 2 reference files
│   └── shared/
│       ├── methodology/                   ← 5 digested methodology files (834 lines)
│       ├── preamble.md                    ← Shared session setup
│       ├── completion-protocol.md         ← STATUS definitions + extraction
│       ├── ask-format.md                  ← AskUserQuestion 4-segment format
│       ├── artifact-conventions.md        ← Naming + storage rules
│       ├── anti-sycophancy.md             ← 3-layer system
│       ├── stop-gates.md                  ← Placement rules
│       └── state-conventions.md           ← Per-project state files
├── test/
│   └── install-test.sh                    ← 67 checks
└── docs/
    ├── prismstack-v2-spec.md              ← Full spec
    ├── design/dual-mode-design.md         ← Auto mode architecture
    └── plans/                             ← Implementation plans
```

---

## Troubleshooting

**Skill not showing up?** Run `bash bin/install.sh --project` from your project root. Restart Claude Code.

**Only `/prismstack` works, sub-skills don't?** You're on global install. Sub-skills work through `/prismstack` triage, or use `--project` install for direct access.

**Windows?** Use Git Bash or WSL. Or use `pwsh bin/install.ps1 --project`.

**Test install:** `bash test/install-test.sh` — should show 67/67 pass.

---

## License

MIT — see [LICENSE](LICENSE).
