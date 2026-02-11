---
name: error-handling
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
