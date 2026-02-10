---
name: postgresql
description: Design PostgreSQL schemas, constraints, and indexing for correctness and performance.
compatibility: opencode
metadata:
  domain: database
---

# PostgreSQL Table Design

Design PostgreSQL schemas with correctness first, then measured performance optimization.

## Core Rules

- Normalize first; denormalize only with measured need
- Use `NOT NULL`, `CHECK`, and FK constraints deliberately
- Index real query paths (including FK columns)
- Prefer `TIMESTAMPTZ` for event time and `NUMERIC` for money
- Prefer identity columns over `serial`

## Data and Constraint Guidance

- Use `TEXT` unless strict length constraints are required
- Use partial/expression/composite indexes only for known access patterns
- Use JSONB for semi-structured attributes; keep core relations normalized
- Choose partitioning only when scale/workload justifies it

## Performance Notes

- Minimize unnecessary indexes on write-heavy tables
- Use bulk insert patterns (`COPY`, multi-row inserts)
- Consider fillfactor/HOT behavior for update-heavy tables

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands (migrations, SQL scripts, schema changes).
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- If sensitive access is necessary, ask for minimal scoped approval first.

## Routing

- Use when: designing PostgreSQL schema, constraints, indexes, and query access paths.
- Combine with: `api-design-principles` for contract-to-schema fit; `systematic-debugging` for DB-related failures.
- Do not use when: task is strictly frontend/UI or non-database architecture.

Source: wshobson/agents `plugins/database-design/skills/postgresql/SKILL.md`
