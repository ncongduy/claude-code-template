---
name: code-review
description: Use before committing or opening a PR. Reviews changed code for correctness, readability, SOLID adherence, error handling at boundaries, common security smells (injection, secrets, missing auth checks), performance pitfalls, and scope discipline. Language-agnostic.
---

# code-review

Guidance for reviewing code — your own (pre-commit) or someone else's (pre-merge). Goal: catch the things that matter, ignore the things that don't, and tell the author which is which.

## When to use

- Pre-commit self-review of a diff you're about to land.
- Reviewing a teammate's PR.
- Sanity check before opening a PR for others to review.

## Review order

Review in this order. Stop and report blockers as soon as you find them — no point nitpicking style on code that doesn't work.

### 1. Correctness

- Does it actually solve the stated problem?
- Are edge cases handled (empty, null, boundary, concurrent, failure)?
- Are there off-by-one errors, wrong operators, swapped arguments?
- Does the change match the PR description / commit message?

### 2. Scope

- Does the diff do **one thing**?
- Flag drive-by refactors mixed into a feature/bugfix — they belong in a separate commit/PR.
- Flag dead code, commented-out code, leftover debug prints.

### 3. Design

- **SOLID** — single responsibility per unit, dependencies injected at boundaries, interfaces small.
- **Separation of concerns** — business logic, I/O, and presentation kept apart.
- **No premature abstraction** — Rule of Three: extract only when you have three real call sites, not two and a hypothetical one.
- **Avoid cleverness** — boring code is easier to maintain than clever code.

### 4. Readability

- **Naming** — names reveal intent; no abbreviations a newcomer wouldn't recognize.
- **Function length / cognitive load** — long functions with deep nesting are harder to verify than short ones with clear names.
- **Comments** — flag comments that explain *what* the code does (rename instead). Keep comments that explain *why* a non-obvious choice was made.
- **Dead code** — unused imports, unreachable branches, vestigial parameters.

### 5. Error handling

- Validate at **system boundaries** (user input, external APIs, deserialization). Trust internal callers.
- Don't swallow exceptions silently. Don't catch broad exceptions just to log and continue.
- Fail loudly on programmer errors; fail gracefully on user/environment errors.
- No `try/except: pass` or empty `catch` blocks.

### 6. Security smells

- **Injection** — string-concatenated SQL, shell commands built from user input, `eval`, unsafe template rendering.
- **Secrets** — credentials, tokens, API keys committed in code or config.
- **Authz/authn** — new endpoints or actions without permission checks.
- **Unsafe deserialization** — pickle, YAML `load`, untrusted JSON into typed objects.
- **Reflected user input** — rendered to HTML/logs/headers without escaping.
- **Crypto** — home-grown crypto, MD5/SHA1 for security purposes, predictable randomness for tokens.

### 7. Performance

- **N+1 queries** — loop calling the DB once per item.
- **Unbounded loops / collections** — loading all rows, no pagination, no limits on user input size.
- **Sync I/O in hot paths** — blocking calls inside request handlers / event loops.
- **Unnecessary allocations** — building large strings/arrays just to discard them.

### 8. Testability and tests

- Are new code paths covered by tests? (Use `write-tests` for what good coverage looks like.)
- Are the tests meaningful — would they fail if the implementation were wrong?
- Are dependencies injectable, or hard-coded behind `new SomeService()` calls?

## Anti-patterns to flag

- **Magic numbers / strings** — extract to a named constant.
- **Deep nesting** (more than ~3 levels) — early returns or extracted helpers usually help.
- **Boolean parameters** — `doThing(true)` is opaque at the call site; prefer two methods or an enum.
- **Primitive obsession** — passing a raw `string` everywhere when a small `EmailAddress` type would prevent bugs.
- **Comments explaining what** instead of why — usually a sign the code should be renamed.
- **TODOs without an owner or ticket** — they rot in place forever.

## What NOT to comment on

- **Bikeshedding** — formatting and style covered by a formatter / linter. If it's not enforced by tooling, don't argue about it in review.
- **Personal style preferences** unrelated to readability.
- **Hypothetical future requirements** — "what if we need X someday?" YAGNI.
- **Things outside the diff** — note them in a follow-up issue rather than blocking the current change.

## Output format

When reporting findings, group them by severity so the author knows what's actionable:

- **`[blocker]`** — must fix before merge (correctness, security, broken tests).
- **`[should-fix]`** — should fix but won't block merge (design, error handling, missing tests).
- **`[nit]`** — taste / minor improvement; author may ignore.

Always say *why* a thing is a problem, not just *what* — and where possible, suggest a concrete change.

## Pre-commit checklist

- [ ] Code does what the commit message claims; no scope creep.
- [ ] Edge cases handled (empty, null, boundary, error).
- [ ] No secrets, no obvious injection vectors, auth checks in place.
- [ ] No swallowed exceptions, no broad `catch`.
- [ ] No `console.log`, `print`, debugger statements, commented-out code.
- [ ] New behavior is tested; tests fail when the code is broken.
- [ ] Names make intent obvious; no surprise side effects in helpers.
- [ ] Diff is minimal — no unrelated reformatting, no dead files.
