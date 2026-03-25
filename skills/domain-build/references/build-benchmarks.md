# Build Output Quality Score

5 dimensions, 0-2 each, 10 points max.

| Dimension | 0 | 1 | 2 |
|-----------|---|---|---|
| **Scaffold Complete** | Missing README/CLAUDE.md/install.sh | Most files present | All required files present + correct |
| **Skill Quality** | Avg skill < 12/30 (Skeleton) | Avg 12-17 (Draft) | Avg 18+ (Usable) |
| **Artifact Wiring** | No discovery/save patterns | Some skills wired | All skills have discovery + save |
| **ECC Compat** | Missing required YAML fields | Most fields present | All skills pass ECC format check |
| **Validation** | validate-repo.sh fails | 3-4/5 pass | All 5 criteria pass |

---

## Expected Quality by Skill Category

| Category | Target Score | Expected Avg Quality |
|----------|-------------|---------------------|
| Generic chassis | 18-23/30 | Usable |
| Planning perspective | 15-20/30 | Draft-Usable |
| Domain-specific | 12-17/30 | Draft |
| Entry skills | 18-23/30 | Usable |
| Tool skills | 12-17/30 | Draft |

---

## Time Benchmarks

| Domain Size | Skills | Expected Build Time | Expected Quality |
|-------------|--------|-------------------|-----------------|
| Small (8-12) | 8-12 | 15-30 min | Avg 16/30 |
| Medium (13-20) | 13-20 | 30-60 min | Avg 15/30 |
| Large (21-30) | 21-30 | 60-120 min | Avg 14/30 |
