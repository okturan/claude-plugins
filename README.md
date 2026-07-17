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

Find duplicates, analyze folder structure, and generate an HTML dashboard for any directory.

| Command | What it does |
|---------|-------------|
| `/scan [directory]` | File inventory - sizes, types, age |
| `/organize [directory]` | Full analysis with 3 parallel agents |
| `/file-map [output.html]` | Interactive HTML dashboard with cleanup commands |

### project-health

Audit any git repo and score it out of 100 across 9 categories.

| Command | What it does |
|---------|-------------|
| `/project-health` | Full audit across all 9 categories |
| `/project-health --category testing` | Audit a single category |

Categories: Git Health (15), Structure (15), Code Quality (15), Config (10), Database (10), Docs (10), Testing & CI (15), Dependencies (5), Security (5).

### human-writing

Write outward-facing prose that reads like a person wrote it, and strip AI tells from existing drafts.

| Command | What it does |
|---------|-------------|
| `/humanize [text or file]` | Two-pass rewrite: identify AI tells, then rewrite keeping voice and meaning |

The skill also auto-activates when drafting posts, READMEs, announcements, emails, or marketing copy. Based on Wikipedia's Signs of AI writing catalog plus positive craft rules: real specifics, varied rhythm, one rhetorical device per piece, never invent details.

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
