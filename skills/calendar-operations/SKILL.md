---
name: calendar-operations
description: Standard workflow for scheduling and managing calendar events with timezone checks, slot proposals, and gated invite creation.
compatibility: opencode
metadata:
  domain: secretary
---

SKILL: CALENDAR OPERATIONS

Purpose
Standardize scheduling and event creation with minimal friction.

Defaults
- Timezone: user's local timezone unless specified
- Buffers: 10 min before/after meetings by default
- Meeting titles: specific and action-oriented

Process
1) Read availability (no side effects)
2) Propose 2-4 time slots
3) Confirm attendees + duration + location/link
4) Draft event description (goal + agenda + links)
5) Execution Proposal
6) Create/update event after approval

Event template
- Goal
- Agenda (3-5 bullets)
- Links (Notion doc, PR, issue)
- Decisions to make

Rules
- Never create/send invites without confirmation
- Always confirm timezone if ambiguity exists
- Avoid double-booking; propose alternatives
