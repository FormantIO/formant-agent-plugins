# Device Config Command Matrix

| Intent | Command | Mutation |
| --- | --- | --- |
| Read effective device config | `formant device config <device-id> --json` | no |
| Apply device config document | `formant device apply-config <device-id> --file <json>` | yes |
| Validate stream config shape | `formant device validate-stream-config --file <json>` | no |
| Read template | `formant config-template get <template-id> --json` | no |
| Update template | `formant config-template update <template-id> --file <json>` | yes |
| Apply template to devices | `formant config-template apply <template-id> ...` | yes |

For exact argument and flag schemas, use `formant schema commands --json`.
