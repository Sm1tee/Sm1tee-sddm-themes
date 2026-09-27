---
name: writing-skills
description: "Use when creating, moving, or changing Claude Code skills so the skill has a clear trigger, correct YAML frontmatter, verifiable rules, and does not duplicate existing skills."
---

# Writing Skills

A skill is not documentation for its own sake. It must change agent behavior at the right moment.

## Before creating a skill

1. Check whether a skill with the same purpose already exists.
2. Define the exact trigger: when the skill should activate.
3. Define who will use it: the main agent, a subagent, or both.
4. Make sure the skill is not tied to a specific project without a reason.
5. Decide whether a separate skill is needed or an existing one should be strengthened.

## Frontmatter

Required fields:

- `name` — the real skill name that will be used in agent YAML.
- `description` — a short description with application conditions.

The name must be stable, readable, and must not conflict with existing skills.

## Skill body

A good skill contains:

- purpose;
- when to apply;
- when not to apply;
- workflow;
- prohibitions and antipatterns;
- good result criterion.

## Skill check

After changing a skill, check:

- frontmatter is valid;
- `name` matches what agents reference;
- the skill does not duplicate an existing one;
- there are no links to local temporary paths;
- there are no instructions that conflict with project rules;
- the skill is written so it can be applied without reading the source repository.
