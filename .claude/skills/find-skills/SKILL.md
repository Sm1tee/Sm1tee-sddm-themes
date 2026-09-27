---
name: find-skills
description: "Use when the user is looking for new skills, asks how to extend an agent's capabilities, asks to find a skill for a task, or is interested in installing skills."
---

# Find Skills

This skill helps search, evaluate, and install external skills without blindly trusting a catalog, popularity, or someone else's description.

## When to use

Use this skill when the user:

- asks to find a skill for a specific task;
- asks whether an agent's capabilities can be extended;
- is interested in installing, updating, or comparing skills;
- wants to know whether a ready-made workflow, template, or domain skill exists;
- often repeats the same kind of task that could be turned into a skill.

## Search sources

Check available sources based on the actual environment:

1. Local project skills: `.claude/skills/*/SKILL.md`.
2. Local packs/toolkit, if the user provided a path.
3. External skill catalogs, if available and the user is not against external search.
4. Skill CLI tools, if they are installed in the current environment.

Do not treat an external catalog as a required source of truth. If network, Node.js, CLI, or the needed catalog is unavailable, say so directly and offer a local option.

## How to search

1. Clarify the task: domain, expected behavior, stack, constraints, and frequency of use.
2. Check local skills and project-specific rules first.
3. If there is no local skill, search for an external skill using specific keywords.
4. For several candidates, compare purpose, freshness, source, usage examples, and risks.
5. Do not recommend a skill only because it is popular or has a nice description.

## Quality check before recommendation

Before recommending, check:

- frontmatter: `name`, `description`, clear trigger;
- content: specific rules instead of generic advice;
- compatibility: whether the skill conflicts with project and user rules;
- scope: whether it brings an unnecessary stack or someone else's methodology;
- security: whether it suggests disabling checks, publishing data, or running dangerous commands;
- maintainability: whether the source, freshness, and update method are clear.

If quality is not proven, mark the candidate as questionable and do not install it without user confirmation.

## Installation

Before installing an external skill:

- show the user exactly what will be added;
- check whether installation would overwrite existing files;
- do not use global installation without explicit consent;
- do not run commands that download or execute external code without confirmation.

If the user wants to create their own skill, use `writing-skills` and shape it around a concrete repeatable scenario.

## If nothing is found

If there is no suitable skill:

1. Say that no reliable ready-made skill was found.
2. Offer to handle the task with normal capabilities.
3. If the task is repeatable, suggest creating a local skill.
4. Do not invent nonexistent skills or present guesses as search results.
