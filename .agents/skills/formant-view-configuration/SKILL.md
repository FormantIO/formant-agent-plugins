---
name: formant-view-configuration
description: This skill should be used when users ask to design, assess, or improve Formant historical telemetry views (coherence view style), including stream selection, module layout, timeline behavior, and operator usability. Guidance is heuristic, not hard rules. Use with formant-config-lifecycle when applying view changes.
version: 0.1.0
---

# Formant View Configuration

Design and evaluate Formant historical telemetry views with practical operator-focused heuristics.

## Scope

Use this skill for:
- view quality reviews
- stream/module selection for dashboards
- module layout and sizing recommendations
- timeline vs realtime behavior decisions
- coherence style historical telemetry view defaults

Routing rules:
- For view mutations, use `formant-config-lifecycle` for snapshot/apply/rollback.
- For teleoperation-first interfaces, use `formant-teleop-view-configuration`.
- For non-view operational administration, use `formant-administrator`.

Out of scope:
- teleoperation view design (different interaction goals and constraints)
- claiming universal best practices for all view types

## Guidance Stance

Treat this skill as a default lens, not a rulebook.

- These are suggestions, not hard requirements.
- This reflects one experienced operator/support perspective and common team patterns.
- Multiple view archetypes are valid (camera walls, log-only views, mapping-heavy interfaces, and others).
- Prioritize the user's actual operational need over the defaults here.

## Default Workflow

### 1. Confirm intent and audience

Classify the target surface before proposing changes:
- single-robot operator/support overview
- fleet-level monitoring
- debugging/engineering diagnostics

If the ask is teleoperation-first, do not apply this guidance directly. A teleop-specific design flow is required.

### 2. Gather current configuration and stream reality

```bash
formant view get <view-id> --full --json
formant device streams <device-id> --days 30 --json
formant device streams <device-id> --days 30 --with-data --json
```

Also collect related views for naming/layout conventions:

```bash
formant view list --json
formant teleop-view list --json
```

### 3. Classify streams

Separate available streams into:
- `configured-and-useful`: used in modules and informative
- `intentionally-excluded`: publishing but low value/noisy for this audience
- `unavailable-or-non-viable`: not publishing, stale, or effectively constant/useless
- `candidate-to-add`: publishing and likely actionable

Important: not every unused stream is a gap. Many are correctly excluded.

### 4. Evaluate layout and module mix

For overview dashboards, default target is `8-16` modules. Going much larger often becomes unwieldy.

For this view class, use coherence style as the default presentation pattern.

Layout patterns that usually work:
- put high-context visual modules near top (camera, map, key status)
- use line charts for numeric values that change meaningfully over time
- group boolean/bitset states in a single state monitor module
- put deep logs and tables lower in the page

### 4a. Technical layout baseline (coherence)

Use this as a practical starting template, then adapt:
- assume a `36`-column style dashboard grid
- top band: large visual context + compact health
  - left half (`~18` cols): primary camera or highest-value visual
  - center (`~9` cols): map and key robot status tiles
  - right (`~9` cols): compact host charts (CPU/memory/network/battery)
- middle band: state monitor + navigation/map status
- lower bands: full-width log/fault tables
- bottom band: persistent map/waypoint inventories or supporting text modules

This pattern is a default that has worked well in practice, not a required structure.

### 5. Evaluate time behavior

If timeline is enabled (`showTimeline=true`):
- assume time-travel/back-in-time usage is expected
- prefer non-realtime module behavior unless a specific realtime need is stated
- ensure key modules still make sense when scrubbing historical ranges

Technical defaults that often pair well with timeline views:
- `showTimeline=true`
- module UI nodes generally `isRealtime=false`
- module time-frame nodes using global aggregate settings
- simple graph mode (`advanced=false`) unless explicitly needed

### 6. Evaluate module configuration quality

Default good practices:
- use simple/default graph mode unless advanced behavior is explicitly requested
- tune units only when stream metadata units are missing or misleading
- keep log/table columns intentionally sized and scoped to readable signals

Technical wiring patterns that have worked well:
- host numeric sets via subpaths:
  - `$.host.cpu` (`utilization`, `load avg 1 min`)
  - `$.host.memory` (`available`, `utilization`)
  - `$.host.network` (`transmit`, `receive`)
- robot state/boolean groups in one bitset module:
  - streams such as `spot.status`, `spot.can_dock`
- fault analysis via dedicated text tables:
  - `spot.adapter.log`, `spot.fault.events`, `spot.faults.*`
- navigation context:
  - map/location: `$.host.geoip`
  - map/waypoint identity: `spot.map.current`, `spot.map.default`, `spot.maps`, `spot.waypoints`

### 6a. Quick technical checks

```bash
# Module type mix
formant view get <view-id> --full --json \
  | jq '[.layout.modules|to_entries[]|.value.graph.nodes[]?|select(.type|startswith("ui-"))|.type]
        | group_by(.) | map({type:.[0],count:length})'

# Configured stream names in the view
formant view get <view-id> --full --json \
  | jq -r '[.layout.modules|to_entries[]|.value.graph.nodes[]?|select(.type=="device-stream")
            | (reduce .attributes[] as $a ({}; .[$a.name]=$a.value) | .streamName)] | unique | .[]'
```

### 6b. Documentation-backed checks

- Verify whether the view is intended to expose a timeline/date control bar, and ensure module-level time overrides are intentional.
- For group views, validate group query scope assumptions (current members only vs all tagged historical members).
- Remember that user drag/resize changes may be local cache only and not globally persisted.

### 7. Produce recommendations

Report in this order:
1. inferred user intent for the view
2. what is working well already
3. intentionally omitted streams and why
4. viable additions with expected operator value
5. optional cleanup/simplification suggestions

## Mutation Safety

When asked to change a view:
1. snapshot current view with `formant-config-lifecycle`
2. apply minimal edits
3. verify resulting module wiring and timeline behavior
4. report rollback artifact path and diff summary

## References

- Views and modules: https://docs.formant.io/docs/getting-started-views-and-modules
- Create a view and add modules (Coherence): https://docs.formant.io/docs/getting-started-create-a-view-and-add-modules
- Timeline behavior: https://docs.formant.io/docs/getting-started-the-timeline
