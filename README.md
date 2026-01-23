# Baymax OpenCode Config

Your no‑nonsense OpenCode setup. Clean config, strict rules, and guardrails that keep your workflow fast without going off the rails.

## Index
- [Quick start](#quick-start)
- [What’s inside](#whats-inside)
- [Agents](#agents)
- [Subagents](#subagents)
- [Tools](#tools)
- [Commands](#commands)
- [Skills](#skills)
- [Rules](#rules)
- [Recommended workflow (Baymax)](#recommended-workflow-baymax)
- [Memory (soft)](#memory-soft)
- [MCPs](#mcps)
- [MCPs that need keys or auth](#mcps-that-need-keys-or-auth)
- [MCPs without keys (enabled)](#mcps-without-keys-enabled)
- [Hooks (compat)](#hooks-compat)
- [Notion](#notion)

## Quick start

```bash
git clone https://github.com/MiguelAguiarDEV/baymax.git
cd baymax
```

Install OpenCode (manual steps now; no auto‑installer here):

```bash
curl -fsSL https://opencode.ai/install -o /tmp/opencode-install.sh
less /tmp/opencode-install.sh
bash /tmp/opencode-install.sh
```

### Apply the config

**Option A (recommended):** symlink this repo to `~/.config/opencode` (non‑destructive, reversible).

```bash
mkdir -p ~/.config
ln -sfn "$(pwd)" ~/.config/opencode
```

**Option B:** replace your current config (backup first).

```bash
mv ~/.config/opencode ~/.config/opencode.bak
cp -R "$(pwd)" ~/.config/opencode
```

### Quick steps
1. `git clone` the repo.
2. Install OpenCode.
3. Apply the config with A or B.

### Edit → Review → Commit → Push
1. Edit files.
2. Run review.
3. Commit changes.
4. Push to `main`.

## What’s inside
- Specialist agents and subagents
- Commands, rules, skills, and contexts
- Tools guardrails and MCP config

## Agents
> Docs: https://opencode.ai/docs/agents/

- [architect](agents/architect.md)
- [build-error-resolver](agents/build-error-resolver.md)
- [code-reviewer](agents/code-reviewer.md)
- [doc-updater](agents/doc-updater.md)
- [deploy-work](agents/deploy-work.md)
- [e2e-runner](agents/e2e-runner.md)
- [planner](agents/planner.md)
- [refactor-cleaner](agents/refactor-cleaner.md)
- [security-reviewer](agents/security-reviewer.md)
- [tdd-guide](agents/tdd-guide.md)

## Subagents
Subagents are specialists that auto‑trigger based on the task (planning, TDD, security, E2E, etc.).

Use these as the “who” for the job. Each one has a defined profile and rules in `/agents`.

Same lineup as the agents in `/agents` (see list above).

## Tools
> Docs: https://opencode.ai/docs/tools/

Tools are the operational powers (bash, read, write, web, etc.) the agent uses to interact with your environment.
They’re gated by strict rules: safe read/write flows, input validation, and the right tool for the job.

- [OpenCode tools reference](https://opencode.ai/docs/tools/)

## Commands
> Docs: https://opencode.ai/docs/commands/

- [/build-fix](commands/build-fix.md)
- [/code-review](commands/code-review.md)
- [/deploy-work](commands/deploy-work.md)
- [/e2e](commands/e2e.md)
- [/learn](commands/learn.md)
- [/memory-save](commands/memory-save.md)
- [/plan](commands/plan.md)
- [/refactor-clean](commands/refactor-clean.md)
- [/tdd](commands/tdd.md)
- [/test-coverage](commands/test-coverage.md)
- [/update-codemaps](commands/update-codemaps.md)
- [/update-docs](commands/update-docs.md)

## Skills
> Docs: https://opencode.ai/docs/skills/

- [backend-patterns](skills/backend-patterns/SKILL.md)
- [clickhouse-io](skills/clickhouse-io/SKILL.md)
- [coding-standards](skills/coding-standards/SKILL.md)
- [continuous-learning](skills/continuous-learning/config.json)
- [deploy-work](skills/deploy-work/SKILL.md)
- [frontend-patterns](skills/frontend-patterns/SKILL.md)
- [project-guidelines-example](skills/project-guidelines-example/SKILL.md)
- [security-review](skills/security-review/SKILL.md)
- [strategic-compact](skills/strategic-compact/suggest-compact.sh)
- [tdd-workflow](skills/tdd-workflow/SKILL.md)

## Rules
> Docs: https://opencode.ai/docs/rules/

- [agents](rules/agents.md)
- [coding-style](rules/coding-style.md)
- [git-workflow](rules/git-workflow.md)
- [hooks](rules/hooks.md)
- [hooks-compat](rules/hooks-compat.md)
- [patterns](rules/patterns.md)
- [performance](rules/performance.md)
- [security](rules/security.md)
- [testing](rules/testing.md)

## Recommended workflow (Baymax)
- **Always plan:** use `/plan` before any change.
- **TDD for real changes:** `/tdd` for new features or actual fixes.
- **Always code review:** `/code-review` after each change.
- **Security review when needed:** `@security-reviewer` for input/auth/API/sensitive data.
- **E2E for critical flows:** `/e2e` when changes touch key flows.
- **Anti‑overengineering:** keep it simple, ship what meets the requirements.

## Memory (soft)
The `memory` MCP is enabled, but opt‑in.

- Stored at `~/.config/opencode/memory.json` (once linked).
- Every memory write runs `git add`, `git commit`, and `git push` automatically.
- Persistence is blocked if secret patterns are detected (tokens, keys, emails).
- To disable, comment out the `memory_` hook in `config/opencode/hooks/hooks.json`.
- Requires `jq`, a valid git repo, and upstream configured for auto‑push (with auth/permissions).
- If push fails (protected branch or auth), the commit stays local.
- Manual command: [/memory-save](commands/memory-save.md)

## MCPs
> Docs: https://opencode.ai/docs/mcp-servers/

- filesystem
- playwright
- memory
- sequential-thinking
- magic
- github
- firecrawl
- context7
- vercel
- cloudflare-docs
- cloudflare-observability
- cloudflare-workers-bindings
- cloudflare-workers-builds

Note: Some versions of the filesystem MCP don’t expand ${HOME}. The installer swaps in your real home path.

## MCPs that need keys or auth
Confirmed via config or endpoint response.

- github: requires `GITHUB_PERSONAL_ACCESS_TOKEN`.
- firecrawl: requires `FIRECRAWL_API_KEY`.
- context7: requires `CONTEXT7_API_KEY`.
- vercel: remote endpoint returns 401 → requires auth (OAuth or headers).
- cloudflare-* (docs/builds/bindings/observability): remote endpoint rejected fetch (406). Likely OAuth/headers; treat as auth‑required.

Note: 406 usually means missing headers or auth. Treat as credentials‑required.

## MCPs without keys (enabled)
- filesystem (local)
- playwright (local)
- memory (local)
- sequential-thinking (local)
- magic (local)

## Hooks (compat)
OpenCode doesn’t run Claude Code hooks. Equivalent rules live here:
- [hooks-compat](rules/hooks-compat.md)

## Notion
All Notion‑related config has been removed.
