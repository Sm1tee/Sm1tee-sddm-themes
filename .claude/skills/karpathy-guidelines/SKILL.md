---
name: karpathy-guidelines
description: "Use always when writing, changing, reviewing, refactoring, planning, or debugging code to avoid guesses, unnecessary code, imprecise edits, and unverified success claims."
---

# Karpathy Guidelines

This skill reduces typical AI development mistakes: overcomplication, hidden assumptions, accidental neighboring edits, premature abstractions, and success claims without verification.

The skill is universal: apply it in any project, language, and technology stack. Stack-specific details, when needed, come from specialized skills, not from this skill.

## 1. Think before code

Before implementation:

- explicitly name assumptions if they affect the solution;
- if the task can be interpreted in different ways, do not choose silently;
- if data is insufficient, stop and ask a precise question;
- if there is a simpler solution, propose it;
- if the request leads to unnecessary complexity, push back gently and explain the risk.

Do not hide uncertainty behind a confident tone. Do not turn a guess into a fact.

## 2. Simplicity first

Write the minimum code that solves the current task.

Forbidden:

- adding functionality beyond the request;
- creating an abstraction for a single use;
- adding configurability “for the future”;
- building a universal mechanism where one direct path is needed;
- expanding a public API without necessity;
- adding a fallback that hides an error instead of an explicit state or correct recovery.

If the solution grows, check whether the same result can be achieved with fewer types, branches, states, and files without losing readability.

## 3. Targeted changes

Every changed line must have a direct connection to the user's task.

When changing existing code:

- touch only what is needed for the current task;
- do not format neighboring code without a reason;
- do not rewrite a working area only because you would implement it differently;
- do not delete old unrelated code without agreement;
- delete only imports, variables, functions, and files that became unnecessary because of your change;
- if you notice another defect outside scope, report it separately instead of mixing it into the current change.

Targeted changes do not mean tolerating bad architecture inside the changed area. If the current task requires redesign to solve correctly, record this in a plan first and agree on the direction.

## 4. Verifiable goal

Turn every task into a verifiable result.

Examples:

- “fix a bug” → reproduce the defect, prove the cause, add or run a check, show that the scenario no longer breaks;
- “add validation” → define rules, check valid and invalid input;
- “refactor” → preserve behavior with tests or another relevant check;
- “update UI” → check visible state and user scenario.

For multi-step work, every step must have its own verification method.

## 5. Error-handling boundaries

Do not add error handling for scenarios proven impossible inside the trusted part of the system.

But always protect system boundaries:

- user input;
- files and external formats;
- network and external APIs;
- DB and migrations;
- system time, randomness, and environment;
- lifecycle, async-task cancellation, and concurrent access;
- data from other applications, CLI, or external processes.

At boundaries, an error must be visible: explicit state, exception with cause, valid error result, or clear recovery. Do not turn an error into an empty list, `null`, or silent fallback without a reason.

## 6. Good result criterion

Good work looks like this:

- the task is understood without hidden assumptions;
- the solution is simpler than alternatives with the same quality;
- the diff is minimal and connected to the request;
- there are no new abstractions without real benefit;
- errors are not hidden;
- the result is verified with fresh evidence;
- remaining risks are named honestly.

## Antipatterns

- “I'll improve neighboring code too”;
- “I'll make it flexible in case we need it later”;
- “It looks like it should work”;
- “Tests are not needed, the change is small”;
- “I'll add a general manager/service/factory for one case”;
- “I'll catch all exceptions and return a default”;
- “The user won't notice the extra change”.
