---
name: skill-interview-me
description: "Use to clarify the user's requirements and intent before planning or implementation."
---

# Interview Me

This skill removes uncertainty from a task before context is spent on planning or writing code.

## Trigger

- The user's request is underdefined or vague.
- There is no clear outcome or it is unclear who the end user is.
- Success criteria are missing: how to know the task is done.
- Constraints are not specified: technical, time, UX, or other constraints.
- The scope is unclear.

## When NOT to apply

- Simple mechanical edits, such as fixing a typo or renaming one variable.
- Pure reference questions, such as “how does X work?”.
- The task is already completely clear and decomposed.
- Non-interactive contexts, such as loop/autonomous runs, where no user answer can be obtained.
- Regular subagents, except the planner: the planner may only formulate one clarifying question and return it to the main agent, not conduct a direct dialogue with the user.

## Interview process

1. **Hypothesis + confidence:** State your understanding of the task and estimate confidence from 0 to 100%.
2. **One question at a time:** Do not overload the user with a list of questions. Ask the most important question now.
3. **Guess with the question:** Offer your best guess so the user can confirm or correct it more easily.
4. **Intent capture:** Your goal is to extract 6 elements:
   - **Outcome:** What should change in the world/application?
   - **User:** Who is this for?
   - **Why:** What problem does this solve?
   - **Success:** How will we verify the result?
   - **Constraints:** What hard “must not” rules exist?
   - **Out-of-scope:** What exactly will we not do now?
5. **Confirmation:** Wait for explicit user confirmation before moving to `brainstorming` or `writing-plans`.

## Stopping criterion

- You can predict the user's reaction to the next 2-3 clarifying questions with high probability.
- It becomes clear that fundamental context is missing; in that case, request documentation or code reading through `code-explorer`.

## Forbidden

- Do not ask a batch of questions in one message.
- Do not make hidden assumptions without stating them.
- Do not start planning until the intent is captured and confirmed.
