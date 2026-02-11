---
name: op-prompter
description: Improve LLM reliability with structured prompting, templates, and evaluation patterns.
compatibility: opencode
metadata:
  domain: ai
---

# Prompt Engineering Patterns

Use this skill to maximize LLM output quality, consistency, and control in production contexts.

## Use Cases

- Designing reusable prompts and templates
- Improving consistency and parseability
- Applying few-shot and chain-of-thought patterns
- Enforcing structured outputs (JSON/schema)
- Iterative optimization with metrics and A/B tests

## Key Patterns

- Few-shot example selection (relevant and diverse)
- Stepwise reasoning where appropriate
- Schema-enforced structured output
- Progressive disclosure from simple to advanced prompts
- Fallback/error recovery for malformed responses
- Role-based system prompts with explicit constraints

## Best Practices

- Keep instructions specific and testable
- Version prompts like code
- Track quality, latency, and token usage
- Handle edge cases explicitly
