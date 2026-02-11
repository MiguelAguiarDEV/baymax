---
name: skill-self-repair
description: Detect and patch broken workflow skills with minimal diffs, root-cause analysis, and explicit verification steps.
compatibility: opencode
metadata:
  domain: governance
---

SKILL: SKILL SELF-REPAIR (AUTOREPAIR)

Goal
Allow Baymax to update skills when execution reveals missing or incorrect steps.

Definitions
- Skill: operational doc for workflow, prerequisites, commands, verification, evidence.
- Skill failure: workflow cannot proceed because the skill is wrong, incomplete, or ambiguous.

Triggers
- repeated command failures from missing prerequisites
- tooling mismatch (bun/pnpm, biome/eslint)
- CI drift (jobs changed, artifacts moved)
- new service requirements (env vars/config)
- repeated user clarifications for the same step
- local/CI behavior divergence

Repair Loop
1) Detect and stop safely.
2) Classify failure:
   - prerequisite missing
   - outdated command/config
   - environment mismatch
   - ambiguous step
3) Produce Skill Patch (minimal change).
4) Ask approval to apply patch to documentation.
5) Apply patch (or provide paste-ready markdown).
6) Resume from earliest safe step.

Patch format (mandatory)

# Skill Patch Proposal: <skill path/name>

## Symptom
- ...

## Root Cause
- ...

## Patch (minimal)
- Add/Change/Remove:
  - ...

## Updated Step(s)
- Step X: ...
- Step Y: ...

## Verification
- local:
- CI:
- evidence:

## Risk Notes
- ...

Rules
- Must not conflict with AGENTS.md.
- Must not include secret values.
- If security-sensitive, require @security-reviewer before accepting patch.
