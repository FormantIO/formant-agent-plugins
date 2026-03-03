# Formant Agent Plugins

Skills and commands for managing [Formant](https://formant.io) robot fleets from AI coding agents.

## Agent Runtime Routing (Required)

If you are an AI coding agent, follow exactly one install path based on runtime.

### Claude Code

```bash
# Add the plugin marketplace
/plugin marketplace add FormantIO/formant-agent-plugins

# Install the formant-admin plugin
/plugin install formant-admin@formantio-formant-agent-plugins
```

Policy:
- Use plugin marketplace only.
- Do not perform manual skill copying/symlinking for Claude.

### Codex (and runtimes without marketplace install)

```bash
set -euo pipefail

REPO="$HOME/src/formant-admin/formant-agent-plugins"
DEST="$HOME/.codex/skills"

if [ ! -d "$REPO/.git" ]; then
  git clone https://github.com/FormantIO/formant-agent-plugins.git "$REPO"
fi
git -C "$REPO" pull --ff-only

if [ -d "$REPO/plugins/formant-admin/skills" ]; then
  SRC="$REPO/plugins/formant-admin/skills"
else
  SRC="$REPO/.agents/skills"
fi

mkdir -p "$DEST"
for skill in "$SRC"/formant-*; do
  name="$(basename "$skill")"
  rm -rf "$DEST/$name"
  ln -s "$skill" "$DEST/$name"
done
```

Validation (required):

```bash
git -C "$REPO" status -sb
ls -ld "$HOME/.codex/skills"/formant-*
```

Policy:
- Do not copy `formant-*` skills into agent skill directories.
- Always `git pull --ff-only` before relinking.
- Restart the agent runtime after install/update.

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
