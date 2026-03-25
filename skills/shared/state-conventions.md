# Prismstack State Conventions

## State Directory
每個 domain project 的 Prismstack 狀態存在：
`~/.gstack/projects/{slug}/.prismstack/`

## State Files
| File | Written By | Read By | Purpose |
|------|-----------|---------|---------|
| `domain-config.json` | /domain-plan | All skills | Domain name, lifecycle, viewer roles |
| `skill-map.json` | /domain-plan | /domain-build, /skill-gen, /workflow-edit | Structured skill map (machine-readable) |
| `build-progress.md` | /domain-build | /domain-build (resume) | Build status per skill |
| `check-results.json` | /skill-check | /domain-upgrade, /skill-edit | Last review scores per skill |
| `edit-log.jsonl` | /skill-edit | /domain-upgrade | Edit history (append-only) |
| `convert-log.jsonl` | /source-convert | /domain-upgrade | Conversion history |
| `upgrade-log.jsonl` | /domain-upgrade | /domain-upgrade (resume) | Upgrade dispatch history |
| `workflow-snapshot.md` | /workflow-edit | /workflow-edit (resume) | Last known workflow graph |
| `discovery-notes.md` | /tool-builder | /tool-builder (resume) | Exploration discoveries |

## Convention Rules
1. State dir created on first skill run (mkdir -p)
2. JSON for machine-readable data, .md for human-readable, .jsonl for append-only logs
3. Skills read state but never delete other skills' state files
4. State is per-project (not global) — different domains have different state
5. If state file doesn't exist, skill runs normally (first time)

## domain-config.json Schema
```json
{
  "domain": "行銷創意生產",
  "created": "2026-03-25",
  "lifecycle_stages": ["策略", "發想", "規格", "生產", "驗證", "投放"],
  "skill_count": 31,
  "last_build": "2026-03-25T14:30:00Z",
  "last_check": null,
  "last_upgrade": null
}
```
