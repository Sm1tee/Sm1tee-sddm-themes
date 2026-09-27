---
name: skill-documentation
description: "Use when writing and updating technical documentation, ADRs, README files, comments, plans, skills, and records of architectural decision reasons."
---

# Documentation and Comments

Code shows *what* was done and *how*. Documentation must answer *why*.

## Architecture decisions (ADR)

Record decisions, not only code. If you make a decision that materially changes how the system works, such as choosing a new library or changing the architectural approach, record it.

ADR structure (Architecture Decision Record):
1. **Context:** What problem appeared and why a decision was needed.
2. **Considered options:** Which alternatives existed.
3. **Decision:** What was chosen and why.
4. **Tradeoffs:** Which consequences or constraints must be accepted.

## Code comments

- **Self-documenting code:** Code should be understandable without comments because of good variable and function names; see `naming`.
- **When to write a comment:** Write comments only where the logic is non-obvious, such as tricky math, intentionally violating standards as a workaround for a platform/framework/external-tool bug, or depending on hidden external factors.
- **What to avoid:** Never write comments that duplicate what is already visible from the code, such as `// increment counter by 1`.

## Interface descriptions

If you write a public interface that will be used by other components or developers, add a short description in the current language's documentation format. Describe purpose, possible errors, and expected input only when this is not obvious from the name and signature.

## Plans and skills as behavior documentation

- A plan must explain why the change is needed, which files are affected, which work order was chosen, and how the result is verified.
- A skill must have a precise trigger, clear name, valid YAML frontmatter, and verifiable behavior rules.
- Do not create documentation “for the future”. Document only decisions, process, or constraints that the next contributor actually needs.
- Do not leave `TODO`, `TBD`, contradictions, or vague wording in plans, ADRs, and skills.
- If a document is outdated relative to code, update it or explicitly mark the gap; do not add a new document on top of old junk.
