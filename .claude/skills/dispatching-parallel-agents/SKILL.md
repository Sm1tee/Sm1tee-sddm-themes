---
name: dispatching-parallel-agents
description: "Use when there are two or more independent tasks that can safely run in parallel without shared mutable state, conflicting files, or sequential dependencies."
---

# Dispatching Parallel Agents

Parallel agents speed up work only when the tasks are truly independent.

## Safe to run in parallel

- read-only investigations of different project areas;
- independent checks: review, audit, test strategy;
- different layers without overlapping files;
- collecting diagnostic data from different sources;
- comparing multiple approaches during planning.

## Do not run in parallel

- multiple writing agents in the same file;
- tasks where one result is needed by another task;
- migrations and data-model edits without shared coordination;
- fixing the same bug with different agents;
- git/worktree/commit operations without explicit control by the main agent.

## A prompt for a parallel agent must include

- the exact responsibility area;
- which files may be read or changed;
- what must not be touched;
- the expected response format;
- an output-size limit;
- the completion criterion.

## After completion

1. Compare the agents' results.
2. Find conflicts and overlaps.
3. Verify real files if an agent changed anything.
4. Synthesize the final result yourself; do not delegate the decision to one of the agents.
