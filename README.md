# Baymax OpenCode Configuration

Sistema portable de OpenCode para Baymax: instalacion rapida, orquestacion de agentes, skills versionados y sincronizacion multi-PC.

## Que incluye

- `AGENTS.md` con gobernanza global
- `opencode.json` con agente por defecto, permisos y MCPs
- agentes personalizados (`agents/`)
- comandos slash (`commands/`)
- skills operativos (`skills/`)
- modos (`modes/`)
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

## Modes

`modes/` se mantiene como capacidad opcional/manual de sesion.
No forma parte del flujo core de comandos slash.

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
