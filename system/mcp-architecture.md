MCP ARCHITECTURE

Goal
Define:
- required MCP capabilities
- credentials needed
- permission boundaries
- agent responsibilities per MCP
- safety gates

Principles
- Minimal scopes (least privilege)
- Read allowed; side effects gated
- Secrets never exposed
- Separate TEST vs PROD

MCP Capability Matrix (conceptual)
Notion
- read pages/db
- create/update pages/db items

Google (Gmail + Calendar)
- gmail read + draft + optional send
- calendar read + create/update events

GitHub
- read issues/PR/CI
- create issues/PR/comments (gated)
- merge/release (high risk)

Vercel
- read projects/deploys
- create deploys / set env vars (high risk)

Stripe
- test mode operations (products/prices/webhooks)
- live mode operations (critical risk)

Turso
- list dbs/tokens
- run migrations (high risk)

Clerk
- read app config/users
- update auth settings (high risk)

Resend
- read domains/api keys
- send test emails (medium)
- configure domains (medium/high)

AWS/EKS/Kubernetes
- read cluster state
- deploy/apply/helm/secrets (critical)

All MCPs must support:
- a "read-only sanity check" operation
- explicit environment selection (staging vs prod)
- no secret value output
