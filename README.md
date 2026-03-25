# Prismstack — Domain Stack Builder

> 一束光（gstack 方法論）進去，分散成多色（domain skills）出來

Prismstack is a 10-skill builder tool for creating domain-specific gstack skill packs. It turns gstack methodology into targeted, installable Claude Code skill sets for any domain.

## Quick Start

```bash
# 1. Clone
git clone <repo-url> prismstack
cd prismstack

# 2. Install skills to ~/.claude/skills/prismstack/
bash bin/install.sh

# 3. Use in Claude Code
/prism-routing
```

## Skills

| # | Skill | Type | Description | Status |
|---|-------|------|-------------|--------|
| 1 | `/prism-routing` | Control | Builder routing — directs workflow to the right skill | ✅ |
| 2 | `/domain-plan` | Bridge | Domain skill map planning — designs the skill set for a target domain | ✅ |
| 3 | `/domain-build` | Production | Auto-generate domain gstack repo — scaffolds and populates the output | ✅ |
| 4 | `/skill-check` | Review | Validate skill quality, format, and completeness | 🚧 |
| 5 | `/skill-gen` | Production | Generate individual skill files from specs | 🚧 |
| 6 | `/skill-edit` | Bridge | Edit and refine existing skill content | 🚧 |
| 7 | `/source-convert` | Bridge | Convert reference materials into skill-ready format | 🚧 |
| 8 | `/tool-builder` | Production | Build custom tool definitions for skills | 🚧 |
| 9 | `/domain-upgrade` | Bridge | Upgrade existing domain packs to newer versions | 🚧 |
| 10 | `/workflow-edit` | Control | Edit and customize the builder workflow | 🚧 |

**Legend:** ✅ Wave 1 (current) | 🚧 Wave 2-3 (planned)

## How It Works

Prismstack follows a 5-step cycle:

1. **Plan** — `/domain-plan` maps out the skills needed for a target domain
2. **Build** — `/domain-build` scaffolds the domain gstack repo and generates skills
3. **Upgrade** — `/domain-upgrade` evolves the pack as requirements change
4. **Test** — `/skill-check` validates quality and completeness
5. **Iterate** — Refine with `/skill-edit`, `/skill-gen`, and other bridge/production skills

`/prism-routing` orchestrates the cycle, directing you to the right skill at each step.

## Relationship to gstack and ECC

- **gstack** is the methodology — a structured approach to building Claude Code skill packs
- **ECC** (Empowered Claude Code) is the runtime environment where skills execute
- **Prismstack** is the builder tool — it uses gstack principles to produce new domain-specific skill packs

Prismstack reads gstack methodology as input and outputs ready-to-install domain skill repositories.

## License

MIT — see [LICENSE](LICENSE).
