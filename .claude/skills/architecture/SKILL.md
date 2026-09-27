---
name: architecture
description: "Use when designing the structure of an application, library, service, or CLI: responsibility boundaries, modules, dependencies, contracts, data flow, integration boundaries, and trade-offs without tying the solution to a specific stack."
---

# Architecture

Architecture is not for beautiful diagrams. It exists so changes stay understandable, verifiable, and safe for the project's evolution.

## Core principles

- Split the system by responsibility, not by accidental technical details.
- Keep business rules separate from transport, UI, storage, framework glue, and external SDKs.
- Point dependencies so stable rules do not depend on unstable details.
- Do not introduce an architectural pattern if the project already has a working style and the task does not require changing it.
- Do not create abstractions “for the future”. A new layer, interface, or module must solve a current confirmed risk.

## What to design explicitly

- Entry points: UI action, API route, CLI command, job, event, webhook, library call.
- Contracts: public API, interfaces, schemas, DTO, commands, events, state shapes.
- Data: where it is created, validated, transformed, stored, and returned outside.
- Errors: where they appear, where they are mapped, and how they become visible to the caller or user.
- Dependencies: who depends on whom and why.
- Boundaries: external input, network, files, database, queue, process, user/session, time/randomness.

## Responsibility boundaries

Typical zones, if they apply to the project:

- **Business/Application logic** — product rules, use cases, workflows, domain services.
- **Interface/API/UI** — inputs and outputs for the user or external clients.
- **Data/Storage** — persistence, repositories, DB, files, cache, schemas.
- **Integrations** — network clients, SDK adapters, queues, webhooks, external systems.
- **Infrastructure** — config, dependency wiring, build, runtime environment, jobs.
- **Tests** — behavior specification and regression protection.

Do not impose these zones on the project. If the actual structure is different, describe it from the files.

## Existing-pattern audit

Before adding a new mechanism to an existing area, check:

- how nearby entry points are structured;
- where contracts and models live;
- how data and errors are passed;
- how dependencies are wired;
- how tests are written;
- which naming and folder conventions already exist.

If the existing pattern is architecturally acceptable, follow it. Do not introduce a parallel style just because it seems cleaner.

## Errors and boundaries

- External-system errors must not leak deep into business logic without mapping.
- Errors must not turn into empty values without an explicit error state or justified recovery.
- Validation belongs at system boundaries and where invariants are protected.
- Contracts should make invalid state impossible or explicitly erroneous.

## Antipatterns

- A new layer without a current reason.
- An interface for a single implementation only “for cleanliness”.
- Business rules inside a controller, view, component, handler, or storage adapter.
- Transport/storage DTO used as the public model of the whole system.
- Cyclic dependencies between modules.
- A “god service” that knows about UI, DB, network, config, and business rules at once.
- Silent fallback instead of an explicit error.

## Result of a good architectural decision

- It is clear which files and zones are affected.
- It is clear where new logic should be added.
- It is clear where behavior should be tested.
- External-system details are isolated.
- Errors are visible and typed as much as is useful for the project.
- The diff solves the task without unnecessary framework around it.
