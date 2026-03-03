---
name: formant-administrator
description: This skill should be used when users ask to administer Formant organizations and fleets using natural language — operational queries, diagnostics, fleet management, user/team/role admin, telemetry and analytics, command dispatch, event and signal inspection, and general CLI tasks. Route config mutations to formant-config-lifecycle, historical telemetry view design requests to formant-view-configuration, and teleop view design requests to formant-teleop-view-configuration.
version: 0.3.0
---

# Formant Administrator

Default operating behavior for competent Formant CLI administration across all domains.

## Domain Model

Formant manages robot fleets through these core entities:

| Entity | Description |
| --- | --- |
| **Device** | A robot or agent. Has config, streams, tags, state. |
| **Stream** | Named telemetry channel on a device (numeric, image, video, location, etc.). |
| **Event** | System or user-generated occurrence with severity, device association, timestamps. |
| **Signal** | AI-initiated investigation trigger tied to a persona and event. |
| **Investigation** | Taskflow instance spawned from a signal or manually. |
| **Command** | Template-based instruction dispatched to devices. |
| **View** | Dashboard layout with stream configurations. |
| **Teleop View** | Teleoperation-specific view layout. |
| **Module / Module Configuration** | Embedded app component and its settings. |
| **Config Template** | Reusable device configuration document. |
| **Fleet** | Logical device grouping with scope filters. |
| **Event Trigger / Group** | Automated event rules and notification groupings. |
| **Schedule** | Time-based automation for commands or workflows. |
| **Persona** | AI agent identity for signal/investigation workflows. |
| **Channel** | Observability layout with filters. |
| **User / Role / Team** | Identity, permissions, and group management. |
| **Organization** | Top-level tenant with feature flags and integrations. |
| **Annotation Template / Tag Template** | Metadata schemas for events and resources. |

## CLI Mastery Patterns

### Command Discovery

Find available commands and their exact schemas:

```bash
formant schema commands --json                              # all commands
formant schema commands --topic <topic> --json              # one topic
formant schema commands --command "<topic> <command>" --json # one command
```

Topics: `analytics`, `annotation-template`, `channel`, `command`, `config-template`, `device`, `event`, `event-trigger`, `event-trigger-group`, `fleet`, `ingest`, `investigation`, `kv`, `module`, `module-configuration`, `org`, `persona`, `query`, `role`, `schedule`, `signal`, `stream`, `tag-template`, `team`, `teleop-view`, `user`, `view`.

### Output Modes

Three mutually exclusive modes:

| Flag | Mode | Best for |
| --- | --- | --- |
| _(none)_ | Table | Human reading |
| `--json` | JSON | Programmatic use, piping to `jq` |
| `--toon` | TOON | LLM-efficient token format |

Always use `--json` when you need to parse, filter, or pipe output. Use `--toon` when feeding results to another LLM context.

### Common Patterns

```bash
# List with filters
formant device list --tag "env=production" --json
formant event list --device <id> --severity critical --limit 50 --json

# Get detail
formant device get <id> --json
formant user get <id> --json

# Query telemetry
formant query numeric --device <id> --stream <name> --start <iso> --end <iso> --json
formant analytics sql --query "SELECT ..." --json

# Pipe and filter with jq
formant device list --json | jq '[.[] | {id, name, online: .state.online}]'
```

## Approach by Ask Type

### Operational Queries & Diagnostics

Read-only fleet inspection, device health, event triage.

```bash
formant device list --include-offline --with-data --json
formant device get <device-id> --json
formant device streams <device-id> --days 7 --json
formant event list --device <device-id> --severity critical --limit 100 --json
formant command history --device <device-id> --limit 50 --json
```

### Fleet Management

Device grouping, tagging, fleet CRUD.

```bash
formant fleet list --json
formant device list --tag "key=value" --json
```

### User, Team & Role Administration

```bash
formant user list --json
formant user get <id> --json
formant role list --json
formant team list --json
```

### Telemetry & Analytics

```bash
formant query numeric --device <id> --stream <name> --start <iso> --end <iso> --json
formant query text --device <id> --stream <name> --start <iso> --end <iso> --json
formant analytics sql --query "<SQL>" --json
formant stream list --device <id> --json
```

### Command Dispatch

```bash
formant command list --json
formant command issue <device-id> --command <name> --json
formant command issue <device-id> --command <name> --parameter '<json>' --json
```

### Event & Signal Inspection

```bash
formant event list --json
formant signal list --json
formant investigation list --json
```

### Historical View Design Review

For historical telemetry dashboard layout strategy, stream curation, and module usability reviews:

**Route to the `formant-view-configuration` skill.**

### Teleop View Design Review

For teleoperation layout strategy, camera/control composition, and action wiring reviews:

**Route to the `formant-teleop-view-configuration` skill.**

### Config Mutations

For any configuration change to `device-config`, `config-template`, `view`, `teleop-view`, or `module-configuration`:

**Route to the `formant-config-lifecycle` skill.** It provides snapshot/apply/rollback artifact management. Do not manually apply config changes outside that workflow.

## Setup Validation

Use `/check` at session start or when auth/environment state is uncertain. This validates CLI availability, auth status, and org access.

## Safety Rules

- Treat `prod` as the default and highest-risk environment. Use `--stage` intentionally when targeting non-production.
- Never expose credentials or secret values.
- Never fabricate IDs, schemas, or command output. Use `formant schema commands --json` to validate command shapes before execution.
- Always produce rollback-ready artifacts for supported config mutations (via `formant-config-lifecycle`).
- Do not add unknown fields to API payloads unless the schema or live response confirms they are valid.
- Validate command args/flags before execution. If a command shape is ambiguous, resolve via schema first.
