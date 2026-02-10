SKILL SELF-REPAIR (AUTOREPAIR) - SPEC

Goal
Allow Baymax to update skills when real execution reveals missing/incorrect steps, reducing future friction.

Definitions
- Skill: operational doc describing workflow, prerequisites, commands, verification, and evidence.
- Skill failure: the workflow cannot proceed because the skill is wrong/incomplete/ambiguous.

Triggers
- repeated command failures caused by missing prerequisites
- tool mismatch (bun/pnpm, biome/eslint)
- CI drift (jobs changed, artifacts moved)
- new service requirements (new env vars, extra config)
- repeated user clarifications for the same step
- inconsistent outcomes between local and CI

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
- If security-sensitive: require @security-reviewer before accepting patch.

Optional Enhancement: Skill Versioning
- Each skill has a version header (v1, v1.1, v2)
- Each patch increments minor version
- Record patch reason and date
