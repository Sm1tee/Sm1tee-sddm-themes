---
name: writing-plans
description: "Use before multi-step implementation, complex refactoring, architectural change, or bug fix when an executable plan with files, work order, risks, and checks is needed."
---

# Writing Plans

A plan is not bureaucracy. It lets an implementer do the work without guesses and without leaving the task boundaries.

## Good plan criteria

A plan must be:

- specific: files, layers, and expected changes are named;
- verifiable: it is clear how to prove success;
- ordered: each step can be executed without knowing future steps;
- bounded: what is outside the task is stated explicitly;
- safe: data, build, UX, performance, and security risks are noted;
- delegable: it is clear which agent should receive each block.

## Required structure

1. Intent: Why this is being done, what problem is being solved, and for whom. If intent is unclear, return to `skill-interview-me`.
2. Success criteria: How we will know the task is complete; measurable success.
3. Out-of-scope: What exactly we will NOT do as part of this task.
4. Current state: which existing patterns and files must be considered.
5. Solution: chosen approach without listing every rejected idea.
6. Responsibility boundaries: which layers, modules, components, teams, or external systems are affected in the current architecture.
7. Implementation order: small steps with expected results.
8. Test strategy: which checks are needed and at which level.
9. Verification: commands, manual scenarios, or E2E checks.
10. Risks: what may break and where caution is needed.

## Rules

- Do not plan abstractions “for the future”.
- Do not hide unknown data: if a user decision is needed, stop and ask.
- Do not mix independent tasks into one step.
- Do not give the implementer vague wording such as “improve” or “clean up”.
- Do not leave placeholders such as “TBD”, “handle edge cases”, “update as needed”, or “add tests later”.
- Each implementation step must name files or areas, expected result, and verification signal.
- Keep steps small enough to review independently when possible.
- Do not require design documents, commits, or branch workflow unless the task explicitly needs them.
- If the plan requires more than three files, always record the order and responsible agents.

## Moving to execution

After the plan is approved, use `executing-plans` or `subagent-driven-development` depending on whether the work is performed in one stream or through several independent agents.
