# Baymax OpenCode Config

Clean, consistent OpenCode config. Built to keep your workflow disciplined without over‑engineering.

## Index
- [Quick start](#quick-start)
- [Official OpenCode docs](#official-opencode-docs)
- [OpenCode deep links](#opencode-deep-links)
- [What’s inside](#whats-inside)
- [Agents](#agents)
- [Subagents](#subagents)
- [Tools](#tools)
- [Commands](#commands)
- [Skills](#skills)
- [Rules](#rules)
- [Recommended workflow (Baymax)](#recommended-workflow-baymax)
- [Memory (soft)](#memory-soft)
- [MCPs (in opencode.json)](#mcps-in-opencodejson)
- [MCPs that need keys or auth](#mcps-that-need-keys-or-auth)
- [MCPs without keys (enabled)](#mcps-without-keys-enabled)
- [Hooks (compat)](#hooks-compat)
- [Notion](#notion)

## Quick start

```bash
git clone https://github.com/MiguelAguiarDEV/baymax.git
cd baymax
```

Install OpenCode (if you don’t have it). The old auto‑installer isn’t run for you anymore—these steps are manual.

```bash
curl -fsSL https://opencode.ai/install -o /tmp/opencode-install.sh
less /tmp/opencode-install.sh
bash /tmp/opencode-install.sh
```

Pick how you want to apply the config:

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

## Official OpenCode docs
- https://opencode.ai/docs
- https://github.com/opencode-ai/opencode

## OpenCode deep links
- Install: https://opencode.ai/docs/#install
- Config: https://opencode.ai/docs/config/
- Agents: https://opencode.ai/docs/agents/
- Tools: https://opencode.ai/docs/tools/
- Skills: https://opencode.ai/docs/skills/
- Commands: https://opencode.ai/docs/commands/
- Rules: https://opencode.ai/docs/rules/
- MCP Servers: https://opencode.ai/docs/mcp-servers/

## What’s inside
- Specialist agents
- Commands and operational rules
- Skills and contexts
- Hooks + MCP configuration

## Agents
- architect
- build-error-resolver
- code-reviewer
- doc-updater
- e2e-runner
- planner
- refactor-cleaner
- security-reviewer
- tdd-guide

## Subagents
Subagents are specialists that auto‑trigger based on the task (planning, TDD, code review, security, E2E, etc.).
This repo defines the profiles and when to spin them up. The list above shows what’s available.

## Tools
Tools are the operational powers (bash, read, write, web, etc.) the agent uses to interact with your environment.
They’re gated by strict rules: safe read/write flows, input validation, and the right tool for the job.

## Commands
- /build-fix
- /code-review
- /deploy-work
- /e2e
- /learn
- /memory-save
- /plan
- /refactor-clean
- /tdd
- /test-coverage
- /update-codemaps
- /update-docs

## Skills
- backend-patterns
- clickhouse-io
- coding-standards
- continuous-learning
- deploy-work
- frontend-patterns
- project-guidelines-example
- security-review
- strategic-compact
- tdd-workflow

## Rules
- agents
- coding-style
- git-workflow
- hooks
- hooks-compat
- patterns
- performance
- security
- testing

## Recommended workflow (Baymax)
- **Always plan:** use `/plan` before any change.
- **TDD for real changes:** `/tdd` for new features or actual fixes.
- **Always code review:** `/code-review` after each change.
- **Security review when needed:** `@security-reviewer` for input/auth/API/sensitive data.
- **E2E for critical flows:** `/e2e` when changes touch key flows.
- **Anti‑overengineering:** keep it simple, ship what meets the requirements.

## Memory (soft)
- The `memory` MCP is enabled, but opt‑in.
- Only store important decisions, new conventions, or recurring fixes.
- Don’t store routine steps or sensitive data.

### Memory auto‑commit + push
- Stored at `~/.config/opencode/memory.json` (once linked).
- Every memory write runs `git add`, `git commit`, and `git push` automatically.
- Persistence is blocked if secret patterns are detected (tokens, keys, emails).
- To disable, comment out the `memory_` hook in `config/opencode/hooks/hooks.json`.
- Requires `jq`, a valid git repo, and upstream configured for auto‑push (with auth/permissions).
- If push fails (protected branch or auth), the commit stays local.
- Manual command: `/memory-save` (validates and pushes current memory).

## MCPs (in opencode.json)
- cloudflare-docs
- cloudflare-observability
- cloudflare-workers-bindings
- cloudflare-workers-builds
- context7
- filesystem
- firecrawl
- github
- magic
- memory
- playwright
- sequential-thinking
- vercel

Note: The filesystem MCP does not expand ${HOME} in opencode.json; the installer swaps in your real home path.

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
- ~/.config/opencode/rules/hooks-compat.md

## Notion
All Notion‑related config has been removed.
