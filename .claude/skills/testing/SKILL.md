---
name: testing
description: "Use when writing and analyzing unit, integration, UI, E2E, regression, property-based, and prove-it tests in any stack; helps choose the test level and verify behavior without fragile implementation-detail checks."
---

# Testing

A test must protect behavior, not create an illusion of coverage.

## General principles

- Test observable behavior: input, action, result, error, state, or side effect.
- Do not test private implementation details without necessity.
- Every test must be independent, repeatable, and self-checking.
- If a test passes immediately for a known bug, it does not prove the bug.
- Do not add tests for coverage percentage. Every test must protect a meaningful risk.

## Choosing the test level

Choose the cheapest level that truly proves the behavior:

- **Unit** — pure logic, functions, validators, formatters, domain/application services.
- **Integration** — interaction between several components, databases, files, network, queues, adapters.
- **Component/UI** — state and interaction of an interface component without a full scenario.
- **E2E/Acceptance** — a critical user or system path that cannot be reliably proven lower.
- **Property-based** — pure functions and transformations with a broad input space.
- **Regression/prove-it** — a test that first reproduces the bug and fails for the expected reason.

Do not move up to E2E if a unit/integration test catches the same defect more cheaply and stably.

## Test structure

Use a readable structure:

- Arrange / Given — preparing data and dependencies.
- Act / When — one action.
- Assert / Then — checking the meaningful result.

One test should check one meaningful fact. If the name contains “and”, the test may need to be split.

## Test doubles

Use fake/mock/stub only where it reduces noise and does not hide behavior:

- network;
- database;
- file system;
- system time;
- randomness;
- external SDKs;
- public contract of a dependency.

Do not mock internal implementation when checking the real code is simpler and more reliable.

## TDD and prove-it tests

Use TDD when the behavior is risky, unclear, central to the system, or part of a bug fix. Do not make test-first mandatory for every production change.

For a bug fix:

1. Write the smallest test that reproduces the bug.
2. Run it and confirm it fails for the expected reason.
3. Fix production code only after the failure is proven.
4. Run the test again and confirm it passes.
5. Run the relevant neighboring test set.

If the test fails for a different reason, fix the test or environment first. A test that was never observed failing does not prove the bug was fixed.

## Edge cases

For important logic, check:

- empty input;
- invalid input;
- boundary values;
- large data;
- Unicode and non-standard characters;
- dependency errors;
- timeout/cancellation;
- repeated events;
- concurrent calls;
- execution order, if it affects behavior.

## Antipatterns

- Checking only “did not crash”.
- Snapshotting huge output without a meaningful assertion.
- The test repeats the implementation.
- Testing mock behavior instead of product behavior.
- Incomplete mocks hide real bugs.
- Test-only methods or hooks leak into production code.
- Mocks verify that the mock was called but do not prove the result.
- The test depends on current time, locale, network, execution order, sleeps, or someone else's state.
- One test covers many unrelated scenarios.
- The test name is vague and does not state the protected behavior.
- The test was added after the code and was never observed failing for the new behavior.

## Good result

- It is clear which behavior is protected.
- The test fails with a clear reason when behavior breaks.
- The test is minimal and resilient to refactoring.
- The test level matches the risk.
- For a bug, there is red → green proof.
