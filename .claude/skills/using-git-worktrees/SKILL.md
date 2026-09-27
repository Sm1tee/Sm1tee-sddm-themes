---
name: using-git-worktrees
description: "Use only when the user explicitly requests a worktree or when project rules require workspace isolation for an independent task."
---

# Using Git Worktrees

A worktree is useful for isolation, but it must not be enabled automatically.

## When to use

- the user explicitly said to work in a worktree;
- an experimental branch must be isolated from current unfinished changes;
- parallel work may conflict with the current working directory;
- project instructions require a worktree.

## When not to use

- a normal edit in the current working directory;
- a simple read-only task;
- the project is not a git repository;
- the IDE, build tooling, or local environment is tied to the current path;
- the user only asked to create a branch, not a worktree.

## Safety rules

- Before creating one, check that this is a git repository.
- Do not delete a worktree without explicit confirmation if it contains changes.
- Do not use a worktree as a way to bypass conflicts or unclear state.
- After finishing, clearly report the worktree path and change status.

## Agent integration

The main agent decides about worktrees. Subagents must not create or delete worktrees on their own.
