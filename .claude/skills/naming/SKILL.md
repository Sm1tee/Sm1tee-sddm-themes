---
name: naming
description: "Use always when creating or renaming files, classes, functions, variables, resources, events, and technical entities in any IT project."
---

# Naming

Names must help the next contributor understand the code's intent without reading the whole implementation.

## General rules

- Use English for technical names. Do not use transliteration.
- A name must reflect intent: what it is and why it exists, not the internal implementation method.
- Avoid abbreviations except those common in the project and industry: `id`, `url`, `uri`, `api`, `json`, `html`, `db`, `sql`, `http`.
- A longer but precise name is better than a short and mysterious one.
- Follow existing project conventions when they are clearly visible and do not hurt readability.
- Do not rename public APIs, files, or resources without necessity and without checking the consequences.

## Types, classes, and interfaces

- Use the naming style of the language and project: for example, `PascalCase` for classes in most C-like languages.
- Type names must be nouns or domain concepts: `UserProfile`, `PaymentRequest`, `RetryPolicy`.
- Use interface prefixes only if the project uses them. By default, prefer a behavior name: `Clickable`, `Serializable`, `UserStore`.
- Avoid the `Impl` suffix when the implementation can be named by meaning: `RemoteUserStore`, `FileSessionRepository`, `CachedFeatureProvider`.
- Use architectural suffixes only when they truly reflect the role in the project: `Controller`, `Service`, `Repository`, `UseCase`, `Handler`, `Adapter`, `Mapper`, `Dto`, `Entity`, `Model`, `Provider`, `Factory`.

## Functions and methods

- Use the naming style of the language and project: for example, `camelCase` in languages with that convention or `snake_case` where that is customary.
- A function name must start with an action or clearly express the computed value: `fetchUserData`, `calculateTotal`, `saveSettings`, `isValidEmail`.
- Do not name a function after its internal algorithm when calling code cares about the result, not the method.
- Functions with side effects must sound like actions: `sendEmail`, `writeFile`, `persistSession`.
- Pure functions can sound like computations or transformations: `formatPrice`, `parseConfig`, `normalizePath`.

## Variables and properties

- A variable name must be a noun or a clear domain state.
- Name collections in plural: `users`, `orders`, `enabledFeatures`.
- Name booleans as a question or state: `isVisible`, `hasError`, `shouldRetry`, `canSubmit`, `supportsStreaming`.
- Do not use negative boolean names without necessity: `isEnabled` reads more clearly than `isNotDisabled`.
- Temporary variables may be short only in a small local scope where the meaning is obvious.

## Constants and configuration

- For constants, follow the style of the language and project.
- Global compile-time/env-like constants are usually written as `SCREAMING_SNAKE_CASE`: `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS`.
- Configuration keys must be stable, clear, and grouped by meaning: `auth.sessionTimeout`, `storage.maxFileSize`.
- Do not name magic numbers with generic names like `VALUE`, `LIMIT`, `CONFIG`. The name must explain the constraint.

## Files and directories

- A file name must reflect the main export, module, or responsibility of the file.
- Do not create files with vague names such as `utils`, `helpers`, `common` when a more specific name is possible.
- If a file contains extensions, adapters, or helpers for a specific type/module, reflect that in the name: `string-formatting`, `date-parsing`, `user-mapping`.
- Name directories by domain area or responsibility, not by a random set of files.

## Events, states, and interface entities

- Name user or external-system events by the fact of the action: `SubmitClicked`, `PaymentAuthorized`, `FileDropped`, `MessageReceived`.
- Name states so it is clear what they represent: `LoadingState`, `CheckoutState`, `ConnectionStatus`.
- Name one-shot commands, effects, or messages by their purpose: `NavigateToProfile`, `ShowValidationError`, `RefreshToken`.
- Callback parameters usually start with `on` if that is customary in the language/stack: `onSubmit`, `onClose`, `onSelectionChanged`.

## Resources and external names

- Names of resources, assets, migrations, API routes, CLI commands, and config keys must follow project conventions.
- If there are no conventions, choose a stable, readable, and sortable format.
- For file resources, use lowercase and separators that are safe for the target file systems.
- Do not change external names that are part of a public contract without checking compatibility.

## Antipatterns

- `data`, `item`, `object`, `manager`, `processor`, `handler` without clarifying the role.
- Names that repeat the type but not the meaning: `stringValue`, `listData`, `objectInfo`.
- Names that hide a side effect: `getUser` must not unexpectedly write a file or send a request unless that is accepted in the project.
- Names based on the current implementation, which may change: `jsonUserStore` when JSON is not important to the contract.
- Different names for the same concept in neighboring layers without a reason.
