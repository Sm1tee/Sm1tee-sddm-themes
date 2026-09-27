---
name: security
description: "Use when implementing or reviewing security and performance: external input, secrets, PII, files, parsers, auth, permissions, dependencies, logging, memory, cache, databases, network, and hot paths."
---

# Security and Performance

Security and performance are checked against real system boundaries and hot paths, not against a list of generic tips.

## Trust boundaries

Treat these as untrusted:

- user input;
- files and archives;
- API requests, webhooks, and callbacks;
- env/config from the external environment;
- data from the database if it may have been written by an old version or an external system;
- network responses;
- CLI arguments;
- data from third-party SDKs.

At boundaries, there must be validation, normalization, limits, and visible error handling.

## Secrets and sensitive data

Check:

- whether tokens, passwords, keys, and credentials are absent from code;
- whether secrets can leak into logs, stack traces, crash reports, analytics, or snapshots;
- whether sensitive data is not stored in plain text without necessity;
- whether debug configurations did not enter the production path;
- whether errors do not expose private paths, payloads, or internal details.

Do not print discovered secrets in full. Mask values.

## Input validation and injection

Check risks:

- SQL/NoSQL injection;
- command injection;
- path traversal;
- template injection;
- HTML/JS/script injection;
- SSRF/open redirect;
- insecure deserialization;
- XML external entities;
- archive extraction attacks;
- MIME/type spoofing;
- unsafe regular expressions.

Do not “sanitize” blindly. Validation must match the format and place of use.

## Auth, permissions, and access control

Check:

- authentication and session lifecycle;
- authorization at the action and resource level;
- tenant/user boundaries;
- permission checks before data changes;
- callback/webhook verification;
- token expiration, refresh, and logout;
- safe defaults.

Never recommend disabling auth, validation, TLS, sandboxing, escaping, or permission checks as a fix.

## Dependencies and supply chain

Check:

- new dependencies are actually needed;
- the dependency does not look abandoned or suspicious;
- lock files are updated consistently;
- scripts/install hooks do not perform unexpected actions;
- versions do not downgrade security without a reason.

## Performance and resources

Look for:

- heavy operations in the request/render/event loop/main thread/hot path;
- N+1 queries;
- repeated parsing or repeated computation;
- unbounded collections, queues, and caches;
- missing pagination, batching, streaming, or lazy processing for large data;
- holding large objects longer than necessary;
- missing timeout, cancellation, or backpressure;
- leaks of file descriptors, connections, handles, subscriptions, or listeners.

## Errors and fallbacks

Flag:

- empty catch blocks;
- converting an error into success/null/empty without context;
- losing the stack trace;
- log-only handling where recovery or propagation is needed;
- retry without a limit, backoff, or cancellation exit;
- fallback that hides corrupted data or source failure.

## Good finding

Every security/performance finding must include:

- location in the code;
- problem mechanism;
- impact;
- proof or strong evidence;
- safe recommendation;
- check that will confirm the fix.

If there is no proof, call it a hypothesis and state what must be checked.
