---
name: prompt-engineering-patterns
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

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands or batch evaluations.
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- Do not include secrets or sensitive user data in prompts, examples, or logs.

## Routing

- Use when: improving prompt reliability, structure, and output consistency.
- Combine with: `error-handling-patterns` for fallback/retry behavior; `api-design-principles` for LLM-backed API interfaces.
- Do not use when: task is purely visual design or unrelated infrastructure debugging.

Source: wshobson/agents `plugins/llm-application-dev/skills/prompt-engineering-patterns/SKILL.md`
