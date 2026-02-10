---
name: workflow-classification
description: Decision framework to map a process to Tool, Skill, Agent, or Hybrid implementation.
compatibility: opencode
metadata:
  domain: architecture
---

SKILL: WORKFLOW CLASSIFICATION

Purpose
Choose the right automation unit to avoid over-engineering.

Decision tree
1) Is it atomic and deterministic?
- Yes -> Tool
- No -> continue

2) Is it a repeated multi-step process with known checklist?
- Yes -> Skill
- No -> continue

3) Does it require dynamic reasoning and context-dependent choices?
- Yes -> Agent
- No -> Skill

4) Does it combine deterministic actions + reasoning?
- Yes -> Hybrid (Tool + Agent or Skill + Agent)

Scoring matrix (0-2 each)
- Determinism
- Decision depth
- Repetition frequency
- Safety risk

Interpretation
- High determinism + low decision depth -> Tool
- High repetition + medium decision depth -> Skill
- High decision depth + variable inputs -> Agent
- Mixed scores -> Hybrid

Output requirement
- Classification
- Why
- Implementation blueprint
- Safety gates
- Verification plan
