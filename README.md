# Baymax OpenCode Configuration

Sistema portable de OpenCode para Baymax: instalacion rapida, orquestacion de agentes, skills versionados y sincronizacion multi-PC.

## Indice

- [Que incluye](#que-incluye)
- [Instalacion ultra rapida (nuevo PC)](#instalacion-ultra-rapida-nuevo-pc)
- [Scripts principales](#scripts-principales)
- [Requisitos](#requisitos)
- [MCPs incluidos](#mcps-incluidos)
- [Autenticacion MCP](#autenticacion-mcp)
- [Flujo para crear nuevas skills/agentes (super rapido)](#flujo-para-crear-nuevas-skillsagentes-super-rapido)
- [Sincronizacion entre PCs](#sincronizacion-entre-pcs)
- [Instalacion multi-provider (OpenCode, Codex, Gemini, Antigravity, Claude Code)](#instalacion-multi-provider-opencode-codex-gemini-antigravity-claude-code)
- [Comandos slash core (flujo reducido)](#comandos-slash-core-flujo-reducido)
- [Comandos slash opcionales (planner-routed)](#comandos-slash-opcionales-planner-routed)
- [Taxonomia de skills (tags)](#taxonomia-de-skills-tags)
- [Formato de commits y PR](#formato-de-commits-y-pr)
- [Flujo release/deploy automatizado](#flujo-releasedeploy-automatizado)
- [Nota de seguridad](#nota-de-seguridad)

## Que incluye

- `AGENTS.md` con gobernanza global
- `opencode.json` con agente por defecto, permisos y MCPs
- agentes personalizados (`agents/`)
- comandos slash (`commands/`)
- skills operativos (`skills/`)
- docs (`docs/`)
- scripts de automatizacion (`scripts/`)

## Instalacion ultra rapida (nuevo PC)

```bash
mkdir -p ~/.config
git clone https://github.com/MiguelAguiarDEV/opencode-baymax-config.git ~/.config/opencode
~/.config/opencode/scripts/bootstrap.sh
```

`bootstrap.sh` hace pull/clone seguro, conserva backups si hace falta y ejecuta `doctor`.

## Scripts principales

- `scripts/bootstrap.sh` -> instala/actualiza esta config en una maquina
- `scripts/doctor.sh` -> valida estructura, comandos y estado MCP
- `scripts/scaffold.sh` -> crea skill/agent/command/mode con plantilla
- `scripts/sync.sh` -> flujo de sync con git (`status`, `pull`, `push`, `publish`)
- `scripts/helm-safe-upgrade.sh` -> `helm upgrade --install` endurecido (wait/atomic/rollback-safe)
- `scripts/release-pipeline.sh` -> commit/push + PR + wait CI + resolve SHA + deploy Helm seguro con autodeteccion
- `scripts/install-providers.sh` -> instala/sincroniza skills, agentes y comandos en OpenCode, Codex, Gemini, Antigravity y Claude Code
- `scripts/validate-skill-tags.py` -> reporte de skills etiquetadas (`op-`, `sec-`, `fe-`, `qa-`) y skills generales sin prefijo
- `scripts/windows/wsl-localhost-bridge.ps1` -> puente localhost Windows -> WSL para callbacks OAuth

## Requisitos

- `opencode`
- `git`
- `node`/`npx`
- `gh` autenticado (GitHub MCP)
- `docker` + `uvx` (Docker MCP)
- `kubectl` (Kubernetes MCP)

## MCPs incluidos

- Notion
- Vercel
- GitHub
- Playwright
- Context7
- Kubernetes
- Docker
- Google Workspace

## Autenticacion MCP

### Notion
```bash
opencode mcp auth notion
```

### Vercel
```bash
opencode mcp auth vercel
```

Si usas WSL y el callback OAuth en Windows falla (`ERR_CONNECTION_REFUSED` en `127.0.0.1:19876`), usa este helper en PowerShell (Administrador):

```powershell
# Habilitar puente para callback OAuth (puerto por defecto 19876)
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.config\opencode\scripts\windows\wsl-localhost-bridge.ps1" -Action enable -EnableFirewall

# Ver estado
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.config\opencode\scripts\windows\wsl-localhost-bridge.ps1" -Action status

# Deshabilitar puente
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.config\opencode\scripts\windows\wsl-localhost-bridge.ps1" -Action disable
```

### GitHub
Este setup usa `Authorization: Bearer {env:GITHUB_MCP_PAT}`.

```bash
export GITHUB_MCP_PAT="$(gh auth token)"
```

### Google Workspace
1) Crear OAuth Desktop en Google Cloud.
2) Guardar `credentials.json` en `~/.config/google-workspace-mcp/credentials.json`.
3) Ejecutar:

```bash
npx -y @presto-ai/google-workspace-mcp@1.0.12
```

### Verificacion
```bash
opencode mcp list
```

## Flujo para crear nuevas skills/agentes (super rapido)

### 1) Evaluar si debe ser Tool / Skill / Agent

Usa:
- `/workflow-evaluator <proceso>`

### 2) Generar blueprint

Usa:
- `/factory <descripcion del workflow>`

### 3) Scaffolding automatico

```bash
./scripts/scaffold.sh skill release-checklist "Checklist de release"
./scripts/scaffold.sh agent qa-orchestrator "QA specialist"
./scripts/scaffold.sh command release-plan "Plan de release"
```

### 4) Validar y sincronizar

```bash
./scripts/doctor.sh
./scripts/sync.sh push "feat: add release workflow skill"
```

## Sincronizacion entre PCs

En PC A (donde editas):
```bash
./scripts/doctor.sh
./scripts/sync.sh push "feat: update baymax workflows"
```

En PC B (donde consumes):
```bash
~/.config/opencode/scripts/bootstrap.sh
```

## Instalacion multi-provider (OpenCode, Codex, Gemini, Antigravity, Claude Code)

Instala/sincroniza assets de este repo en varios proveedores desde un solo comando.

```bash
./scripts/install-providers.sh
```

Por defecto:

- usa `--mode symlink`
- instala en: `~/.config/opencode`, `~/.codex`, `~/.gemini`, `~/.gemini/antigravity`, `~/.claude`
- toma skills/agentes activos desde:
  - `skills/ACTIVE_SKILLS.txt`
  - `agents/ACTIVE_AGENTS.txt`

Ejemplos:

```bash
# Ver rutas destino sin tocar nada
./scripts/install-providers.sh --list

# Solo codex + gemini en modo copia
./scripts/install-providers.sh --providers codex,gemini --mode copy

# Simulacion
./scripts/install-providers.sh --providers antigravity,claudecode --dry-run

# Sobrescribir destinos existentes
./scripts/install-providers.sh --force
```

Overrides por variable de entorno:

- `OPENCODE_HOME`
- `CODEX_HOME`
- `GEMINI_HOME`
- `ANTIGRAVITY_HOME`
- `CLAUDECODE_HOME`

## Comandos slash core (flujo reducido)

- `/plan`
- `/code-review`
- `/security-review`
- `/release-pr`
- `/deploy-pre`
- `/deploy-prod`
- `/sync-release`

## Comandos slash opcionales (planner-routed)

- `/e2e`
- `/tdd`
- `/factory`
- `/workflow-evaluator`
- `/skill-repair`
- `/secretary`

Estos comandos no requieren agentes dedicados; se enrutan al `planner` y usan skills/contexto especializado.

## Taxonomia de skills (tags)

Convencion de carpetas para skills etiquetadas:

- `op-*` -> operacion/configuracion de OpenCode
- `sec-*` -> workflows de secretaria (calendar/gmail/notion)
- `fe-*` -> frontend/UI
- `qa-*` -> testing/calidad

Notas:

- Las skills sin prefijo siguen permitidas como skills generales.

Validacion:

```bash
python3 scripts/validate-skill-tags.py
```

Modo estricto (falla si hay skills sin prefijo):

```bash
python3 scripts/validate-skill-tags.py --strict-untagged
```

El comportamiento de plan profundo, preguntas de aclaracion y decision gates es always-on en `AGENTS.md` y agentes activos.

## Formato de commits y PR

- Guía formal: `docs/commit-pr-format.md`
- Template de PR: `.github/pull_request_template.md`
- `scripts/release-pipeline.sh` valida formato convencional para:
  - commit message
  - título de PR
- `scripts/release-pipeline.sh` usa el template de PR por defecto cuando no envías `--pr-body`.

## Flujo release/deploy automatizado

Pipeline recomendado (pre/prod):

```bash
./scripts/release-pipeline.sh \
  --env pre \
  --commit-message "feat(catalog): improve pricing endpoint" \
  --base-branch main \
  --create-namespace
```

Para producción:

```bash
./scripts/release-pipeline.sh \
  --env prod \
  --commit-message "chore(release): prod deploy catalog" \
  --base-branch main \
  --hash-source base \
  --create-namespace
```

Nota: por defecto `release-pipeline.sh` usa `--hash-source pr` (HEAD del PR).

## Nota de seguridad

No subas secretos al repositorio.

- No commitear `.env`, `credentials.json`, `tokens.json`, keys privadas.
- Mantener secretos en variables de entorno / gestor de secretos.
- `scripts/sync.sh` bloquea patrones sensibles al hacer push.
