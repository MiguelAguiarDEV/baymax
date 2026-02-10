---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality.
compatibility: opencode
metadata:
  domain: frontend
---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic AI aesthetics.

Use this skill when the user asks to build web components, pages, or applications. Implement real working code with exceptional attention to aesthetic details and creative choices.

## Design Thinking

Before coding, understand context and commit to a clear aesthetic direction:
- Purpose: what problem the interface solves and who uses it
- Tone: choose a concrete visual language (minimal, brutalist, editorial, playful, etc.)
- Constraints: framework, accessibility, performance, platform
- Differentiation: one memorable design element that makes the output unique

## Frontend Aesthetics Guidelines

- Typography: avoid generic defaults; choose distinctive type pairings
- Color and theme: use cohesive tokenized palettes (CSS variables)
- Motion: prioritize meaningful entrance and interaction motion
- Spatial composition: use deliberate hierarchy, asymmetry, and rhythm
- Background and detail: add depth with textures, gradients, and layered surfaces when appropriate

## Critical Avoidances

- Avoid generic layouts and repetitive card grids by default
- Avoid overused purple-on-white gradient aesthetics
- Avoid one-size-fits-all type stacks (Arial/Roboto/Inter/system defaults)

## Output Quality Bar

- Production-grade and functional
- Distinctive and context-aware
- Consistent visual system
- Appropriate complexity for the chosen style

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands.
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- If sensitive access is necessary, ask for minimal scoped approval first.

## Routing

- Use when: building or redesigning visual frontend experiences and UI styling direction.
- Combine with: `brainstorming` -> `interface-design` -> `react-best-practices` (for React/Next implementation quality).
- Do not use when: task is mainly bug triage (`systematic-debugging`) or backend/API/database architecture.
- Discovery note: this skill may ask additional design questions (tone, color, typography, style) when material context is missing.

Source: anthropics/claude-code `plugins/frontend-design/skills/frontend-design/SKILL.md`
