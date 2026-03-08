# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A personal Claude Code plugin marketplace. Install plugins via `/plugin` using `okturan/claude-plugins`.

## Architecture

```
claude-plugins/
├── .claude-plugin/
│   └── marketplace.json           # Marketplace manifest (lists all plugins)
└── plugins/
    └── files-organizer/           # Each plugin in its own directory
        ├── .claude-plugin/
        │   └── plugin.json
        ├── commands/
        ├── agents/
        ├── skills/
        └── scripts/
```

## Adding a new plugin

1. Create `plugins/my-plugin/` with its own `.claude-plugin/plugin.json`
2. Add an entry to `.claude-plugin/marketplace.json` with `"source": "./plugins/my-plugin"`
3. Commit and push

## Plugins

### files-organizer
Scans Mac file systems, finds duplicates, analyzes folder structure, detects orphan files, and generates interactive HTML dashboards with reorganization recommendations.

- `/scan ~/Documents` — Scan a directory and generate file inventory
- `/organize ~/Documents` — Full analysis with 3 parallel agents
- `/file-map output.html` — Generate interactive HTML dashboard
