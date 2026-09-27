---
name: skill-debugging
description: "Use for systematic debugging, failing tests, compilation errors, crashes, silent failures, and any unpredictable behavior where the root cause must be found."
---

# Systematic Debugging

Stop writing new code and adding features as soon as something breaks. The goal is to find the root cause, not treat the symptom.

## Strict rules

- Do not propose a fix until the symptom is reproduced or enough evidence is collected.
- Do not change code randomly: every action must test a specific hypothesis.
- Do not rerun a failed command without analyzing its output.
- Do not wait by time when you can wait for a specific state, file, log, process, or UI signal.
- If three hypotheses fail, stop and request new data.

## Investigation process

1. Classify the problem: crash, failing test, build failure, interface state bug, data corruption, parser failure, performance symptom, or silent failure.
2. Record expected and actual behavior.
3. Find the smallest reproducible scenario.
4. Collect evidence: stack trace, log, test output, diff, input data, environment state.
5. Trace the cause chain: trigger → input → boundary → transformation → state → async or timing point → failure location → first wrong value.
6. Form a hypothesis and the cheapest way to test it.
7. For non-trivial hypotheses, use the Claim/Evidence/Counterexample triad.
8. Confirm or reject the hypothesis with a fact.
9. After the fix, check the original scenario and the regression test.

## Defense in depth

After finding the cause, check why the system allowed the defect through:

- a type or invariant was missing;
- boundary validation was absent or too late;
- the error was swallowed;
- the test checked implementation, not behavior;
- the log lost context;
- there was no regression or prove-it test;
- there was no check at an external-input boundary;
- calling code received an invalid state without an explicit error state.

## Condition-based waiting

Prefer waiting for an observable condition over sleeping for a fixed time:

- process exits;
- file exists or changes;
- port responds;
- UI element appears;
- log line appears;
- remote job status changes.

If only a timeout is available, explain why no better signal exists.

## Evidence collection by symptom type

Collect evidence that matches the project's real environment:

- Crash/process exit: full stack trace, error cause, input data, environment, recent changes.
- Build/compiler failure: read the error from bottom to top, separate the primary error from build-tool wrapper errors.
- Test failure: check the specific test, expected/actual, fixture/setup, execution order, and recent changes.
- Interface state bug: record the visible state, user event, route/endpoint/handler, input data, and state after the action.
- Performance symptom: look for blocking operations, repeated work, N+1, resource leaks, unbounded loops, and heavy operations in the hot path.
- Data corruption: preserve source data, intermediate transformations, schema/version/config, and the first corruption point.
- Integration failure: check the contract at every boundary — request, response, serialization, auth/config, retry, and timeout.
- Silent failure: find where the error lost its cause, stack trace, signal to the caller, or recovery possibility.

## Good result

A bug is fixed only when it is clear why it happened, why the solution removes the actual cause, and which check prevents recurrence.

Do not add temporary logs to production code without necessity. If instrumentation is needed, it must test a specific hypothesis and be removed after confirmation.
