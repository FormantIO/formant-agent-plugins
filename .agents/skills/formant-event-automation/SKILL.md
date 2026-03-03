---
name: formant-event-automation
description: This skill should be used when users ask to design, assess, or tune Formant event automation (event triggers and event trigger groups), including trigger semantics, scope filters, severity/message policy, notification/command/workflow actions, and alert-noise reduction. Use formant-administrator to execute CLI operations.
version: 0.1.0
---

# Formant Event Automation

Design and evaluate Formant event automation with practical, low-noise operational defaults.

## Scope

Use this skill for:
- event trigger design and review
- stateful trigger behavior and resolve semantics
- severity/message/notification policy
- command/workflow forwarding from triggers
- event trigger group strategy and on-call noise reduction

Routing rules:
- Use `formant-administrator` to run CLI commands and produce outputs.
- Use `formant-config-lifecycle` only when the requested change is inside device/view/module config documents.
- For realtime stream wiring and teleop transport behavior, use `formant-realtime-connection-design`.

## Guidance Stance

Treat this as a practical default lens, not a rulebook.

- These are suggestions, not hard requirements.
- Different teams need different alerting sensitivity and escalation policy.
- Optimize for actionable alerts with clear ownership and low false-positive rates.

## Default Workflow

### 1. Confirm outcome and owner

Before changing triggers, define:
- what operator action should happen when this fires
- who owns response
- acceptable detection delay and acceptable false positives

### 2. Gather current automation state

```bash
formant event-trigger list --json
formant event-trigger-group list --json
formant event list --limit 200 --json
```

For detailed edits, fetch the exact trigger/group document:

```bash
formant event-trigger get <trigger-id> --json
formant event-trigger-group get <group-id> --json
```

### 3. Classify trigger intent

For each trigger, classify as:
- `datapoint condition`: stream-driven detection (threshold/bitset/regex/json/battery/numeric set/presence)
- `event predicate`: matching on existing event stream
- `stateful`: enter/leave state lifecycle instead of one-shot alerts

Prefer stateful triggers when operators care about both onset and resolution.

### 4. Set semantics deliberately

Key decisions:
- event type and condition/predicate pairing
- interval (throttle window) and expected detection latency
- severity and message format
- `notificationEnabled` and forwarding behavior
- command/workflow fanout only when actions are deterministic and safe

Practical defaults:
- use explicit `exitCondition` for stateful triggers when possible
- keep interval conservative first, then tighten only if needed
- keep command/workflow fanout small and easy to audit

### 5. Scope to the right devices

Validate matching scope with both:
- trigger tags
- `deviceScope` filter

If the scope strategy is type-based, confirm tags are consistently maintained across the fleet.

### 6. Check signal quality against recent history

Use recent events and relevant streams to estimate noise and misses:

```bash
formant event list --type <event-type> --start <iso> --end <iso> --limit 500 --json
formant query --device <device-id> --stream <stream-name> --start <iso> --end <iso> --json
```

Look for:
- repeated alerts with no operator action
- thresholds that trigger on nominal operating ranges
- missing resolves for stateful conditions

### 6a. Quick technical checks

```bash
# Trigger inventory summary
formant event-trigger list --json \
  | jq '[.[] | {
      id,
      eventType,
      enabled,
      isStateful,
      interval,
      severity,
      notificationEnabled,
      hasCondition:(.condition != null),
      hasExitCondition:(.exitCondition != null),
      commandCount:(.commands // [] | length),
      workflowCount:(.workflows // [] | length)
    }]'

# Group inventory summary
formant event-trigger-group list --json \
  | jq '[.[] | {
      id,
      enabled,
      deviceScope,
      phoneNumbers,
      smsTags,
      triggerCount:(.eventTriggers // [] | length)
    }]'
```

## Operational Defaults

- Prefer fewer, high-confidence triggers over broad “catch-all” rules.
- Write messages for operator action, not for engineering internals.
- Keep severity aligned to required response urgency.
- Treat wildcard stream matching as high-risk for noise unless justified.

## Mutation Safety

Use explicit before/after snapshots for trigger edits:

```bash
formant event-trigger get <trigger-id> --json > before.trigger.json
# edit into updated.trigger.json
formant event-trigger update <trigger-id> --file updated.trigger.json
formant event-trigger get <trigger-id> --json > after.trigger.json
```

For groups, apply the same pattern with `event-trigger-group` commands.

## References

- Create an event and configure notifications: https://docs.formant.io/docs/getting-started-create-an-event-and-configure-notifications
- Create a custom event: https://docs.formant.io/docs/getting-started-create-a-custom-event
- Trigger webhooks from events: https://docs.formant.io/docs/trigger-webhooks-from-events
- Query events in analytics: https://docs.formant.io/docs/query-events-in-analytics
