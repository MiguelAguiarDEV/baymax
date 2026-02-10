---
name: brainstorming
description: Use before creative implementation work to refine intent, alternatives, and design.
compatibility: opencode
metadata:
  domain: planning
---

# Brainstorming Ideas Into Designs

## Overview

Turn rough ideas into clear, validated designs through collaborative dialogue.

## Process

1. Understand context first (project state, constraints, goals).
2. Ask questions only when genuinely blocked by missing or ambiguous information.
3. When questions are needed, ask one at a time.
4. Prefer multiple-choice questions when possible.
5. Propose 2-3 approaches with trade-offs and recommendation.
6. Present design in short sections and validate incrementally.

## Design Coverage

Include architecture, components, data flow, error handling, and testing.

## After Validation

- Before any file write or command execution, request explicit confirmation.
- Save design in `docs/plans/YYYY-MM-DD-<topic>-design.md` only after confirmation.
- Ask whether to proceed to implementation setup and planning.

## Principles

- Ask only when blocked
- One question at a time when questioning is necessary
- Explore alternatives before committing
- YAGNI-first scope control
- Iterate based on feedback

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands.
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- If sensitive access is necessary, ask for minimal scoped approval first.

## Routing

- Use when: goals are unclear and you need structured idea-to-design discovery.
- Combine with: `interface-design` or `frontend-design` for UI work; `api-design-principles` for backend contracts.
- Do not use when: task is already fully specified and ready for direct implementation.

Source: obra/superpowers `skills/brainstorming/SKILL.md`
