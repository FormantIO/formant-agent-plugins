---
name: formant-administrator
description: This skill should be used when users ask to administer Formant organizations and fleets using natural language, including diagnostics, configuration updates, role/user/team management, and operational workflows with the formant CLI.
version: 0.2.0
---

# Formant Administrator

Default operating behavior for competent Formant CLI administration.

## UX Model

- Primary interface is natural language, not slash commands.
- Keep slash-command usage minimal (`/check` for setup validation).

## Baseline Workflow

1. Run setup checks.
- Use `/check` at session start or when auth/env is uncertain.

2. Determine domain.
- Device config/template work -> `formant-device-config`.
- View/module/teleop-view work -> `formant-view-config`.
- Command shape discovery -> `formant-cli-schemas`.

3. Execute change lifecycle for supported config entities.
- Use `formant-config-lifecycle` for:
  - `device-config`
  - `config-template`
  - `view`
  - `teleop-view`
  - `module-configuration`

4. Verify outcomes.
- Re-read affected objects after writes.
- Report key changed fields and artifact bundle location.

## Safety Rules

- Treat `prod` as default and highest-risk environment.
- Never expose credentials.
- Never fabricate IDs, schemas, or command output.
- Always produce rollback-ready artifacts for supported config mutations.

## References

- `references/command-playbooks.md`
- `references/operating-contract.md`
- `../formant-cli-schemas/references/config-entity-schemas.md`
- `../formant-cli-schemas/references/deep-config-hierarchies.md`
