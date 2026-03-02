---
description: Validate local Formant CLI setup, auth, and environment targeting
argument-hint: "[--stage]"
---

# /check

Run environment and authentication checks before Formant admin tasks.

## Usage

```bash
/check $ARGUMENTS
```

`$ARGUMENTS` may include `--stage`. If omitted, default to production.

## Workflow

1. Verify CLI availability:

```bash
formant --help
```

2. Verify auth status:

```bash
formant auth status --json $ARGUMENTS
```

3. Verify organization access:

```bash
formant org get --json $ARGUMENTS
```

4. If CLI is missing, print installation instructions and stop:

```bash
npm install -g @formant/formant-cli
```

5. If auth fails, print remediation and stop:

```bash
formant auth login --user "<service-account-email>" --password "<service-account-password>"
formant auth status $ARGUMENTS
```

6. Output a short readiness report:
- target environment (`prod`/`stage`)
- authenticated principal (if available)
- org id/name
- blockers

## Guardrails

- Never print secret values.
- If both flags are present, ask user to choose one.
- Keep checks read-only.
