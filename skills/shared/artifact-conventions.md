# Artifact Naming & Storage Conventions

## Storage Path
All artifacts: `~/.gstack/projects/{slug}/`
- {slug} = repo basename (from `bin/prism-slug.sh` or `basename $(git remote get-url origin)`)

## Filename Pattern
`{user}-{branch}-{type}-{datetime}.md`
- user: git config user.name or $USER
- branch: current git branch
- type: artifact type (skill-map, workflow-graph, review, etc.)
- datetime: YYYY-MM-DD-HHmm

Example: `nox-main-skill-map-2026-03-25-1430.md`

## Supersedes Chain
When a new artifact replaces an old one, include at the top:
```
Supersedes: nox-main-skill-map-2026-03-24-0900.md
```

## Discovery Pattern (Bash)
Skills search for upstream artifacts at startup:
```bash
_SLUG=$(bash "$(dirname "$0")/../bin/prism-slug.sh" 2>/dev/null || basename "$(pwd)")
_PROJECTS_DIR="${HOME}/.gstack/projects/${_SLUG}"
if [ -d "$_PROJECTS_DIR" ]; then
  _LATEST_ARTIFACT=$(ls -t "$_PROJECTS_DIR"/*-{type}-*.md 2>/dev/null | head -1)
fi
```
