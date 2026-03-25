# Prismstack — Developer Handoff

## Project Overview

Prismstack is a 10-skill domain stack builder tool, installed as Claude Code skills. It takes gstack methodology and produces domain-specific skill packs. Skills are installed to `~/.claude/skills/prismstack/`.

## Directory Structure

```
prismstack/
  skills/       # Skill definition files (YAML frontmatter + Markdown body)
  bin/           # Executable scripts (install, helpers)
  docs/          # Documentation and reference materials
  test/          # Test scripts
```

## Installation

```bash
bash bin/install.sh
```

## Testing

```bash
bash test/install-test.sh
```

## Skill Format

Each skill file uses YAML frontmatter followed by a Markdown body:

```markdown
---
name: skill-name
version: 0.1.0
origin: prismstack
description: What this skill does
allowed-tools:
  - Bash
  - Read
  - Write
---

# Skill Title

Skill instructions in Markdown...
```

## Commit Style

Use conventional commits:

- `feat:` — new feature or skill
- `fix:` — bug fix
- `docs:` — documentation changes

## Language

- Skill content: 繁體中文
- Code and comments: English

## Reference Materials

gstack knowledge base is located at: `C:\ai_project\guardian\docs\tech\gstack\`
