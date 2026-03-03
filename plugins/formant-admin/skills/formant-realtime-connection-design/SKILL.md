---
name: formant-realtime-connection-design
description: This skill should be used when users ask to design, assess, or tune Formant real-time connection behavior for teleoperation and live streams, including telemetry-vs-realtime stream roles, stream wiring, media settings, low-bandwidth behavior, and runtime validation.
version: 0.1.0
---

# Formant Realtime Connection Design

Design and evaluate Formant realtime connection behavior for teleoperation with practical runtime-focused heuristics.

## Scope

Use this skill for:
- telemetry vs realtime stream role decisions
- teleop/realtime stream wiring consistency
- live media tuning (quality/bitrate/adaptive behavior)
- low-bandwidth and high-latency behavior design
- live validation of command/observe stream behavior

Routing rules:
- For teleop UI layout/module placement, use `formant-teleop-view-configuration`.
- For historical telemetry dashboards, use `formant-view-configuration`.
- For device config mutations, use `formant-config-lifecycle`.
- For general operations and diagnostics, use `formant-administrator`.

## Guidance Stance

Treat this as a practical default lens, not a rulebook.

- These are suggestions, not hard requirements.
- Mission profile, network quality, and robot capabilities should drive final decisions.

## Default Workflow

### 1. Confirm realtime mission profile

Classify the primary use case:
- navigation/drive
- manipulation/arm
- observe-only support
- mixed command and monitoring

Then define acceptable latency, image quality floor, and control reliability requirements.

### 2. Gather current realtime truth

```bash
formant device config <device-id> --full --json
formant teleop-view list --full --json
formant teleop-view get <teleop-view-id> --full --json
formant device streams <device-id> --days 7 --json
```

### 3. Build stream role matrix

For each stream, classify whether it should be:
- telemetry-only
- realtime-only
- dual-path (both), with explicit purpose

Use clear naming and labels for operator readability.

### 4. Apply precedence and wiring rules

Practical behavior assumptions:
- when duplicate teleop/realtime stream definitions overlap, realtime definitions should be treated as authoritative
- command streams and observe streams must be explicitly separated in intent
- teleop module stream names must match configured stream names exactly

### 5. Tune media and control channels

Key knobs to tune:
- `quality`
- `bitrate`
- `disableAdaptiveQuality`
- overlay clock usage
- low-bandwidth mode allowances

Keep initial tuning conservative, then adjust after live validation.

### 6. Validate in live session conditions

Static config checks are not enough. Validate while session is active:
- verify command streams actually affect robot behavior
- verify observe streams are timely and usable
- verify fallback behavior under constrained network
- verify session handoff behavior when multiple operators connect

### 6a. Quick technical checks

```bash
# Teleop/realtime stream inventory from device config
formant device config <device-id> --full --json \
  | jq '{
      teleop: {
        ros: ((.config.document.teleop.rosStreams // []) | map({topicName, mode, encodeVideo, quality, bitrate, disableAdaptiveQuality, label})),
        custom: ((.config.document.teleop.customStreams // []) | map({name, rtcStreamType, mode, encodeVideo, quality, bitrate, disableAdaptiveQuality, label})),
        hardware: ((.config.document.teleop.hardwareStreams // []) | map({name, hwDescriptor, rtcStreamType, mode, quality, bitrate, disableAdaptiveQuality, label}))
      },
      realtime: {
        ros: ((.config.document.realtime.rosStreams // []) | map({topicName, mode, encodeVideo, quality, bitrate, disableAdaptiveQuality, label})),
        custom: ((.config.document.realtime.customStreams // []) | map({name, rtcStreamType, mode, encodeVideo, quality, bitrate, disableAdaptiveQuality, label})),
        hardware: ((.config.document.realtime.hardwareStreams // []) | map({name, hwDescriptor, rtcStreamType, mode, quality, bitrate, disableAdaptiveQuality, label}))
      },
      lowBandwidth: (.config.document.teleop.allowLowBandwidthMode // null),
      highPingWarningDisabled: (.config.document.teleop.disableHighPingWarning // null)
    }'

# Teleop view module inventory
formant teleop-view get <teleop-view-id> --full --json \
  | jq '{name,tags,module_count:(.configuration.modules|length),types:(.configuration.modules|map(.type)|group_by(.)|map({type:.[0],count:length}))}'
```

## Practical Defaults

- Explicitly define operator-critical command channels before adding auxiliary streams.
- Prefer stable names and labels over clever naming.
- Treat low-bandwidth mode as a deliberate operational mode, not an afterthought.
- Keep the set of control-critical streams small and well tested.

## Mutation Safety

For realtime/teleop stream changes in device config:
1. Use `formant-config-lifecycle` snapshot/apply workflow.
2. Apply minimal changes.
3. Validate live session behavior before declaring success.
4. Keep rollback artifacts available until validation passes.

## References

- Set up real-time connections: https://docs.formant.io/docs/getting-started-set-up-real-time-connections
- Telemetry vs realtime data streams: https://docs.formant.io/docs/getting-started-telemetry-vs-realtime-data-streams
- Realtime video module: https://docs.formant.io/docs/realtime-video-module
- Video encoding: https://docs.formant.io/docs/video-encoding
