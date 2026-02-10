---
name: api-design-principles
description: Design clear, consistent, and maintainable REST/GraphQL APIs.
compatibility: opencode
metadata:
  domain: backend
---

# API Design Principles

Use this skill to design developer-friendly APIs that scale over time.

## Focus Areas

- REST resource modeling and HTTP semantics
- GraphQL schema-first design and resolver quality
- Versioning and backward compatibility
- Pagination, filtering, and error contracts
- Documentation and usability standards

## REST Guidance

- Use resource nouns and standard methods (`GET/POST/PUT/PATCH/DELETE`)
- Keep URL hierarchy consistent
- Standardize status codes and error payloads
- Always paginate large collections
- Define rate limiting and API version strategy early

## GraphQL Guidance

- Use typed schemas and input/payload objects
- Prevent N+1 with DataLoader/batching
- Use cursor pagination for large lists
- Return structured mutation errors

## Reliability and DX

- Keep error formats consistent
- Avoid breaking changes without migration path
- Document endpoints/schemas with concrete examples

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands.
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- If sensitive access is necessary, ask for minimal scoped approval first.

## Routing

- Use when: defining or reviewing REST/GraphQL API contracts and conventions.
- Combine with: `error-handling-patterns` for response/failure strategy; `postgresql` for persistence alignment.
- Do not use when: task is primarily frontend visual design or isolated UI styling.

Source: wshobson/agents `plugins/backend-development/skills/api-design-principles/SKILL.md`
