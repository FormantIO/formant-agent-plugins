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
| `formant-administrator` | Default router for natural-language admin workflows |
| `formant-cli-schemas` | Schema discovery and command-shape validation |
| `formant-config-lifecycle` | Rollback-safe configuration mutations |
| `formant-device-config` | Device and template configuration operations |
| `formant-view-config` | View, module, and teleop configuration operations |

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
