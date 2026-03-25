# Changelog
## [0.5.0] - 2026-03-25

### Changed
- Replaced copied gstack knowledge base (3814 lines) with 4 digested methodology files (834 lines)
  - `skill-map-methodology.md` — how to derive a skill map from any domain
  - `skill-craft-guide.md` — how to write a good skill (8 principles + 7 patterns + 5 templates)
  - `quality-standards.md` — how to judge skill quality (15D + calibration + 6 review principles)
  - `system-wiring-guide.md` — how to connect skills (artifact flow + chaining + completion protocol)
- All 6 affected skills now reference digested methodology, not copied originals
- Prismstack is now self-contained: no external dependencies on gstack knowledge base

## [0.4.0] - 2026-03-25

### Changed
- `/skill-check` review mode upgraded from 9D to **15D** rubric (A1-A3 Entry, B4-B6 Flow, C7-C9 Knowledge, D10-D12 Structure, E13-E15 System)
- Scoring scale: 18 points → 30 points
- Added `review --all` batch mode (review all skills at once)
- Added cross-skill pattern analysis (dimension heatmap, layer health, grade distribution, top 5 systemic issues)
- Now aligned with gstack `skill-quality-rubric.md` gold standard

## [0.3.1] - 2026-03-25

### Fixed
- Added scoring criteria + benchmarks to all skills (C8+C9 quality fix)
- Added recovery/interrupt handling to all multi-phase skills (B6)
- Added artifact discovery to all skills (E13)
- Added per-project state conventions and config/memory (D12)
- New shared file: `state-conventions.md`
- New reference files: `success-criteria.md`, `build-benchmarks.md`, `generation-quality-checklist.md`, `workflow-benchmarks.md`

## [0.3.0] - 2026-03-25

### Added
- `/source-convert` — external source conversion (repo/prompt/video/article/ECC skill → skill content)
- `/tool-builder` — dual-layer tool building (hands-on + meta mode)
- `/domain-upgrade` — persistent stack improvement (listen/feedback/upgrade modes)
- `/workflow-edit` — artifact flow and skill connection management

### Changed
- `/prism-routing` — all 10 skills now active (was 3/10)

## [0.2.0] - 2026-03-25

### Added
- `/skill-check` — quality review meta-skill (design / review / pack modes)
- `/skill-gen` — single skill generation
- `/skill-edit` — surgical skill modifications

## [0.1.0] - 2026-03-25

### Added
- Project scaffold
- `/prism-routing` — builder routing skill
- `/domain-plan` — domain skill map planning
- `/domain-build` — auto-generate domain gstack repo
