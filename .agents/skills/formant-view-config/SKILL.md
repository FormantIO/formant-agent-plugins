---
name: formant-view-config
description: This skill should be used when users ask to inspect or modify Formant views, teleop views, modules, or module configurations. Trigger phrases include "edit dashboard view", "change module config", "update teleop view", and "fix layout configuration".
version: 0.1.0
---

# Formant View Config

Operate on view/layout/module configuration with schema-first checks.

## Command Areas

- `formant view get|update|reorder`
- `formant teleop-view get|update`
- `formant module get|update`
- `formant module-configuration get|update`

## Schema References

- `formant schema commands --json`
- `../formant-cli-schemas/references/config-entity-schemas.md`
- `../formant-cli-schemas/references/deep-config-hierarchies.md`
- `references/command-matrix.md`

## Execution Pattern

1. Read current object (`get`).
2. Edit only target fields (`name`, `layout`, `configuration`, module settings).
3. Apply through `formant-config-lifecycle` for rollback artifacts.
4. Re-read and summarize changed keys.

## Focus Areas

- `IView`, `IViewConfiguration`, and `IViewConfigurationMap`.
- `IModule` and `IModuleConfiguration`.
- Teleop stream/view settings carried in device teleop config when relevant.
