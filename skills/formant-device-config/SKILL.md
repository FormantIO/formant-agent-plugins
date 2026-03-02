---
name: formant-device-config
description: This skill should be used when users ask to inspect or modify device configurations, stream settings, realtime/teleop config, or config templates in Formant. Trigger phrases include "update device config", "fix stream configuration", "apply template", and "edit robot configuration".
version: 0.1.0
---

# Formant Device Config

Operate on device-centric configuration safely and with schema awareness.

## Command Areas

- `formant device config`
- `formant device apply-config`
- `formant config-template get|update|apply`
- `formant device validate-stream-config`

## Schema References

- `formant schema commands --json`
- `../formant-cli-schemas/references/config-entity-schemas.md`
- `../formant-cli-schemas/references/deep-config-hierarchies.md`
- `references/command-matrix.md`

## Execution Pattern

1. Read current state first (`device config` or `config-template get`).
2. Edit JSON with minimal field changes.
3. Apply via `formant-config-lifecycle` to guarantee rollback artifacts.
4. Verify with a fresh read and inspect diffs.

## Focus Areas

- `IDeviceConfigurationDocument` and nested telemetry/teleop/realtime structures.
- `IDeviceStreamConfiguration` correctness for stream name/type/config.
- `IDeviceConfigurationTemplate` reuse across fleets.
