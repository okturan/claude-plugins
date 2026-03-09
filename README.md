# claude-plugins

Personal Claude Code plugin marketplace by [okturan](https://github.com/okturan).

## Installation

Register this marketplace in Claude Code:

```
/plugin marketplace add https://github.com/okturan/claude-plugins
```

Then install any plugin from it:

```
/plugin install files-organizer@claude-plugins
```

## Available Plugins

### files-organizer

Scan Mac file systems, find duplicates, analyze folder structure, detect orphan files, and generate interactive HTML dashboards with reorganization recommendations.

| Command | What it does |
|---------|-------------|
| `/scan [directory]` | Scan a directory and show file inventory — sizes, types, age, large files |
| `/organize [directory]` | Full analysis with 3 parallel agents (dedup-finder, structure-advisor, orphan-detector) |
| `/file-map [output.html]` | Generate a self-contained HTML dashboard with dark theme and copy-to-clipboard commands |

### project-health

Deep audit any code repository — scores it out of 100 across 9 categories. Language-agnostic, works on any git repo.

| Command | What it does |
|---------|-------------|
| `/project-health` | Full audit of the current repository across all 9 categories |
| `/project-health --category testing` | Audit only a single category |

Categories: Git Health (15), Structure (15), Code Quality (15), Config (10), Database (10), Docs (10), Testing & CI (15), Dependencies (5), Security (5).

## Plugin Structure

Each plugin lives under `plugins/` with its own manifest and components:

```
plugins/plugin-name/
  .claude-plugin/plugin.json   # manifest (name, version, description)
  commands/*.md                # slash commands
  agents/*.md                  # autonomous subagents
  skills/*/SKILL.md            # auto-activating skills
  scripts/                     # helper scripts
  hooks/hooks.json             # event handlers
```

## License

MIT
