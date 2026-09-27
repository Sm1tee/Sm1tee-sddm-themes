---
name: receiving-code-review
description: "Use when receiving review comments, to distinguish blockers from suggestions, verify disputed claims, and fix only proven problems."
---

# Receiving Code Review

A review is technical input, not an order. It must be analyzed strictly.

## Processing flow

1. Split comments into blockers, important risks, and suggestions.
2. For each blocker, verify the evidence: file, line, scenario, risk.
3. If the comment is correct, fix the root cause, not the symptom.
4. If the comment is debatable, check the code and respond with technical reasoning.
5. If the comment is outside the scope, record that and do not expand the task without approval.
6. Classify each response as verified-and-fixed, verified-not-applicable, needs clarification, or follow-up outside scope.
7. After fixes, rerun the relevant checks.

## Forbidden

- automatically agreeing with review comments out of politeness;
- replying only “good catch”, “fixed”, or “I agree” without verifying the code;
- arguing without checking the code;
- fixing only the location mentioned in the comment when the cause is deeper;
- adding hacks just to “close” a comment;
- ignoring a blocker because the build passes;
- mixing useful comments with subjective style preferences.

## Good result

- blockers are resolved;
- disputed points have evidence-based answers;
- suggestions are either applied or intentionally postponed;
- checks after the changes confirm the state;
- the final solution does not degrade the architecture.
