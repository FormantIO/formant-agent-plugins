# Formant Admin Playbooks

## Setup Check

```bash
formant --help
formant auth status --json ENV
formant org get --json ENV
```

`ENV` is empty for prod, `--stage` for stage, `--dev` for dev.

## Fleet Snapshot (Read-only)

```bash
formant device list --include-offline --with-data --json ENV
formant event list --severity critical --limit 200 --json ENV
formant event list --severity error --limit 200 --json ENV
```

## Device Deep Dive (Read-only)

```bash
formant device get <device-id> --json ENV
formant device config <device-id> --json ENV
formant device streams <device-id> --days 7 --json ENV
formant event list --device <device-id> --limit 100 --json ENV
formant command history --device <device-id> --limit 50 --json ENV
```

## Config Mutation with Lifecycle Artifacts

Run through lifecycle script (no manual approval stage):

```bash
${CLAUDE_PLUGIN_ROOT}/skills/formant-config-lifecycle/scripts/config-lifecycle.sh \
  --entity <entity> --id <id> --env <prod|stage|dev> --updated <updated.json>
```

Supported entities:
- `device-config`
- `config-template`
- `view`
- `teleop-view`
- `module-configuration`

## Post-change Verification

Re-read target object and summarize:
- changed keys
- operational impact
- rollback path (`rollback.sh` in artifact bundle)
