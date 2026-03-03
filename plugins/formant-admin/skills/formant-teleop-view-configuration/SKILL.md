---
name: formant-teleop-view-configuration
description: This skill should be used when users ask to design, assess, or improve Formant teleoperation views, including camera layout, joystick/control modules, command/action wiring, and operator usability. Guidance is heuristic, not hard rules. Use with formant-config-lifecycle when applying teleop-view changes.
version: 0.1.0
---

# Formant Teleop View Configuration

Design and evaluate Formant teleoperation views with practical operator-focused heuristics.

## Scope

Use this skill for:
- teleop view quality reviews
- camera and map composition for operator context
- joystick/button/command module design
- control placement and ergonomics
- stream/control wiring validation against device teleop config

Routing rules:
- For teleop-view mutations, use `formant-config-lifecycle` for snapshot/apply/rollback.
- For historical telemetry dashboard design, use `formant-view-configuration`.
- For non-view operational administration, use `formant-administrator`.

## Guidance Stance

Treat this skill as a default lens, not a rulebook.

- These are suggestions, not hard requirements.
- This reflects one experienced operator/support perspective and common team patterns.
- Multiple teleop archetypes are valid (minimal controls, camera walls, command-heavy, mapping-heavy).
- Prioritize mission and robot behavior over defaults.

## Default Workflow

### 1. Confirm teleop intent

Classify the teleop scenario first:
- driving/navigation focused
- manipulation/arm focused
- command-assisted operation
- training/supervised support

### 2. Gather teleop truth sources

```bash
formant teleop-view get <teleop-view-id> --full --json
formant teleop-view list --full --json
formant device config <device-id> --full --json
formant device streams <device-id> --days 30 --json
```

Also verify available command templates if command modules are used:

```bash
formant command list --json
```

Prerequisite reminder:
- teleop modules are powered by real-time connections; if connections are missing, modules may render but will not function.

### 3. Validate view-to-device targeting

Check teleop view tags and binding consistency:
- `tags.deviceId` should match the intended device when the view is device-specific
- tag strategy should match org conventions (for example, device-specific vs type-based binding)

### 4. Validate core teleop composition

Default composition that often works:
- one large background video (primary operator feed)
- additional camera modules when they add operational context
- one joystick minimum; two joysticks when robot behavior supports it
- action buttons for high-value robot actions
- optional command module for broader task execution

If a second joystick is unstable or confusing for this robot, keep one joystick.

### 4a. Technical teleop layout baseline

Use this as a practical starting template, then adapt:
- large background video module as primary operator context
- one secondary video in upper side region when available
- primary control cluster in lower corners
  - joystick + high-frequency actions near one lower corner
  - command/readout/support modules near the opposite lower corner
- keep mission-critical actions on-screen as direct buttons

This pattern is a default that has worked well in practice, not a required structure.

### 5. Validate control placement ergonomics

Common ergonomic pattern:
- place main controls near bottom left/right
- keep frequently used action buttons close to joystick area
- keep low-priority/support modules away from primary control zones

Technical control patterns that have worked well:
- joystick axes:
  - drive: `vertical-axis=linear-x`, `horizontal-axis=angular-z`
  - keyboard defaults can use arrow keys for drive
- button rows for core robot actions:
  - commonly `Sit`, `Stand`, `Dock`, `Walk`, `Crawl`, `Stairs`, `Recover`
- include a command module filtered to a robot namespace (for example `Spot: `) for less-frequent actions

Control semantics to verify:
- button modules are momentary (`true` while held, `false` on release)
- latching buttons toggle persistent `true/false` state
- text input sends only on Enter and then clears

### 6. Validate wiring against device teleop config

Cross-check module references with:
- `teleop.views[*].streamName`
- `teleop.hardwareStreams[*].name`
- `teleop.customStreams[*]` command labels

Classify mismatches:
- `intentional`: view intentionally differs for future or alternative setup
- `stale`: old stream/control names no longer used
- `invalid`: wiring that will likely fail at runtime

Critical sync checks:
- teleop view binding:
  - if intended to be device-specific, ensure `tags.deviceId == <target-device-id>`
- camera wiring:
  - view video stream names should match currently configured teleop streams
- button wiring:
  - on-screen button labels/dataStream values should align with `teleop.customStreams[*].labels`
  - flag extras/missing entries explicitly (for example extra emergency action or missing reset action)
- session behavior:
  - validate controls while a teleop session is active and unlocked, not from static configuration inspection alone

### 6a. Quick technical checks

```bash
# Teleop module inventory
formant teleop-view get <teleop-view-id> --full --json \
  | jq '{name,tags,module_count:(.configuration.modules|length),
         types:((.configuration.modules|map(.type))|group_by(.)|map({type:.[0],count:length}))}'

# Device teleop stream/control definitions
formant device config <device-id> --full --json \
  | jq '{views:(.config.document.teleop.views // []),
         hardware:(.config.document.teleop.hardwareStreams // []),
         custom:(.config.document.teleop.customStreams // [])}'
```

### 7. Produce recommendations

Report in this order:
1. inferred teleop use case
2. what is working well already
3. control/camera wiring mismatches and impact
4. concrete module changes with operator value
5. optional simplifications

## Practical Defaults

- Prefer clear labels over internal naming consistency.
- Include mission-critical actions directly as buttons.
- Use color emphasis for high-risk actions (for example, stop/recover) when available.
- Add modules incrementally from real robot capabilities instead of generic templates.
- Validate streams and controls live when possible; telemetry presence alone may not prove teleop viability.

## Mutation Safety

When asked to change a teleop view:
1. snapshot current teleop view with `formant-config-lifecycle`
2. apply minimal edits
3. verify module placement and stream/control wiring
4. report rollback artifact path and diff summary

## References

- Build a teleoperation interface: https://docs.formant.io/docs/getting-started-build-a-teleoperation-interface
- Set up real-time connections: https://docs.formant.io/docs/getting-started-set-up-real-time-connections
- Teleoperate a device: https://docs.formant.io/docs/getting-started-teleoperate-a-device
- Teleoperation overview: https://docs.formant.io/docs/getting-started-teleoperation
