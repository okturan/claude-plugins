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

**Commands:**

| Command | What it does |
|---------|-------------|
| `/scan [directory]` | Scan a directory and show file inventory — sizes, types, age, large files |
| `/organize [directory]` | Full analysis with 3 parallel agents, produces prioritized recommendations with shell commands |
| `/file-map [output.html]` | Generate a self-contained HTML dashboard with dark theme, collapsible folders, copy-to-clipboard commands |

**How it works:**

`/organize` launches three specialized agents in parallel:

- **dedup-finder** — Finds exact duplicates (MD5), near-duplicates (similar names), redundant archives (ZIP + extracted folder)
- **structure-advisor** — Analyzes folder hierarchy, finds scattered content, proposes a cleaner structure with migration commands
- **orphan-detector** — Finds misplaced files, stray downloads, temp/junk files, lonely files that belong elsewhere

All three are bilingual-aware (English/Spanish filenames).

`/file-map` generates a single HTML file you can open in any browser — no server needed. Dark theme with GitHub-inspired palette, file type badges, category tags, and recommendation cards with one-click copy for every shell command.

## Adding Your Own Plugins

1. Create a directory under `plugins/your-plugin-name/`
2. Add a manifest at `plugins/your-plugin-name/.claude-plugin/plugin.json`:
   ```json
   {
     "name": "your-plugin-name",
     "version": "0.1.0",
     "description": "What your plugin does"
   }
   ```
3. Add components as needed:
   - `commands/*.md` — Slash commands
   - `agents/*.md` — Autonomous subagents
   - `skills/skill-name/SKILL.md` — Skills (knowledge Claude uses automatically)
   - `hooks/hooks.json` — Event-driven automation
   - `.mcp.json` — External tool integrations
4. Register your plugin in the root `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "your-plugin-name",
     "description": "What your plugin does",
     "author": { "name": "your-name" },
     "source": "./plugins/your-plugin-name",
     "category": "productivity"
   }
   ```
5. Commit and push.

## Plugin Structure Reference

```
plugins/your-plugin-name/
  .claude-plugin/
    plugin.json          # Required: plugin manifest
  commands/              # Slash commands (markdown + YAML frontmatter)
  agents/                # Subagent definitions (markdown + YAML frontmatter)
  skills/                # Auto-activating skills (subdirs with SKILL.md)
  scripts/               # Helper scripts
  hooks/                 # Event handlers (hooks.json)
  .mcp.json              # MCP server definitions
```

Plugins are the distributable unit. Skills, agents, hooks, and MCP servers live inside plugins. Standalone skills (in `~/.claude/skills/`) work for personal use but can't be shared through marketplaces.

## License

MIT
