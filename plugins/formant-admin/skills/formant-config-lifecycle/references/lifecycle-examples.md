# Lifecycle Examples

## Example 1: Update a nested teleop flag in device config

1. Snapshot current config:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity device-config --id <device-id> --env prod
```

2. Edit snapshot with `jq`:

```bash
jq '.teleop.disableHighPingWarning = true' \
  .formant-admin-artifacts/<bundle>/before.json > /tmp/device-config-updated.json
```

3. Apply and capture artifacts:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity device-config --id <device-id> --env prod --updated /tmp/device-config-updated.json
```

## Example 2: Add a telemetry stream to device config

1. Snapshot:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity device-config --id <device-id> --env prod
```

2. Add stream with `jq`:

```bash
jq '.telemetry.streams += [{"name": "battery.voltage", "configuration": {"type": "numeric", "topicName": "/battery/voltage", "topicType": "std_msgs/Float64"}, "throttleHz": 1}]' \
  .formant-admin-artifacts/<bundle>/before.json > /tmp/device-config-updated.json
```

3. Apply:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity device-config --id <device-id> --env prod --updated /tmp/device-config-updated.json
```

## Example 3: Rename a view while preserving layout

1. Snapshot:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity view --id <view-id> --env prod
```

2. Build update payload:

```bash
jq '.name = "Operations Overview v2"' \
  .formant-admin-artifacts/<bundle>/before.json > /tmp/view-updated.json
```

3. Apply:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity view --id <view-id> --env prod --updated /tmp/view-updated.json
```

## Example 4: Update module configuration

1. Snapshot:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity module-configuration --id <module-config-id> --env prod
```

2. Edit the configuration JSON (stored as a string field):

```bash
jq '.configuration = (.configuration | fromjson | .theme = "dark" | tojson)' \
  .formant-admin-artifacts/<bundle>/before.json > /tmp/module-config-updated.json
```

3. Apply:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity module-configuration --id <module-config-id> --env prod --updated /tmp/module-config-updated.json
```

## Example 5: Roll back a change

From the bundle directory created during apply mode:

```bash
cd .formant-admin-artifacts/<bundle>
./rollback.sh
```

Then verify with the corresponding `get` command:

```bash
formant view get <view-id> --json
```
