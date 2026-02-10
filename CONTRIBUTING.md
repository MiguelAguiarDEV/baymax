# Contributing Guide

Este repo define la configuracion global de OpenCode para Baymax.

## Flujo recomendado

1) Crear o actualizar componentes (`skills/`, `agents/`, `commands/`, `modes/`).
2) Ejecutar validaciones:

```bash
./scripts/doctor.sh
```

3) Sincronizar:

```bash
./scripts/sync.sh push "type: short message"
```

## Convenciones

- Nombres en `kebab-case`.
- Mantener front matter valido.
- Mantener side effects bajo confirmacion.
- No guardar secretos.

## Tipos de cambio sugeridos

- `feat:` nuevo skill/agent/command/mode
- `fix:` correcciones de comportamiento
- `docs:` documentacion
- `chore:` mantenimiento interno

## Plantillas rapidas

```bash
./scripts/scaffold.sh skill <name> "<description>"
./scripts/scaffold.sh agent <name> "<description>"
./scripts/scaffold.sh command <name> "<description>"
./scripts/scaffold.sh mode <name> "<description>"
```
