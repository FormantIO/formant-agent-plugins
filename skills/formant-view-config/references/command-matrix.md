# View Config Command Matrix

| Intent | Command | Mutation |
| --- | --- | --- |
| Read view | `formant view get <view-id> --json` | no |
| Update view | `formant view update <view-id> --file <json>` | yes |
| Reorder views | `formant view reorder --file <json>` | yes |
| Read teleop view | `formant teleop-view get <id> --json` | no |
| Update teleop view | `formant teleop-view update <id> --file <json>` | yes |
| Read module config | `formant module-configuration get <id> --json` | no |
| Update module config | `formant module-configuration update <id> --file <json>` | yes |

For exact argument and flag schemas, use `formant schema commands --json`.
