AUTOMATION EVOLUTION GUIDE

Goal
Keep Baymax extensible while avoiding workflow sprawl.

Principle
Every new process must be classified first:
- Tool
- Skill
- Agent
- Hybrid

Standard process
1) Evaluate with `/workflow-evaluator`
2) Design with `/factory`
3) Scaffold with `scripts/scaffold.sh`
4) Validate with `scripts/doctor.sh`
5) Sync with `scripts/sync.sh push "<message>"`

When to prefer each form
- Tool: deterministic, atomic operation.
- Skill: repeatable checklist process.
- Agent: context-heavy decision making.
- Hybrid: deterministic ops + reasoning.

Quality gate
- No secret leakage
- Confirmation gates for side effects
- Verification evidence mandatory
