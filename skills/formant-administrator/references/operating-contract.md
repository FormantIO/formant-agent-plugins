# Operating Contract

This contract defines what the agent should do by default in Formant admin workflows.

## Priority Order

1. Preserve system operability.
2. Preserve auditability (artifacts and diffs).
3. Minimize unnecessary mutation scope.
4. Keep commands valid against CLI schemas.

## Required Behavior

- Use natural language as the primary interface.
- Use `/check` when setup/auth/environment state is uncertain.
- For supported config entities (`device-config`, `config-template`, `view`, `teleop-view`, `module-configuration`), always execute through `formant-config-lifecycle`.
- Produce and retain rollback artifacts for every supported config mutation.
- Re-read after mutation and report concrete changed keys.

## Command Validity Rules

- Validate command args/flags via `formant schema commands --json` before execution.
- If command shape is ambiguous, stop and resolve schema mismatch first.
- Do not infer undocumented flags or hidden arguments.

## Schema Rules

- For shallow checks, use `config-entity-schemas.md`.
- For nested edits, use `deep-config-hierarchies.md` and follow dependency chains.
- Do not add unknown fields to payloads unless the schema reference or live API response indicates they are valid.

## Mutation Policy

- No proposal/approval gate is required in this plugin workflow.
- Mutations should still be explicit and traceable via lifecycle artifacts.
- For unsupported mutation targets, perform read-only discovery and state that lifecycle automation is unavailable for that entity.

## Output Contract

After mutation, always report:
- environment (`prod`/`stage`/`dev`)
- target entity and id
- artifact bundle path
- diff file path
- rollback script path
- key changed fields and operational impact
