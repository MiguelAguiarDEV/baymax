---
name: op-changelog-generator
description: Transform technical commits into polished, user-facing changelogs.
compatibility: opencode
metadata:
  domain: documentation
---

# Changelog Generator

Convert raw git history into professional, user-friendly release notes.

## When to Use

- Release notes for new versions
- Weekly/monthly product updates
- Customer-facing update summaries
- Internal release documentation

## What It Does

- Scans git commits for a selected range
- Categorizes changes (features, improvements, fixes, breaking, security)
- Rewrites technical commits into user language
- Filters internal noise (refactor/tests/chore where appropriate)
- Outputs consistent changelog structure

## Recommended Workflow

1. Before running git commands or writing changelog files, request explicit confirmation.
2. Run from repository root.
3. Select period or tag range.
4. Apply project changelog style guide if available.
5. Review generated entries before publishing.

## Output Shape

- Sectioned by category
- Clear bullets in plain language
- Highlights user impact

## Safety Gates

- AGENTS.md is the controlling policy for this skill.
- Ask for explicit confirmation before any file edit/write.
- Ask for explicit confirmation before running commands (git log, git diff, generators).
- Do not read sensitive files by default (`.env*`, keys, tokens, credentials).
- Do not include secrets, tokens, credentials, or PII in changelog output.

## Routing

- Use when: generating release notes from commits/change history.
- Combine with: implementation skills first (`react-best-practices`, `api-design-principles`, etc.), then run this at release/summary stage.
- Do not use when: there are no meaningful code changes to summarize.

Source: skills.sh `composiohq/awesome-claude-skills/changelog-generator`
