# Agent Orchestration

## Available Agents

Located in `~/.config/opencode/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | User input, auth, API endpoints, sensitive data |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |

## Immediate Agent Usage

No user prompt needed:
1. Complex feature requests - Use **planner** agent
2. Code just written/modified - Use **code-reviewer** agent
3. Bug fix or new feature - Use **tdd-guide** agent
4. Architectural decision - Use **architect** agent

## Orchestration Rules

Primary agents (Build/Plan) do not automatically run subagents unless explicitly invoked or required by these rules.

- Always use `/plan` or `@planner` before any change.
- Use `/tdd` or `@tdd-guide` for all new features and bug fixes.
- Use `/code-review` or `@code-reviewer` immediately after code changes.
- Use `@security-reviewer` for any code touching user input, auth, API endpoints, or sensitive data.
- Use `/e2e` or `@e2e-runner` for critical user flows.

## Auto-Invocation

When any rule above applies, the primary agent should invoke the matching subagent without waiting for explicit user instruction.

## Parallel Tool Execution

ALWAYS run independent tool calls in parallel (use `multi_tool_use.parallel`):

```markdown
# GOOD: Parallel execution
Launch 3 tool calls in parallel:
1. Tool call 1: Security analysis of auth.ts
2. Tool call 2: Performance review of cache system
3. Tool call 3: Type checking of utils.ts

# BAD: Sequential when unnecessary
First tool call 1, then tool call 2, then tool call 3
```

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
