---
name: formant-config-lifecycle
description: This skill should be used when users ask to change Formant configurations (device config, config templates, views, teleop views, or module configurations). Provides snapshot/edit/apply workflows with rollback-safe artifact capture, schema-aware editing, and deterministic lifecycle management.
version: 0.2.0
---

# Formant Config Lifecycle

Execute configuration changes with deterministic artifact capture and rollback readiness.

## Supported Entities

| Entity | Read Command | Apply Command |
| --- | --- | --- |
| `device-config` | `formant device config <id> --json` | `formant device apply-config <id> --file <json>` |
| `config-template` | `formant config-template get <id> --json` | `formant config-template update <id> --file <json>` |
| `view` | `formant view get <id> --json` | `formant view update <id> --file <json>` |
| `teleop-view` | `formant teleop-view get <id> --json` | `formant teleop-view update <id> --file <json>` |
| `module-configuration` | `formant module-configuration get <id> --json` | `formant module-configuration update <id> --file <json>` |

Additional read-only commands:
- `formant device validate-stream-config --file <json>` — validate stream config shape.
- `formant config-template apply <template-id> ...` — apply template to devices.
- `formant view reorder --file <json>` — reorder views.

## Script Path Conventions

Use the lifecycle script in this skill directory (`formant-config-lifecycle/scripts/config-lifecycle.sh`).

Typical locations by runtime:
- Cowork/Claude plugin: `${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh`
- Claude standalone skill: `<workspace>/.claude/skills/formant-config-lifecycle/scripts/config-lifecycle.sh` or `~/.claude/skills/...`
- Codex skill: `<workspace>/.codex/skills/formant-config-lifecycle/scripts/config-lifecycle.sh` or `~/.codex/skills/...`
- Gemini skill: `<workspace>/.gemini/skills/formant-config-lifecycle/scripts/config-lifecycle.sh` or `~/.gemini/skills/...`

## Required Lifecycle

### 1. Resolve context

- Confirm target entity and ID.
- Confirm environment (`prod` or `stage`).
- Validate access with `/check` (or equivalent auth/org checks).

### 2. Snapshot current state

Run the lifecycle script in snapshot mode:

```bash
<lifecycle-script> \
  --entity <entity> --id <id> --env <prod|stage>
```

### 3. Prepare updated JSON

- Start from the snapshot artifact (`before.json`).
- Edit with schema awareness — see `references/config-entity-schemas.md` for top-level field shapes.
- For deeply nested structures, inspect the live `before.json` to understand the current shape rather than guessing.
- Use `jq` for targeted nested edits when possible.

### 4. Apply change and capture artifacts

Run the lifecycle script with `--updated`:

```bash
<lifecycle-script> \
  --entity <entity> --id <id> --env <prod|stage> --updated <path/to/updated.json>
```

### 5. Report outcome

- Artifact bundle path.
- Diff summary (`changes.diff`).
- Key post-change fields from `after.live.json`.

## Device Config Domain

The device configuration document (`IDeviceConfigurationDocument`) has these top-level sections:

- `tags` — key-value metadata.
- `resources` — resource allocation settings.
- `telemetry` — stream definitions (`streams[]` with name, type, throttle, validation, transform).
- `realtime` — realtime stream mappings.
- `teleop` — teleoperation settings (joysticks, arm switch, ros/custom/hardware streams, bandwidth and ping warnings).
- `application` — application-level settings.
- `portForwarding` — port forwarding rules.
- `terminalAccess` — SSH access toggle.
- `diagnostics` — diagnostics configuration.
- `adapters` — adapter configurations.

Config templates (`IDeviceConfigurationTemplate`) wrap a full document with `name`, `document`, and `enabled`.

### Stream Configuration

Each stream in `telemetry.streams[]` has: `name`, `configuration` (type-specific), `tags`, `throttleHz`, `disabled`, `onDemand`, `validation`, `transform`, `quality`.

## View & Module Domain

### Views (`IView`)

Top-level fields: `name`, `description`, `filter`, `deviceFilter`, `groupFilter`, `layout`, `layoutType`, `configuration[]`, `index`, `showOnSingleDevice`, `showOnMultiDevice`, `showOnTeleop`, `showTimeline`, `localModeEnabled`.

Each `configuration` entry has `streamName` and `type` with type-specific settings (bitset, image, location, numeric, localization, point cloud, transform tree).

### Modules (`IModule`)

Fields: `name`, `url`, `description`, `configurationSchemaUrl`, `defaultConfigurationId`, `fullscreen`, `isEmbedded`.

### Module Configurations (`IModuleConfiguration`)

Contains a `configuration` string field (typically JSON-encoded settings).

## Behavior Rules

- Do not require proposal/approval gates in this workflow.
- Always create rollback-ready artifacts before and after changes.
- Prefer minimal edits over broad object rewrites.
- If schema mismatch or API rejection occurs, stop and use `rollback.sh` from the artifact bundle.
- Do not add unknown fields to payloads unless the schema reference or live API response indicates they are valid.

## Artifact Contract

Each run creates `.formant-admin-artifacts/<timestamp>-<entity>-<id>/` with:
- `before.json`
- `before.normalized.json`
- `rollback.sh`

Apply-mode adds:
- `after.request.json`
- `apply-result.json`
- `after.live.json`
- `after.normalized.json`
- `changes.diff`

## References

- CLI command schemas: `formant schema commands --json`
- Entity schemas: `references/config-entity-schemas.md`
- Workflow examples: `references/lifecycle-examples.md`
