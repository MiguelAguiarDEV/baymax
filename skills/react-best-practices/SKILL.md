---
name: react-best-practices
description: Apply modern React and Next.js performance patterns with prioritized rules.
compatibility: opencode
metadata:
  domain: frontend
---

# Vercel React Best Practices

Comprehensive performance optimization guide for React and Next.js applications.

## When to Apply

- Writing new React components or Next.js pages
- Implementing data fetching (client/server)
- Reviewing code for performance issues
- Refactoring existing React code
- Optimizing bundle size and load times

## Priority Categories

1. Eliminating waterfalls (`async-*`) - critical
2. Bundle size optimization (`bundle-*`) - critical
3. Server-side performance (`server-*`) - high
4. Client-side fetching (`client-*`) - medium-high
5. Re-render optimization (`rerender-*`) - medium
6. Rendering performance (`rendering-*`) - medium
7. JavaScript performance (`js-*`) - low-medium
8. Advanced patterns (`advanced-*`) - low

## High-Impact Rules

- Prefer parallel async (`Promise.all`) for independent work
- Import directly; avoid barrel imports in hot paths
- Use dynamic imports for heavy components
- Authenticate server actions like API routes
- Prevent unnecessary subscriptions and unstable dependencies
- Use transition APIs for non-urgent updates

## Usage Pattern

- Start with waterfall and bundle checks
- Address server and client fetch behavior next
- Then optimize rendering/re-renders
- Finish with lower-impact JS micro-optimizations

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands (tests, builds, profiling).
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- If sensitive access is necessary, ask for minimal scoped approval first.

## Routing

- Use when: implementing or refactoring React/Next code for quality and performance.
- Combine with: `interface-design`/`frontend-design` for UI intent; `systematic-debugging` for regressions.
- Do not use when: task is pure product discovery, API design, or database schema work.

Source: skills.sh `vercel-labs/agent-skills/vercel-react-best-practices`
