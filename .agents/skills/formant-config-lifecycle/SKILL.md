---
name: formant-config-lifecycle
description: This skill should be used when users ask to change Formant configurations (device config, config templates, views, teleop views, or module configurations), especially for nested JSON updates, schema-sensitive edits, save-edit-push flows, and rollback-safe operations.
version: 0.1.0
---

# Formant Config Lifecycle

Execute configuration changes with deterministic artifact capture and rollback readiness.

## Scope

Supported entities:
- `device-config`
- `config-template`
- `view`
- `teleop-view`
- `module-configuration`

## Script Path Conventions

Use the lifecycle script in this skill directory (`formant-config-lifecycle/scripts/config-lifecycle.sh`).

Typical locations by runtime:
- Cowork/Claude plugin: `${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh`
- Claude standalone skill: `<workspace>/.claude/skills/formant-config-lifecycle/scripts/config-lifecycle.sh` or `~/.claude/skills/...`
- Codex skill: `<workspace>/.codex/skills/formant-config-lifecycle/scripts/config-lifecycle.sh` or `~/.codex/skills/...`
- Gemini skill: `<workspace>/.gemini/skills/formant-config-lifecycle/scripts/config-lifecycle.sh` or `~/.gemini/skills/...`

## Required Lifecycle

1. Resolve context.
- Confirm target entity and ID.
- Confirm environment (`prod`, `stage`, `dev`).
- Validate access with `/check` (or equivalent auth/org checks).

2. Snapshot current state first.
- Run lifecycle script in snapshot mode:
```bash
<lifecycle-script> \
  --entity <entity> --id <id> --env <prod|stage|dev>
```

3. Prepare updated JSON.
- Start from the snapshot artifact (`before.json`).
- Edit with schema awareness from the schema skills.
- Use `jq` for targeted nested edits when possible.

4. Apply change and capture full artifact bundle.
- Run lifecycle script with `--updated`:
```bash
<lifecycle-script> \
  --entity <entity> --id <id> --env <prod|stage|dev> --updated <path/to/updated.json>
```

5. Report outcome.
- Artifact bundle path.
- Diff summary (`changes.diff`).
- Key post-change fields from `after.live.json`.

## Behavior Rules

- Do not require proposal/approval gates in this workflow.
- Always create rollback-ready artifacts before and after changes.
- Prefer minimal edits over broad object rewrites.
- If schema mismatch or API rejection occurs, stop and use `rollback.sh` from the artifact bundle.

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
- Entity schemas: `../formant-cli-schemas/references/config-entity-schemas.md`
- Examples: `references/lifecycle-examples.md`
