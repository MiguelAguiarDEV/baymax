# Baymax OpenCode Config

Configuración clara y consistente para OpenCode. Pensada para mantener disciplina en el flujo de trabajo sin sobre‑ingeniería.

## Índice
- [Inicio rápido](#inicio-rápido)
- [Docs oficiales (OpenCode)](#docs-oficiales-opencode)
- [Enlaces directos de OpenCode](#enlaces-directos-de-opencode)
- [Qué incluye](#qué-incluye)
- [Agentes](#agentes)
- [Comandos](#comandos)
- [Skills](#skills)
- [Rules](#rules)
- [Workflow recomendado (Baymax)](#workflow-recomendado-baymax)
- [Memory (soft)](#memory-soft)
- [MCPs (configurados en opencode.json)](#mcps-configurados-en-opencodejson)
- [MCPs que requieren keys o autenticación](#mcps-que-requieren-keys-o-autenticación)
- [MCPs sin keys (habilitados)](#mcps-sin-keys-habilitados)
- [Hooks (compatibilidad)](#hooks-compatibilidad)
- [Notion](#notion)

## Inicio rápido

```bash
git clone https://github.com/MiguelAguiarDEV/baymax.git
cd baymax
```

Instalar OpenCode (si no lo tienes):

```bash
curl -fsSL https://opencode.ai/install | bash
```

Vincular la configuración:

```bash
mkdir -p ~/.config
ln -sfn "$(pwd)" ~/.config/opencode
```

## Docs oficiales (OpenCode)
- https://opencode.ai/docs
- https://github.com/opencode-ai/opencode

## Enlaces directos de OpenCode
- Instalación: https://opencode.ai/docs/#install
- Configuración: https://opencode.ai/docs/config/
- Agentes: https://opencode.ai/docs/agents/
- Tools: https://opencode.ai/docs/tools/
- Skills: https://opencode.ai/docs/skills/
- Commands: https://opencode.ai/docs/commands/
- Rules: https://opencode.ai/docs/rules/
- MCP Servers: https://opencode.ai/docs/mcp-servers/

## Qué incluye
- Agentes especializados
- Comandos y reglas operativas
- Skills y contextos
- Hooks y configuración de MCPs

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
- **Code review siempre:** `/code-review` después de cada cambio.
- **Security review cuando aplique:** `@security-reviewer` para input/auth/API/datos sensibles.
- **E2E solo para flujos críticos:** `/e2e` cuando el cambio afecte flujos clave.
- **Anti-overengineering:** preferir la solución más simple que cumpla requisitos.

## Memory (soft)
- El MCP `memory` está habilitado, pero es opt‑in.
- Solo guardar decisiones importantes, nuevas convenciones o fixes recurrentes.
- No guardar pasos rutinarios ni datos sensibles.

### Auto-commit y push de memoria
- Se guarda en `~/.config/opencode/memory.json` (una vez enlazado).
- Cada escritura de memoria ejecuta `git add`, `git commit` y `git push` automáticamente.
- Se bloquea la persistencia (y por tanto el commit) si hay patrones de posibles secretos (tokens, keys, emails).
- Para desactivar, comenta el hook de `memory_` en `config/opencode/hooks/hooks.json`.
- Requiere `jq`, un repo git válido y upstream configurado para auto‑push (con auth/permisos).
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

Nota: El MCP filesystem no expande ${HOME} en opencode.json; el instalador reemplaza ${HOME} por la home real.

## MCPs que requieren keys o autenticación
Confirmado por configuración o por respuesta del endpoint.

- github: requiere `GITHUB_PERSONAL_ACCESS_TOKEN`.
- firecrawl: requiere `FIRECRAWL_API_KEY`.
- context7: requiere `CONTEXT7_API_KEY`.
- vercel: endpoint remoto responde 401 → requiere autenticación (OAuth o headers).
- cloudflare-* (docs/builds/bindings/observability): endpoint remoto no aceptó fetch (406). Probable OAuth o headers; tratar como autenticación requerida.

Nota: 406 suele indicar headers o auth faltantes. Considerar como MCP que requiere credenciales.

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
Toda configuración relacionada con Notion fue eliminada.
