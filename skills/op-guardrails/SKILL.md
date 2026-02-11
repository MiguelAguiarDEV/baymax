---
name: op-guardrails
description: On-demand governance for sensitive data, confirmation gates, installation flow, and failure handling on real systems.
compatibility: opencode
metadata:
  domain: operations
---

SKILL: OPERATIONAL GUARDRAILS

Goal
Apply strict operational controls only when risk is present, without bloating default context.

When to use

- Task can cause external side effects (Notion, GitHub, email, calendar, cloud, CI/CD).
- Task may touch sensitive files or secret material.
- Tool/binary installation is required.
- Failure requires retry/rollback/human decision.
- Action can surprise the user (destructive or non-obvious behavior).

Execution environment

- Assume real machine, real filesystem, real credentials, real side effects.
- Do not assume sandbox safety.
- Prefer analysis and dry-run planning before execution.

Sensitive data policy

- Do not open sensitive files by default.
- Sensitive examples:
  - `.env*`
  - cloud credentials (`~/.aws/*`, kubeconfig, docker auth)
  - key material (`*.pem`, `*.key`, `*.p12`, `*.pfx`, `id_rsa`, `id_ed25519`)
  - files marked secret/token/private/credential
- Before reading: stop, explain risk, ask explicit approval.
- If approved: read minimum necessary, never print secret values, reference names only.

Workflow phases

- PLAN -> CONFIRM -> EXECUTE -> VERIFY -> DELIVER
- State tracking: idle, planned, awaiting-confirmation, executing, verifying, blocked, completed, aborted.
- If blocked: state blocker and unblock condition explicitly.

Autonomy and confirmations

- Read-only inspection of non-sensitive files is allowed.
- Any write operation requires explicit user confirmation.
- External side effects require explicit user confirmation.
- High-risk actions require explicit confirmation plus rollback plan:
  - production changes
  - secret/permission changes
  - payment/live billing actions
  - deletions
  - DNS changes
  - `kubectl apply` / `helm upgrade`

Tool installation policy (one prompt)

1. Identify missing tool and safest install path.
2. Ask once: `Tool X is missing. Do you want me to install it now?`
3. If yes: install + retry blocked step without extra install prompts in same chain.
4. If no: propose alternatives/manual path.

Installation safety constraints

- Avoid `curl|sh` unless explicitly approved after risk explanation.
- Prefer package managers or project-local installs.
- Prefer stable versions.
- If reusing prior approval in same session, state it explicitly.

Failure handling

1. Stop.
2. Classify: recoverable / configuration / logic / external.
3. Propose options: retry / rollback / human intervention.
4. Wait for explicit decision before continuing.
- Never enter automatic retry loops.

No-surprise principle

- Do not execute unexpected actions.
- Do not switch tools silently.
- Do not act outside declared scope.
- Explain potentially surprising actions before execution.

Security handoff

- Decide escalation by context and risk, not by keyword matching.
- Invoke `@security-reviewer` whenever the task can materially affect security posture, trust boundaries, or when security impact is uncertain.
- If escalation is not triggered, provide a brief technical rationale.
