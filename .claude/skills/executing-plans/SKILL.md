---
name: executing-plans
description: "Use when executing an already approved plan, to follow steps, avoid scope expansion, record blockers, and verify the result after each significant stage."
---

# Executing Plans

This skill keeps execution inside the approved plan.

## Core principle

Treat the plan as a contract. Do not add new goals, change the architectural direction, or fix neighboring code without an explicit reason.

## Process

1. Read the full plan.
2. Break the work into verifiable tasks.
3. Start with the step that unlocks the others.
4. After each significant step, verify the factual result.
5. Check that the step has no placeholders, stubs, partial wiring, skipped checks, or mock implementations unless the approved plan explicitly allows them.
6. If you find a defect in the plan, stop and return the problem to the coordinator.
7. If the task goes outside the plan, do not expand scope yourself.
8. Before claiming completion, use `verification-before-completion`.

## Result statuses

- `DONE` — the step is completed and verified.
- `DONE_WITH_CONCERNS` — the step is completed, but there is a risk or concern.
- `NEEDS_CONTEXT` — there is not enough data for correct execution.
- `BLOCKED` — progress is impossible without resolving an external problem.

## Forbidden

- silently changing the plan;
- doing neighboring improvements “while here”;
- hiding partial execution under a done status;
- leaving TODOs, skipped tests, fake implementations, or partial wiring as if complete;
- relying on old checks;
- continuing after the third failed attempt to fix the same problem.

## Step completion checklist

- The assigned step is finished, not merely started.
- No unrelated files or goals were added.
- The relevant evidence was collected.
- Blockers and concerns were reported immediately.
