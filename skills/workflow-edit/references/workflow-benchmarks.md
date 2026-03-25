# Workflow Health Benchmarks

## Healthy Workflow Indicators
| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Orphan artifacts | 0 | 1-2 | 3+ |
| Skills with no downstream | 0-1 (terminal skills OK) | 2-3 | 4+ |
| Skills with no upstream | 1-2 (entry skills OK) | 3-4 | 5+ |
| Longest chain | 4-8 skills | 9-12 | 13+ (too complex) |
| Circular dependencies | 0 | - | Any (always critical) |
| Bridge skill ratio | 15-25% of total | 10-15% or 25-35% | <10% or >35% |

## Workflow Complexity Score (0-10)
Simple formula: 10 - (orphans × 2) - (no-downstream × 1) - (cycles × 5)
- 8-10: Clean workflow
- 5-7: Minor issues
- 0-4: Needs restructuring

## Common Workflow Patterns
| Pattern | When Healthy | When Problematic |
|---------|-------------|-----------------|
| Linear chain (A→B→C) | Small domains, clear sequence | >8 skills in chain = too rigid |
| Diamond (A→B,C→D) | Parallel review paths | If B and C never merge back |
| Fan-out (A→B,C,D,E) | One-to-many distribution | If no fan-in to collect results |
| Loop (A→B→C→A) | Iterative refinement | If no exit condition |
