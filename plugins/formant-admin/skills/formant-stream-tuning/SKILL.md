---
name: formant-stream-tuning
description: This skill should be used when users ask to tune Formant stream behavior for reliability, bandwidth, and operator usability, including telemetry rate controls, on-demand strategy, video quality/bitrate tuning, and teleop/realtime stream performance tradeoffs.
version: 0.1.0
---

# Formant Stream Tuning

Tune Formant stream configuration for reliability, bandwidth, and operator usability.

## Scope

Use this skill for:
- telemetry stream rate and enablement tuning
- on-demand stream strategy
- video quality and bitrate tuning
- adaptive quality and low-bandwidth behavior decisions
- stream inventory cleanup and stale stream reduction

Routing rules:
- For teleop interface layout and control UX, use `formant-teleop-view-configuration`.
- For realtime connection architecture and mode design, use `formant-realtime-connection-design`.
- For config document mutations, use `formant-config-lifecycle`.

## Guidance Stance

Treat this as a practical default lens, not a rulebook.

- These are suggestions, not hard requirements.
- Optimal tuning depends on hardware limits, network conditions, and mission objectives.

## Default Workflow

### 1. Classify stream criticality

For each stream, classify as:
- mission-critical control/awareness
- operator-supporting
- diagnostics-only
- currently unused

### 2. Baseline stream reality

```bash
formant device streams <device-id> --days 30 --json
formant device streams <device-id> --days 30 --with-data --json
formant device config <device-id> --full --json
```

### 3. Pick the correct tuning knob

Common knobs by need:
- reduce telemetry volume: `throttleHz`
- disable unused stream definitions: `disabled`
- move heavy data to pull-based retrieval: `onDemand`
- tune visual quality/bandwidth: `quality`, `bitrate`, `disableAdaptiveQuality`
- control image-to-video transform behavior: stream `transform` settings

### 4. Tune video and realtime streams deliberately

Practical defaults:
- avoid max quality by default on constrained links
- set explicit bitrate for operator-critical feeds
- use adaptive quality unless deterministic fixed quality is required
- validate low-bandwidth mode behavior for degraded network conditions

### 5. Validate effects in production-like usage

After each change set, validate:
- operator usability (latency + readability)
- stream freshness and drop behavior
- bandwidth pressure and CPU/GPU pressure
- whether hidden dependencies were broken

### 5a. Quick technical checks

```bash
# Telemetry stream knobs
formant device config <device-id> --full --json \
  | jq '(.config.document.telemetry.streams // [])
        | map({name, throttleHz, disabled, onDemand, quality, transform, configuration})'

# Realtime/teleop video-related knobs
formant device config <device-id> --full --json \
  | jq '{
      teleopCustom: ((.config.document.teleop.customStreams // []) | map({name, rtcStreamType, quality, bitrate, disableAdaptiveQuality, encodeVideo})),
      teleopHardware: ((.config.document.teleop.hardwareStreams // []) | map({name, hwDescriptor, rtcStreamType, quality, bitrate, disableAdaptiveQuality})),
      realtimeCustom: ((.config.document.realtime.customStreams // []) | map({name, rtcStreamType, quality, bitrate, disableAdaptiveQuality, encodeVideo})),
      realtimeHardware: ((.config.document.realtime.hardwareStreams // []) | map({name, hwDescriptor, rtcStreamType, quality, bitrate, disableAdaptiveQuality}))
    }'
```

## Practical Defaults

- Set explicit rates for critical telemetry streams; avoid implicit defaults.
- Treat `throttleHz=0` as effectively off for telemetry behavior.
- Keep only streams with clear operator or diagnostic value.
- Tune in small increments and measure before/after impact.

## Mutation Safety

Use `formant-config-lifecycle` for stream tuning changes:
1. snapshot current device config
2. apply minimal edits
3. verify stream presence/quality/freshness
4. retain rollback artifacts until live validation is complete

## References

- Add a video stream: https://docs.formant.io/docs/getting-started-add-a-video-stream
- Video encoding: https://docs.formant.io/docs/video-encoding
- Set up real-time connections: https://docs.formant.io/docs/getting-started-set-up-real-time-connections
- Telemetry vs realtime data streams: https://docs.formant.io/docs/getting-started-telemetry-vs-realtime-data-streams
