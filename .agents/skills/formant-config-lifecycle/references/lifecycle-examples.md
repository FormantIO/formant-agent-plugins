# Lifecycle Examples

## Example 1: Update one nested teleop flag in device config

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

## Example 2: Rename a view while preserving layout/config

1. Snapshot:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity view --id <view-id> --env stage
```

2. Build update payload:
```bash
jq '.name = "Operations Overview v2"' \
  .formant-admin-artifacts/<bundle>/before.json > /tmp/view-updated.json
```

3. Apply:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity view --id <view-id> --env stage --updated /tmp/view-updated.json
```

## Example 3: Roll back

From the bundle directory created during apply mode:

```bash
cd .formant-admin-artifacts/<bundle>
./rollback.sh
```

Then verify with the corresponding `get` command:

```bash
formant view get <view-id> --json --stage
```
