---
name: skill-code-quality
description: "Use for refactoring, code cleanliness checks, code review, pull request analysis, technical debt discovery, and quality assessment of existing components."
---

# Code Quality and Refactoring

This skill is responsible for local code quality: simplicity, readability, minimal scope, absence of unnecessary abstractions, and technical debt control.

## 1. Local code quality

When analyzing changes, check:

1. **Correctness:** whether the code performs the stated task and accounts for real edge cases.
2. **Readability:** whether names, function structure, branches, and data flow are clear.
3. **Responsibility:** whether the code mixes independent reasons to change.
4. **Simplicity:** whether there is unnecessary generality, configurability, or layers with no current benefit.
5. **Maintenance cost:** whether non-obvious dependencies, hidden states, duplication, or fragile contracts appeared.

## 2. Brief change description

When preparing a change, PR, or commit description, record only useful information:

- **Summary:** what changed and why.
- **Impact:** which contracts, scenarios, or modules are affected.
- **Risks:** where failures, regressions, data loss, or performance degradation are possible.
- **Testing:** what proves the behavior remains correct.

## 3. Clean code principles

- Leave cleaner only the area that is actually touched by the task.
- Avoid logic duplication, but do not create an abstraction before it simplifies the current code.
- Do not write code or extensibility “for the future”.
- Reduce nesting with early returns, separated conditions, and explicit states.
- Delete dead code only after understanding why it exists and who consumes it.

## 4. Working with technical debt

- Do not mask architectural problems with quick fixes or hacks.
- Anti-rationalization / red flags: do not accept excuses like “we will clean it later”, “tests later”, or “leave the old one for now”. Code must be clean here and now.
- Delete old code only after understanding why it exists and all of its consumers.
- If refactoring touches more than 3 files or changes a component's public contract/API, agree on the change with the developer first by providing a plan.
- When deprecated code is found, suggest modern alternatives that fit the project stack.

## 5. Skill boundaries

- For architectural boundaries, use `architecture`.
- For security and performance, use `security`.
- For test strategy, use `testing`.
- For requesting independent review, use `requesting-code-review`.
- For processing review comments, use `receiving-code-review`.

This skill does not replace specialized checks. It is responsible for local simplicity, readability, and maintainability of code.
