---
name: write-tests
description: Use when writing new tests, refactoring existing tests, or designing a test strategy. Applies industry-standard principles — AAA structure, FIRST traits, test pyramid, behavior-over-implementation, edge-case coverage. Language-agnostic.
---

# write-tests

Guidance for writing tests that catch real bugs, stay readable years later, and don't break on every refactor.

## When to use

- Adding tests for new code (feature, bug fix, refactor).
- Refactoring brittle, slow, or flaky tests.
- Planning a test strategy for a feature or module.
- Reviewing test code (use alongside `code-review`).

## Core principles

### AAA — Arrange / Act / Assert

Structure every test in three visually separated blocks:

1. **Arrange** — set up inputs, fixtures, doubles.
2. **Act** — invoke the single behavior under test.
3. **Assert** — verify the observable outcome.

Blank lines between blocks beat comments. If the Act block is more than one call, you're probably testing more than one thing.

### FIRST

- **Fast** — milliseconds, not seconds. Slow tests don't get run.
- **Independent** — any order, any subset, no shared mutable state.
- **Repeatable** — same result every run, on every machine. No clock, network, or randomness leaking in.
- **Self-validating** — pass/fail is unambiguous. No reading log output to decide.
- **Timely** — written with (or just before) the code, not bolted on later.

### Test behavior, not implementation

Assert on observable outputs and side effects at the boundary of the unit under test. Do not assert that a particular private method was called, or that an internal collaborator received a specific message — those assertions break the moment you refactor without changing behavior.

If a test fails when you change *how* something is done but not *what* it does, the test is over-specified.

### One logical concept per test

One test = one behavior. Multiple `expect`/`assert` calls are fine if they verify the same concept (e.g., asserting three fields of a returned object). Multiple unrelated behaviors → split into multiple tests with descriptive names.

### Test pyramid

Many fast unit tests, fewer integration tests, very few end-to-end tests. Inverted pyramids (mostly e2e) are slow, flaky, and expensive to maintain.

## Naming

Test names describe behavior, not method names. Pick one convention and stick to it:

- `should_<expected>_when_<condition>` — e.g., `should_reject_when_password_is_empty`.
- `given_<state>_when_<action>_then_<outcome>` — e.g., `given_empty_cart_when_checkout_then_throws`.

The name should let a reader understand the failure without opening the file.

## What to cover

For any unit under test, walk this list:

- **Happy path** — the canonical successful case.
- **Boundaries** — empty, zero, one, max, off-by-one.
- **Null / missing / undefined** inputs.
- **Error paths** — exceptions thrown, error returns, retries.
- **Idempotency** — calling twice should be safe where the contract says so.
- **Concurrency** — if the unit can be called concurrently, prove it's safe.

Coverage gaps usually live in the error paths, not the happy path.

## Mocks and doubles

- **Mock at architectural boundaries** — network, database, clock, filesystem, third-party APIs.
- **Never mock the system under test.** If you find yourself doing that, the unit boundary is wrong.
- **Prefer fakes over mocks** when feasible. A fake in-memory repository is more maintainable than a mock with five `.expects()` calls.
- **Don't mock what you don't own** without a thin adapter — mocks of third-party APIs drift from reality silently.

## Anti-patterns to flag

- Shared mutable state between tests (globals, singletons not reset).
- `sleep()` for synchronization — use polling with a timeout, or deterministic time control.
- Asserting on log output as the test oracle.
- Snapshot tests accepted without review — they just freeze whatever was there, including bugs.
- Tests that still pass when you delete the implementation — they're testing nothing.
- Tests that duplicate the implementation logic in the assertion.
- Conditional logic (`if`, `for`) inside tests — split into separate cases instead.

## Coverage

Coverage is a leading indicator, not a goal. 100% line coverage with weak assertions catches less than 60% with strong ones. When available, **mutation testing** (Stryker, mutmut, PIT) is a far better signal of test quality than line coverage.

## Pre-commit checklist

- [ ] Each test has a clear AAA structure.
- [ ] Test names describe behavior; a failure message would be self-explanatory.
- [ ] No `sleep`, no shared state, no order dependencies.
- [ ] Mocks only at architectural boundaries; no mocking the SUT.
- [ ] Edge cases covered: empty, null, boundary, error path.
- [ ] Test fails for the right reason — try inverting the assertion or breaking the code briefly to confirm.
- [ ] Test runs in milliseconds (unit) or seconds (integration).
