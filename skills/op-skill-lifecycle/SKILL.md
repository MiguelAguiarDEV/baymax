---
name: op-skill-lifecycle
description: Create, update, deprecate, and repair skills with minimal diffs and explicit validation gates.
compatibility: opencode
metadata:
  domain: governance
---

SKILL: SKILL LIFECYCLE MANAGEMENT

Goal
Manage skills end-to-end with reproducible steps and low-risk changes.

When to use

- Add a new skill.
- Update an existing skill.
- Deprecate/remove a skill.
- Repair a broken skill workflow.

Lifecycle workflow

1. Classify request

- Create: new workflow capability.
- Update: behavior/content change in existing skill.
- Deprecate/Delete: no longer used or replaced.
- Repair: workflow fails in real usage.

2. Plan change scope

- Identify affected files:
  - `skills/<name>/SKILL.md`
  - `skills/ACTIVE_SKILLS.txt` (if activation/deactivation is needed)
  - `AGENTS.md` table (auto-generated via script only)
- Define validation evidence up front.

3. Implement

- Create:
  - `./scripts/scaffold.sh skill <name> "<description>"`
  - Fill `SKILL.md` with concrete steps, safety, verification.
  - Add `<name>` to `skills/ACTIVE_SKILLS.txt` only if it should be auto-loaded.
- Update:
  - Edit minimal sections only.
  - Keep frontmatter stable unless intentionally changed.
- Deprecate/Delete:
  - Remove from `skills/ACTIVE_SKILLS.txt` first.
  - If hard delete is approved, remove `skills/<name>/`.
  - Prefer deactivation over deletion unless explicitly requested.
- Repair:
  - Follow root-cause + patch flow from failure evidence.
  - Keep patch minimal and reversible.

4. Validate

- `python3 scripts/generate-skills-table.py`
- `./scripts/doctor.sh`
- Verify AGENTS table includes only active skills.

5. Deliver

- Change summary (what changed and why).
- Validation evidence.
- Rollback note (how to revert quickly).

Rules

- No secret leakage.
- No broad rewrites when a minimal patch solves it.
- Require `@security-reviewer` when a skill changes security posture or introduces uncertain risk.
