---
name: notion-operations
description: Standard workflow for creating and maintaining Notion projects, tasks, meeting notes, and specs with safe drafting and gated publishing.
compatibility: opencode
metadata:
  domain: secretary
---

SKILL: NOTION OPERATIONS

Purpose
Standardize how Secretary creates and maintains Notion content:
- Projects
- Tasks
- Meeting Notes
- Specs/Plans

Core rule
No secrets in Notion. Ever.
If something is sensitive, store only references (links, names), never values.

Recommended structure
Databases (optional but recommended):
- Projects
- Tasks
- Meeting Notes

Naming conventions
Projects:
- <Client/Product> - <Short descriptor>

Tasks:
- <Verb> <object> (<context>)

Meeting notes:
- <YYYY-MM-DD> - <Topic>

Workflow
1) Extract intent (project/task/meeting/spec)
2) Draft content locally (no side effect)
3) Produce Execution Proposal (batched)
4) After approval: create/update pages/items
5) Deliver links + summary

Never do
- paste API keys/tokens/passwords
- store .env contents
- store production secrets
