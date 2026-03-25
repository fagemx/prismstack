# Skill Generation Quality Checklist

Score each generated skill (0-2, 8 points max):

| Check | 0 | 1 | 2 |
|-------|---|---|---|
| **Trigger Precision** | Vague "use for X" | Has trigger + anti-trigger | Trigger + anti-trigger + adjacent skills + trigger phrases |
| **Role Lock** | Generic "you are a helper" | Role stated but broad | One-sentence sharp persona that changes agent behavior |
| **Operational Gotchas** | None or generic | 1-2 relevant | 3+ Claude-specific operational errors with redirect patterns |
| **Workflow Wiring** | Isolated (no upstream/downstream) | Partial (missing one direction) | Full (upstream discovery + downstream recommendation + artifact save) |

**Pass threshold:** 5/8 minimum. Below 5 → revise before committing.

**Common generation failures:**
- Score 2/8: Generic template with domain words swapped in → fails substitution test
- Score 4/8: Good structure but no gotchas and isolated from workflow
- Score 6/8: Good skill, just needs polish on gotchas or wiring
- Score 8/8: Rare on first generation — usually requires expert upgrade
