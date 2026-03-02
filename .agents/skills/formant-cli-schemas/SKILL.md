---
name: formant-cli-schemas
description: This skill should be used when users ask what Formant CLI commands exist, what arguments/flags a command accepts, or how to structure tool calls across command areas. Use for schema-first command validation and command discovery.
version: 0.1.0
---

# Formant CLI Schemas

Use this skill to answer command-shape questions precisely.

## Primary References

- `references/config-entity-schemas.md`
- `references/deep-config-hierarchies.md`

## Workflow

1. Identify the requested command area (device, view, config-template, etc.).
2. Read command schemas directly from CLI:
```bash
formant schema commands --json
formant schema commands --topic <topic> --json
formant schema commands --command "<topic> <command>" --json
```
3. Validate required args, flag types, and mutually-exclusive flags.
4. If the command edits nested config, cross-check with `deep-config-hierarchies.md`.
5. Return the exact command form and a minimal, valid example.

## Rules

- Prefer exact command schema over inferred usage.
- Highlight required positional args and required flags first.
- Mention `--dev` / `--stage` explicitly when environment choice matters.
- For mutating commands, route execution through `formant-config-lifecycle` when supported.
