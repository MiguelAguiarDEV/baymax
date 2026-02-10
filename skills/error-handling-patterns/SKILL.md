---
name: error-handling-patterns
description: Implement robust error handling with clear propagation and recovery strategies.
compatibility: opencode
metadata:
  domain: reliability
---

# Error Handling Patterns

Build resilient systems with explicit, testable error handling.

## Use Cases

- Designing API/service error contracts
- Improving reliability and observability
- Refactoring fragile try/catch flows
- Handling async/concurrent failures

## Core Patterns

- Typed/custom errors for domain cases
- Result-style handling for expected failures
- Retry with backoff for transient errors
- Graceful degradation with fallback behavior
- Error aggregation for validation pipelines
- Circuit breaker for dependent service instability

## Best Practices

- Fail fast on invalid input
- Preserve context (code, metadata, chain)
- Log once at the right boundary
- Never silently swallow errors
- Clean up resources reliably

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands (tests, repros, diagnostics).
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- If sensitive access is necessary, ask for minimal scoped approval first.

## Routing

- Use when: implementing resilient error semantics and recovery behavior.
- Combine with: `api-design-principles` for API contracts; `systematic-debugging` when fixing active failures.
- Do not use when: task is pure UX styling or layout composition.

Source: wshobson/agents `plugins/developer-essentials/skills/error-handling-patterns/SKILL.md`
