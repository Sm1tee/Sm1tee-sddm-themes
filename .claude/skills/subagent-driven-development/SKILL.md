---
name: subagent-driven-development
description: "Use when executing an approved plan through specialized subagents, when tasks can be delegated by layer or work type without losing quality."
---

# Subagent-Driven Development

The main agent manages the process, while specialized agents perform work within their responsibility boundaries.

## Why

Subagents receive clean context and a precise task. This reduces noise, lowers the risk of accidental changes, and lets the main agent remain the quality coordinator.

## Delegation rules

- Every subagent receives a self-contained prompt: goal, context, specific files, boundaries, expected result, and report format.
- Do not delegate “figure it out and do everything”. Delegate a specific layer or verifiable piece of work.
- Do not make a subagent take architectural decisions if they should already be decided by the plan.
- Do not launch subagents for tasks that depend on unfinished changes from other agents.
- After a subagent finishes, check the actual changes, not only its report.
- Do not assign models to subagents unless the user explicitly requests it.
- Do not create a mandatory implementer → reviewer → reviewer loop for every task.

## Subagent prompt template

A good assignment names:

- goal: what outcome is required;
- context: why the work exists and what has already been decided;
- allowed files or areas;
- out of scope;
- constraints and project rules;
- expected deliverable;
- expected verification;
- report format.

## Two-stage verification

1. Task fit check: whether exactly the assigned work was done.
2. Quality check: correctness, readability, architecture, security, performance, tests.

If any stage fails, return the task to the specialized implementer or rebuild the plan.

## Plan and spec review checklist

Before delegating, check:

- ambiguous task wording;
- missing files or affected areas;
- missing test or verification path;
- conflicting requirements;
- impossible sequencing;
- hidden scope creep;
- responsibility crossing between agents.

## Subagent statuses

- `DONE` — proceed to verification.
- `DONE_WITH_CONCERNS` — read the concerns first, then decide.
- `NEEDS_CONTEXT` — provide the missing context and rerun the task.
- `BLOCKED` — do not repeat the same prompt; change the plan, context, or implementer.

## When to parallelize

Parallel launch is allowed only if tasks are independent: different files, different layers, no shared state, and no dependency of one agent's result on another.

## Antipatterns

- trusting the report without checking the diff/files;
- launching many agents on the same area;
- assigning an agent to someone else's layer;
- assigning review fixes without an exact list of problems;
- using a subagent as a way for the main agent to avoid understanding the task.
