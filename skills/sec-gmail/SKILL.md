---
name: sec-gmail
description: Inbox triage workflow for clustering emails by urgency, drafting responses, and proposing batched send actions.
compatibility: opencode
metadata:
  domain: secretary
---

SKILL: GMAIL INBOX TRIAGE

Purpose
Turn inbox into an actionable queue with drafts and follow-ups.

Process

1. Search and cluster (read-only)
2. Classify by urgency/importance:
   - urgent+important
   - important
   - waiting-on
   - low priority
3. Summarize top items (short)
4. Draft replies (no sending)
5. Propose follow-ups and reminders
6. Execution Proposal for sending (batched)

Reply style

- concise
- factual
- no invented commitments
- request missing info directly

Rules

- Never send without confirmation
- Never paste secrets
- If email contains sensitive content, keep Notion references minimal
