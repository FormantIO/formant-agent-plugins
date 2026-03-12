---
name: formant-device-diagnostics
description: This skill should be used when users ask to diagnose why a Formant device appears offline, has missing or stale telemetry, shows only system streams, is not uploading agent logs, or is not firing stream-based event triggers. Use formant-administrator to execute CLI commands and formant-config-lifecycle for any config mutation.
version: 0.1.0
---

# Formant Device Diagnostics

Diagnose cloud-visible device issues with the Formant CLI before assuming SSH or host access is required.

## Scope

Use this skill for:
- device appears offline or recently dropped offline
- dashboard shows no data or stale data
- only `$.host.*` / `$.agent.*` streams are visible
- agent logs are missing or need inspection
- stream-based event triggers are not firing
- compare-bad-vs-good device diagnosis

Routing rules:
- Use `formant-administrator` to execute CLI commands and return outputs.
- Use `formant-config-lifecycle` for any device/view/module config mutation.
- Do not invent host-level remediations from cloud-only evidence.

## Evidence Discipline

Always separate conclusions into:
- `confirmed`: directly supported by CLI output
- `likely`: strong inference, not directly proven
- `needs host access`: requires SSH or local machine inspection

Do not use `fullyConfigured` as proof that a device has or has not applied config.
When a diagnostic depends on nested JSON fields or raw datapoints, use `--full` with `--json`.

## Default Workflow

### 1. Establish device state and recent timeline

```bash
formant device get <device-id> --full --json
formant event list --device <device-id> --type device-offline --limit 50 --json
formant event list --device <device-id> --type device-online --limit 50 --json
```

Check:
- `enabled`
- `state.agentVersion`
- `desiredConfigurationVersion`
- `state.reportedConfiguration.version`
- `state.hwInfo.nodeInfo`
- `state.hwInfo.networkInfo`
- `state.onDemand.buffers`

Interpretation:
- `enabled=false` is an administrative disable state
- `desiredConfigurationVersion != state.reportedConfiguration.version` means the device has not reported the desired config version yet
- offline/online events help anchor the last cloud-visible transition, but absence of those events does not prove health

### 2. Check stream inventory and freshness

```bash
formant device streams <device-id> --days 7 --json
formant query --device <device-id> --all-streams --latest-values-only --start <iso> --end <iso> --json
```

Classify streams as:
- configured and fresh
- configured but with no data
- present but stale
- discovered from data only

Heuristics:
- only `$.host.*` / `$.agent.*` streams usually means the agent is alive but application telemetry is missing, disabled, or not configured
- no fresh streams at all usually means the device is not successfully uploading
- configured streams with no data usually means the config exists but the publisher, adapter, or upstream process is not producing data
- streams discovered from data but missing from config usually mean the device has ingested data outside the current config snapshot; compare carefully before concluding drift

### 3. Check whether agent logs should exist

Inspect config first:

```bash
formant device config <device-id> --json
```

Then query logs:

```bash
formant query --device <device-id> --stream '$.agent.logs' --type text --start <iso> --end <iso> --full --json
```

Interpretation:
- `config.document.diagnostics.reportLogs=true` means the agent is configured to upload logs
- `config.document.diagnostics.ingestLogs=true` means uploaded logs should be ingested into queryable telemetry
- empty `$.agent.logs` results are expected if either gate is off
- absence of `$.agent.logs` does not prove logs do not exist locally on the machine

### 4. Inspect config shape and drift

From `formant device config <device-id> --json`, inspect:
- `config.document.telemetry.streams`
- `config.document.resources.streamThrottleHz`
- `config.document.diagnostics`
- `config.document.adapters`
- `config.document.teleop`
- `config.document.realtime`

Interpretation:
- application telemetry stream definitions live under `config.document.telemetry.streams`
- empty or missing `config.document.telemetry.streams` means application telemetry is not configured in this device config
- very low `streamThrottleHz` can make data look sparse or stale
- adapters present with missing streams often points to an adapter/process-side issue, not necessarily a cloud ingestion issue

### 5. If events are not firing, validate trigger-to-stream fit

```bash
formant event-trigger list --json
formant event-trigger get <trigger-id> --full --json
formant event list --device <device-id> --type datapoint-event --limit 100 --json
```

For datapoint-event triggers, verify:
- the trigger is enabled
- `condition.stream` matches a stream the device is actually sending
- `deviceScope` includes the affected device
- recent stream data exists in the relevant time window

Nuance:
- `formant event-trigger list --json` returns enabled triggers only
- if you are investigating a known trigger by ID, inspect it directly with `formant event-trigger get <trigger-id> --full --json`
- not all trigger failures are stream failures; event-predicate triggers need different diagnosis

### 6. Compare against a known-good device when needed

Repeat steps 1-5 for a working device in the same org.

Compare:
- agent version
- desired vs reported config version
- stream inventory and freshness
- diagnostics log settings
- adapter presence
- trigger scope assumptions

## Useful Log Signals

Use `formant query --device <device-id> --stream '$.agent.logs' --type text --start <iso> --end <iso> --full --json` and interpret signals cautiously.

Common patterns:
- repeated `Calling AuthApi. Connection error` strongly suggests device-to-cloud connectivity problems
- repeated `Calling DeviceApi:DeviceControllerGetUpdatedConfiguration. Connection error` confirms config polling is failing and usually points to the same connectivity class
- `error getting default route interface: no default route found` is direct evidence of a local routing problem
- `listening for ROS Bridge gRPC on: ...` confirms the ROS bridge socket was started, but does not by itself prove the overall deployment shape or cloud connectivity

For a compact reference of log signatures and how strongly to interpret them, read [`references/device-diagnostic-signatures.md`](references/device-diagnostic-signatures.md).

## Output Contract

End every diagnosis with:
- `confirmed findings`
- `likely findings`
- `recommended next checks`
- `requires host access: yes/no`
