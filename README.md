# Prismstack

**把你的專業知識變成一套 AI skill 系統**

[繁體中文](#) | English

你是行銷專家、教育工作者、遊戲設計師、或任何領域的專業人士。你有自己的工作流程、判斷標準、品質門檻。Prismstack 幫你把這些變成一套可運行、可共享、可持續改進的 AI skill 系統。

一束光（你的專業知識）進去，分散成多色（可操作的 AI skills）出來。

> **What this IS:** 你的知識和流程的結構化——變成 AI 能遵循的工作系統，帶有品質評分、修復迴圈、和防止 AI 敷衍的機制。
> **What this is NOT:** 通用 AI 工具合集——它生成的是*你的領域*的專屬 skill，不是萬用模板。

**Who this is for:**
- **有工作流程的團隊** — 把「每個人各自用 AI」升級成「團隊共用一套 AI 工作系統」
- **領域專家** — 你的三句話裡有完整的評分公式和判斷標準，Prismstack 聽得懂、轉得出
- **想讓 AI 照自己的方式工作的人** — 不是通用建議，是你的實際流程

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

## 為什麼不直接寫 prompt？

你可以寫一個好的 prompt。但你的團隊有 5 個人，每個人寫不同的 prompt，品質不一致。有人離職了，prompt 就沒了。

Prismstack 把你的專業變成**可管理的系統**：

| | 散落的 prompt | Prismstack skill |
|---|---|---|
| **歸屬** | 在個人腦裡，人走就沒了 | 裝在團隊共享目錄，任何人都能用 |
| **品質** | 靠感覺（「看起來不錯」） | 有評分公式、有維度、有證據 |
| **AI 態度** | AI 什麼都說好 | 禁止空洞讚美 + 逼問 + 追問 |
| **流程** | 一口氣跑完 | 每個判斷點停下來問你 |
| **串接** | 各做各的 | 上一步的產出自動進下一步 |
| **改進** | 下次又從零開始 | 記得你說過什麼，越用越準 |
| **出錯** | 不知道哪裡壞 | 自動偵測 → 分類 → 修復 → 驗證 |

---

## 背後的方法論

Prismstack 有 5 份內建方法論，教 AI 怎麼幫你建好 skill：

| 方法論 | 解決什麼問題 |
|--------|-------------|
| **Skill Map 推導法** | 怎麼從你的工作流程推導出需要哪些 skill |
| **Skill 撰寫指南** | 怎麼寫出好的 skill：8 原則 + 7 結構 pattern + 10 個設計 how-to |
| **品質標準** | 怎麼判斷 skill 好不好：15 維度 + 校準基準 + 6 個常見陷阱 |
| **串接指南** | 怎麼讓 skill 之間自動傳遞資料 |
| **修復迴圈** | 發現問題怎麼修：偵測 → 分類 → 修 → 驗證 → 對比 |

10 個 how-to 覆蓋：評分公式設計、找 AI 盲點、修復迴圈設計、停頓點放置、反敷衍機制、逼問設計、中斷恢復、資料串接、輸入辨識、品質對等生成。

---

## 技術背景

Prismstack 的工程方法論源自 [gstack](https://github.com/garrytan/gstack)（Garry Tan 的 AI 工程工作流），經過完整消化重寫，適配「幫用戶建 skill」的情境。不需要安裝 gstack。

**核心差異：**
- gstack = 固定 25 個 Web/SaaS 工程 skill
- Prismstack = 10 個 builder skill，能為任何領域生成 10-30 個專屬 skill

**Prismstack 獨有的能力：**
- 雙模式（互動 + 自動，generator-evaluator 分離）
- 輸入敏感度（你給一句話或一份 spec，品質對等生成）
- 脈絡累積（記得你說過什麼，跨 session 越用越準）
- 工具打造（雙層：直接自動化 + 產出能自動化的 skill）

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
