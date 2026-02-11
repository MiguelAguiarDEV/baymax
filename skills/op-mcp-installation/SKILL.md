---
name: op-mcp-installation
description: Cascading MCP installation and credential validation protocol with one-prompt confirmation and minimal sanity checks.
compatibility: opencode
metadata:
  domain: platform
---

SKILL: MCP INSTALLATION FLOW

Goal
Install MCPs and gather credentials safely, with minimal friction.

Golden rules

- Never store secret values in Notion.
- Never echo secret values in chat logs.
- Prefer secret managers and env vars.
- One confirmation per installation chain.

Recommended order

1. Notion
2. GitHub
3. Google (Gmail + Calendar)
4. Turso
5. Vercel
6. Stripe
7. Clerk
8. Resend
9. AWS/EKS/Kubernetes (only when needed)

Standard install protocol (ONE PROMPT)

1. Explain what MCP enables.
2. List credentials required (names only).
3. Ask once: "Install/configure this MCP now?"
   If yes:

- complete setup steps
- run sanity check
- record non-sensitive metadata in Notion
- continue workflow

Sanity checks (minimal)

- Notion: fetch root page
- GitHub: read repo/issue
- Gmail: search one email
- Calendar: list upcoming events
- Turso: list DBs or run read-only query
- Vercel: list projects
- Stripe: list products in TEST
- Clerk: read app details/users
- Resend: list domains/senders
- AWS: describe cluster (read-only)

Credential handling

- Ask for values only when needed.
- Never paste secrets into Notion; store only:
  - credential names
  - storage location reference
  - validation status
