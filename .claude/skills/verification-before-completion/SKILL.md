---
name: verification-before-completion
description: "Use before claiming that work is done, a bug is fixed, the build passes, tests are green, or requirements are satisfied. Requires fresh evidence, not assumptions."
---

# Verification Before Completion

Main rule: evidence before claiming completion.

## Hard rule

Do not say that work is done unless a fresh check confirms it.

## Verification gate

Before any success claim:

1. Define which check proves the claim.
2. Run the full relevant check or honestly state why it is unavailable.
3. Read the result: exit code, number of failures, error lines, actual state.
4. Compare the result with the claim.
5. If the check does not confirm success, report the factual status.
6. If it confirms success, state exactly what confirmed it.

## What does not count as proof

- “should work”, “probably”, or “seems fine”;
- an old successful run;
- a partial check instead of the full relevant one;
- a subagent report without checking actual files or changes;
- absence of errors in the visible log fragment;
- linter instead of build;
- build instead of checking the user scenario;
- build passed but the changed behavior was not exercised;
- a test that does not reproduce the original bug;
- a test that passed but was never observed failing for the bug.

## For different claims

- “tests pass” — requires a fresh run of the relevant test command.
- “build passes” — requires a fresh run of the build command.
- “bug is fixed” — requires the scenario that reproduced the bug before and a check after the fix.
- “UI works” — requires a manual or E2E scenario check if UI changed.
- “requirements are satisfied” — requires a requirement checklist and verification of each item.

## If verification is impossible

Do not disguise it as success. State exactly what changed, what was verified, what was not verified, and why.

## Final report discipline

- Claim only what fresh evidence proves.
- Name the check that confirmed the claim.
- Separate completed work from unverified work.
- If verification is partial, say so directly.
