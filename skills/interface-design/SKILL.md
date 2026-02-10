---
name: interface-design
description: Structure layouts, hierarchy, and components with deliberate visual craft.
compatibility: opencode
metadata:
  domain: frontend
---

# Interface Design

Build interface design with craft and consistency.

## Scope

Use for dashboards, admin panels, SaaS tools, settings pages, and data interfaces.
Not for marketing/landing pages (use frontend-design for those).

## Core Principle

Defaults create generic output. Every decision must be intentional and tied to user, task, and context.

## Required Discovery Before Designing

Produce these four outputs before proposing a direction:
1. Domain concepts (5+)
2. Color world rooted in the product domain (5+)
3. One signature element unique to this product
4. Three obvious defaults to reject and what replaces them

## Intent Questions

- Who is this human user in their real context?
- What exact task must they complete?
- What should the interface feel like?

If these are materially unclear, ask focused design questions before building.

## Craft Checks

- Swap test: does swapping typography/layout make no difference? If yes, it is generic.
- Squint test: hierarchy remains visible without harsh jumps.
- Signature test: signature appears in concrete components.
- Token test: design tokens feel domain-specific, not template-like.

## Design Foundations

- Subtle layering and border contrast
- Consistent spacing scale and padding rhythm
- Single depth strategy (borders-only or shadows)
- Clear typography hierarchy for headings/body/data
- Complete interaction and data states (hover, focus, disabled, loading, empty, error)

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands.
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- If sensitive access is necessary, ask for minimal scoped approval first.

## Routing

- Use when: structuring product interfaces, layouts, hierarchy, and component composition.
- Combine with: `brainstorming` first for ambiguous intent; `react-best-practices` during React/Next implementation.
- Do not use when: task is mainly visual theme experimentation (use `frontend-design`) or incident debugging.
- Discovery note: deeper question flow is acceptable for design decisions, but only for material ambiguity.

Source: skills.sh `dammyjay93/interface-design/interface-design`
