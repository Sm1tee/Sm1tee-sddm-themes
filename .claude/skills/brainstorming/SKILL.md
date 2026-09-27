---
name: brainstorming
description: "Use before creating new functionality, changing behavior, making UX/UI decisions, or making architectural decisions when intent, constraints, options, and success criteria must be clarified before implementation."
---

# Brainstorming

The goal of this skill is to turn a raw idea into a clear solution design before code.

If the user's intent is unclear, underdefined, or questionable, use `skill-interview-me` first. Brainstorming is responsible for exploring solution options AFTER the intent is recorded and confirmed.

## Hard rule

Do not move to implementation until it is clear:

- which problem is being solved;
- who will use the result and how;
- which constraints matter;
- which scenarios count as successful;
- which options were considered;
- which option was chosen and why.

If the task is simple, the design may be short, but hidden assumptions still must be found.

## Process

1. Study the current project context: existing files, patterns, constraints, and similar solutions.
2. If data is insufficient, ask one precise question at a time.
3. If there are several reasonable paths, propose 2-3 options with the main trade-off.
4. Give a recommendation and explain why it is better for the current task.
5. Record the design as verifiable decisions: boundaries, data, states, errors, tests.
6. Do not start implementation before the direction is approved if the change affects behavior, architecture, or multiple files.

## Expected result

- brief task description;
- chosen approach;
- change boundaries;
- what is out of scope;
- risks and checks;
- next skill or agent: usually `writing-plans` or `task-implementation-planner`.

## Antipatterns

- treating the task as “too simple” and writing code immediately;
- proposing a solution without reading the project's current state;
- asking many questions in one message;
- discussing abstract options without a recommendation;
- adding functionality the user did not request;
- turning brainstorming into a long document without a practical decision.
