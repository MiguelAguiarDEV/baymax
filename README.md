# OpenCode Config (Everything Claude Code)

Configuracion aplicada desde everything-claude-code y adaptada a OpenCode.

## Agentes
- architect
- build-error-resolver
- code-reviewer
- doc-updater
- e2e-runner
- planner
- refactor-cleaner
- security-reviewer
- tdd-guide

## Comandos
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

## Workflow recomendado (Baymax)
- **Plan siempre:** usar `/plan` antes de cualquier cambio.
- **TDD solo para features/bugs:** `/tdd` cuando sea nueva funcionalidad o fix real.
- **Code review siempre:** `/code-review` despues de cada cambio.
- **Security review cuando aplique:** `@security-reviewer` para input/auth/API/datos sensibles.
- **E2E solo para flujos criticos:** `/e2e` cuando el cambio afecte flujos clave.
- **Anti-overengineering:** preferir la solucion mas simple que cumpla requisitos.

## Memory (soft)
- El MCP `memory` esta habilitado, pero es opt-in.
- Solo guardar decisiones importantes, nuevas convenciones o fixes recurrentes.
- No guardar pasos rutinarios ni datos sensibles.

### Auto-commit y push de memoria
- Se guarda en `config/opencode/memory.json`.
- Cada escritura de memoria ejecuta `git add`, `git commit` y `git push` automaticamente.
- Se bloquea la persistencia (y por tanto el commit) si hay patrones de posibles secretos (tokens, keys, emails).
- Para desactivar, comenta el hook de `memory_` en `config/opencode/hooks/hooks.json`.
- Requiere `jq`, un repo git valido y upstream configurado para auto-push.
- Si el push falla (branch protegido o auth), el commit queda local.
- Comando manual: `/memory-save` (valida y pushea la memoria actual).

## MCPs (configurados en opencode.json)
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

Nota: MCP filesystem no expande ${HOME} en opencode.json; el instalador reemplaza ${HOME} por la home real.

## MCPs que requieren keys o autenticacion
Confirmado por configuracion o por respuesta del endpoint.

- github: requiere `GITHUB_PERSONAL_ACCESS_TOKEN`.
- firecrawl: requiere `FIRECRAWL_API_KEY`.
- context7: requiere `CONTEXT7_API_KEY`.
- vercel: endpoint remoto responde 401 -> requiere autenticacion (OAuth o headers).
- cloudflare-* (docs/builds/bindings/observability): endpoint remoto no acepto fetch (406). Probable OAuth o headers; tratar como autenticacion requerida.

## MCPs sin keys (habilitados)
- filesystem (local)
- playwright (local)
- memory (local)
- sequential-thinking (local)
- magic (local)

## Hooks (compatibilidad)
OpenCode no ejecuta hooks de Claude Code. Reglas equivalentes en:
- ~/.config/opencode/rules/hooks-compat.md

## Notion
Toda configuracion relacionada con Notion fue eliminada.
