---
name: formant-administrator
description: This skill should be used when users ask to administer Formant organizations and fleets using natural language — operational queries, fleet management, user/team/role admin, telemetry and analytics, command dispatch, event and signal inspection, and general CLI tasks. Route device offline, missing telemetry, missing log upload, and stream-trigger diagnosis to formant-device-diagnostics; persona chat sessions to formant-persona-chat; config mutations to formant-config-lifecycle; historical telemetry view design to formant-view-configuration; teleop view design to formant-teleop-view-configuration; event automation design to formant-event-automation; realtime connection design to formant-realtime-connection-design; task summary analytics to formant-task-summary-analytics; and stream tuning to formant-stream-tuning.
version: 0.5.0
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
formant query --device <id> --stream <name> --type numeric --start <iso> --end <iso> --json
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

For deeper diagnosis of device offline behavior, missing telemetry, missing agent logs, or stream-based event trigger failures:

**Route to the `formant-device-diagnostics` skill.**

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
formant query --device <id> --stream <name> --type numeric --start <iso> --end <iso> --json
formant query --device <id> --stream <name> --type text --start <iso> --end <iso> --json
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

### Persona Chat Sessions

For direct user chat with a specific persona in Theopolis (persona selection, thread continuity, sync/async turns, polling, history):

**Route to the `formant-persona-chat` skill.**

### Event Automation Design Review

For event trigger/group design, stateful trigger semantics, notification/action policy, and alert-noise tuning:

**Route to the `formant-event-automation` skill.**

### Realtime Connection Design

For telemetry-vs-realtime stream role decisions, live stream wiring, media tuning, and low-bandwidth behavior:

**Route to the `formant-realtime-connection-design` skill.**

### Task Summary Analytics

For task-summary reporting strategy, KPI query patterns, and task-summary data quality checks:

**Route to the `formant-task-summary-analytics` skill.**

### Stream Tuning

For telemetry rates, video quality/bitrate, adaptive quality behavior, and on-demand stream strategy:

**Route to the `formant-stream-tuning` skill.**

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

## Documentation Links

- Views and modules: https://docs.formant.io/docs/getting-started-views-and-modules
- Create a view and add modules: https://docs.formant.io/docs/getting-started-create-a-view-and-add-modules
- Teleoperation overview: https://docs.formant.io/docs/getting-started-teleoperation
- Teleoperate a device: https://docs.formant.io/docs/getting-started-teleoperate-a-device
- Build a teleoperation interface: https://docs.formant.io/docs/getting-started-build-a-teleoperation-interface
- Set up real-time connections: https://docs.formant.io/docs/getting-started-set-up-real-time-connections
- Telemetry vs realtime data streams: https://docs.formant.io/docs/getting-started-telemetry-vs-realtime-data-streams
- Create an event and configure notifications: https://docs.formant.io/docs/getting-started-create-an-event-and-configure-notifications
- Create a custom event: https://docs.formant.io/docs/getting-started-create-a-custom-event
- Trigger webhooks from events: https://docs.formant.io/docs/trigger-webhooks-from-events
- Query events in analytics: https://docs.formant.io/docs/query-events-in-analytics
- Task summaries: https://docs.formant.io/docs/task-summaries
- Create a task summary: https://docs.formant.io/docs/create-a-task-summary
- Add a video stream: https://docs.formant.io/docs/getting-started-add-a-video-stream
- Video encoding: https://docs.formant.io/docs/video-encoding

## Safety Rules

- Treat `prod` as the default and highest-risk environment. Use `--stage` intentionally when targeting non-production.
- Never expose credentials or secret values.
- Never fabricate IDs, schemas, or command output. Use `formant schema commands --json` to validate command shapes before execution.
- Always produce rollback-ready artifacts for supported config mutations (via `formant-config-lifecycle`).
- Do not add unknown fields to API payloads unless the schema or live response confirms they are valid.
- Validate command args/flags before execution. If a command shape is ambiguous, resolve via schema first.
