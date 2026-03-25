# Completion Protocol

Every Prismstack skill ends with one of these statuses:

## STATUS: DONE
All steps completed. Evidence provided. Artifacts saved.
- Include: summary of what was done, artifact locations, recommended next skill

## STATUS: DONE_WITH_CONCERNS
Completed, but user should know about these issues.
- Include: what was done, concerns list, whether concerns are blocking

## STATUS: BLOCKED
Cannot continue.
- Include: ESCALATION_REASON (what's blocking), SUGGESTION (what to try)

## STATUS: NEEDS_CONTEXT
Missing information to proceed.
- Include: what information is needed, why it's needed, what to do with it
