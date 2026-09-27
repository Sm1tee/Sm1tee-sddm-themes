---
name: requesting-code-review
description: "Use after implementing a meaningful change or before finishing a task, to request an independent read-only review of requirement fit and code quality."
---

# Requesting Code Review

A review is not a formality. It is used to find real defects before handing the result to the user.

## When to apply

- after any production-code changes;
- after changes to architecture, build, navigation, database, or security;
- after fixing a bug, especially when there was a prove-it test;
- before the final report for a non-trivial task;
- if a subagent changed files and the main agent must verify the result.

## What to give the reviewer

- the original task goal;
- the list of changed files;
- important constraints and decisions made;
- which checks have already been run;
- which areas are especially risky;
- what must not be evaluated outside the scope.

## Two review levels

1. Task fit: whether the requested work was implemented.
2. Quality: correctness, edge cases, regressions, readability, architecture, security, performance, maintainability, tests.

## YAGNI and production-quality check

Ask the reviewer to check that the change:

- solves the requested problem without speculative abstractions;
- does not add “professional-looking” features outside the task;
- is not demo-only behavior disguised as production work;
- does not over-engineer a simple requirement.

## Reviewing non-trivial decisions

For disputed or architecturally significant changes:
- Ask the reviewer to actively look for what is broken or could break, not merely confirm your decision.
- Require every comment to be classified:
  - **Blocker:** Must be fixed (bug, architecture violation, security risk).
  - **Warning:** Should be fixed if time/budget allows, or recorded as technical debt.
  - **Optional / Nit:** Taste preferences or minor improvements.

## Forbidden

- requesting review without context;
- requesting review of “the whole project” when only a small area changed;
- accepting a subagent report without checking the actual changes;
- closing the task while blocker comments remain;
- turning review into taste-based cleanup with no behavior risk.
