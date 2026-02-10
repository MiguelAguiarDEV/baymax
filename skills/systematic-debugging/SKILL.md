---
name: systematic-debugging
description: Step-by-step root cause debugging before proposing fixes.
compatibility: opencode
metadata:
  domain: debugging
---

# Systematic Debugging

Core law: no fixes without root cause investigation.

## Four Phases

1. Root cause investigation
   - Read errors fully
   - Reproduce consistently
   - Check recent changes
   - Trace data flow across boundaries
2. Pattern analysis
   - Find working references
   - Compare broken vs working behavior
3. Hypothesis and testing
   - Form one hypothesis
   - Make minimal test change
4. Implementation
   - Create failing test first
   - Implement single fix
   - Verify no regressions

## Stop Conditions

- If guessing starts, return to phase 1.
- If 3+ fix attempts fail, stop and question architecture before continuing.

## Anti-Patterns

- Quick patches without investigation
- Multiple fixes at once
- Skipping test-first validation
- Assuming without evidence

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands (tests, logs, repro scripts).
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- If sensitive access is necessary, ask for minimal scoped approval first.

## Routing

- Use when: there is a bug, failing test, production incident, or unexpected behavior.
- Combine with: `error-handling-patterns` for remediation patterns; `react-best-practices` or `postgresql` by affected layer.
- Do not use when: task is purely greenfield design with no defect signal.

Source: obra/superpowers `skills/systematic-debugging/SKILL.md`
