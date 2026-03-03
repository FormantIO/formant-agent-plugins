# Formant Agent Plugins

Skills and commands for managing [Formant](https://formant.io) robot fleets from AI coding agents.

## Claude Code

```bash
# Add the plugin marketplace
/plugin marketplace add FormantIO/formant-agent-plugins

# Install the formant-admin plugin
/plugin install formant-admin@formantio-formant-agent-plugins
```

Once installed, Claude Code automatically loads the Formant skills and commands. Run `/check` to verify CLI access and authentication.

## Codex

```bash
# Option 1: Clone and symlink skills
git clone https://github.com/FormantIO/formant-agent-plugins.git
ln -s formant-agent-plugins/.agents/skills/formant-* .agents/skills/

# Option 2: Add MCP server for CLI access
codex mcp add formant -- npx -y @formant/formant-cli
```

## Prerequisites

Install the Formant CLI and authenticate:

```bash
npm install -g @formant/formant-cli
formant auth login --user "<service-account-email>" --password "<password>"
```

## What's included

### Skills

| Skill | Description |
|-------|-------------|
| `formant-administrator` | Full-coverage CLI administration for operations, diagnostics, and fleet management |
| `formant-persona-chat` | Persona-first Theopolis chat workflows with thread continuity, sync/async turns, polling, and history |
| `formant-config-lifecycle` | Rollback-safe configuration mutations with schema-aware editing |
| `formant-view-configuration` | Historical telemetry view (coherence style) design defaults and audit heuristics; suggestions only, not hard rules |
| `formant-teleop-view-configuration` | Teleop view design defaults for camera/control composition and action wiring; suggestions only, not hard rules |
| `formant-event-automation` | Event trigger and trigger-group design defaults for condition semantics, action routing, and alert-noise reduction |
| `formant-realtime-connection-design` | Realtime stream architecture defaults for teleop/observe wiring, media tuning, and live validation |
| `formant-task-summary-analytics` | Task-summary KPI and SQL defaults for reporting quality checks and analysis workflows |
| `formant-stream-tuning` | Telemetry and video stream tuning defaults for rate, bandwidth, and usability tradeoffs |

### Commands

| Command | Description |
|---------|-------------|
| `/check` | Validate CLI availability, authentication, and org access |

## Links

- [Formant CLI](https://github.com/FormantIO/formant-cli)
- [Formant Documentation](https://docs.formant.io)
- [Formant](https://formant.io)

## License

MIT — see [LICENSE](LICENSE).
