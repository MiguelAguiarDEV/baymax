---
name: stack-freelance
description: Delivery standard for SaaS projects using Next.js, TypeScript, Tailwind, shadcn, Turso, Clerk, Stripe, Resend, Vercel, Bun, and Biome.
compatibility: opencode
metadata:
  domain: engineering
  workflow: saas-delivery
---

SKILL: STACK FREELANCE

Purpose
Standardize how Baymax delivers SaaS projects fast with high quality and repeatable delivery.

Applies To
- Web SaaS (Next.js App Router) with auth, payments, emails, DB, hosting
- MVPs and client projects

Non-Goals
- Complex microservices
- Highly regulated compliance architectures unless explicitly required

DEFAULT ARCHITECTURE

Frontend/Backend
- Next.js App Router
- Server Components by default
- Client Components only when needed for interactivity/forms
- Server Actions for internal mutations (CRUD)
- API Routes for webhooks and public endpoints

DB
- Turso (remote SQLite)
- Explicit schema + migration discipline

Auth
- Clerk (OAuth providers)
- Role-based checks on server boundaries

Payments
- Stripe
- Test mode by default
- Webhooks are mandatory for payment state transitions

Emails
- Resend (or Oracle if required)
- Transactional emails only

Lint/Format
- Biome

Package Manager
- Bun

Hosting
- Vercel (staging preview + prod)

PROJECT SETUP CHECKLIST

Repo creation
- bunx create-next-app@latest <name>
- TypeScript yes
- Tailwind yes
- App Router yes
- commit initial

Dependencies
- @libsql/client
- @clerk/nextjs
- stripe
- zod
- react-hook-form
- resend
- biome dev dependency
- playwright (E2E) when applicable

Folder structure (baseline)
- app/
- app/api/webhooks/stripe
- components/
- lib/db/
- lib/validations/
- lib/utils/
- types/

Env vars (names only)
- TURSO_URL
- TURSO_TOKEN
- NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
- CLERK_SECRET_KEY
- STRIPE_SECRET_KEY (TEST)
- STRIPE_PUBLISHABLE_KEY (TEST)
- STRIPE_WEBHOOK_SECRET (per env)
- RESEND_API_KEY
- NEXT_PUBLIC_APP_URL

Rule: never paste values into Notion.

DEVELOPMENT WORKFLOW (STANDARD)

Phase 1: Discovery -> Spec
- Use @planner to create scope, architecture notes, MVP tasks, and acceptance criteria.
- Secretary documents in Notion.

Phase 2: Implement (TDD)
- Use @tdd-guide for new features/bugfixes.
- Implement minimal, incremental changes.

Phase 3: Verification
- Unit/integration tests as relevant.
- E2E for critical user flows.
- Ensure build passes.

Phase 4: PR
- Include what changed, how to test, evidence, and risk notes.

Phase 5: CI + Merge Gates
- Biome lint
- Typecheck
- Build
- Playwright E2E (if configured)

Phase 6: Deploy
- Vercel preview per PR
- Merge to main triggers production deploy
- Production webhooks only after staging validation

DELIVERY CHECKLIST
- [ ] Staging validated by client
- [ ] Stripe webhooks configured (prod)
- [ ] Domain configured
- [ ] Admin access granted (Clerk)
- [ ] Notion docs updated (architecture, env var names, runbook, platform links)
