---
name: mcp-operations-runbook
description: Safety and credential runbook for operating Notion, Google, GitHub, Vercel, Stripe, Turso, Clerk, Resend, and Kubernetes MCPs.
compatibility: opencode
metadata:
  domain: platform
---

SKILL: MCP OPERATIONS RUNBOOK

Core principles
- Least privilege scopes
- Read-first, side-effects gated
- Never expose secrets in output
- Separate TEST and PROD explicitly

Capability highlights
- Notion: read/write pages and databases
- Google: Gmail read/draft/send (gated), Calendar read/create/update (gated)
- GitHub: read repos/issues/PR/CI, create comments/PR/issues (gated)
- Vercel: read projects/deploys, deploy and env changes (high risk)
- Stripe: test-mode operations by default; live mode is critical risk
- Turso: list DBs/tokens, run migrations (high risk)
- Clerk: auth settings/users, provider/redirect changes are high risk
- Resend: domains/senders and send test emails (gated)
- AWS/EKS/Kubernetes: read cluster state, apply/helm/secrets are critical risk

Credential handling
- Ask for secret values only when needed.
- Store secrets in environment or secret manager.
- Store only non-sensitive metadata in Notion.

Sanity checks
- Notion: fetch root page
- GitHub: read a repo or issue
- Gmail: search one email
- Calendar: list upcoming events
- Vercel: list projects
- Stripe: list products in test mode
- Turso: list DBs or run read-only query
- Kubernetes: list namespaces (read-only)
