# Hook Compatibility Rules (OpenCode)

OpenCode no ejecuta hooks de Claude Code. Estas reglas traducen el comportamiento esperado a instrucciones manuales.

## Bash / dev servers
- NO ejecutar dev servers fuera de tmux. Usa:
  - tmux new-session -d -s dev 'npm run dev'
  - tmux attach -t dev
- Para comandos largos (npm/pnpm/yarn/bun install/test, cargo build, make, docker, pytest, vitest, playwright), preferir tmux para mantener logs.

## Git push
- Antes de `git push`, revisar cambios localmente (diff/log) y confirmar manualmente.
- Excepcion: el hook de memoria puede auto-pushear `config/opencode/memory.json`.

## Documentacion
- Evitar crear archivos .md/.txt nuevos salvo README.md, CLAUDE.md, AGENTS.md o CONTRIBUTING.md.
- Excepcion: archivos de reglas en `config/opencode/rules/*.md`.

## Post-edit checks (manuales)
- Despues de editar .ts/.tsx/.js/.jsx:
  - Ejecutar Prettier si existe.
  - Ejecutar `npx tsc --noEmit` si hay tsconfig.
  - Verificar que no queden `console.log`.

## Session end
- Antes de finalizar la sesion, buscar `console.log` en archivos modificados y eliminarlos.
- Ejecutar `/learn` si hay patrones reutilizables.
