# Formant CLI Agent Guidance

- Use installed `formant-*` skills for Formant administration tasks.
- Before mutating operations, validate setup with:
  - `formant --help`
  - `formant auth status --json`
  - `formant org get --json`
- Prefer schema-first command validation via:
  - `formant schema commands --json`
  - `formant schema commands --topic <topic> --json`
  - `formant schema commands --command "<topic> <command>" --json`
- Never print service account secrets.
