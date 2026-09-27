---
name: finishing-a-development-branch
description: "Use only when explicitly working with a git branch, PR, or finishing a set of changes, to check state, choose an integration path, and avoid losing someone else's work."
---

# Finishing a Development Branch

This skill is for carefully finishing a branch or a set of changes. It does not start git operations by itself: git actions require an explicit user request.

## Before finishing

1. Check the working state: modified, staged, and untracked files.
2. Make sure there are no secrets, temporary files, or accidental junk.
3. Compare the changes against the original task.
4. Run relevant checks or honestly state what was not run.
5. Check whether the user needs a PR, commit, local preservation, or only a report.

## Do not do without explicit permission

- commit;
- push;
- force push;
- rebase/amend;
- delete branches;
- reset/clean/restore;
- close or create a PR;
- publish data to external services.

## Finishing options

- leave changes locally and provide a report;
- create a commit at the user's request;
- prepare a PR at the user's request;
- stop because of blockers;
- postpone part of the work if it is out of scope.

## Final report

Report only the factual state: what changed, what was verified, what was not verified, which risks remain, and which action is required from the user.
