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
    ├── files-organizer/           # Mac file system organizer
    │   ├── .claude-plugin/plugin.json
    │   ├── commands/
    │   ├── agents/
    │   ├── skills/
    │   └── scripts/
    └── project-health/            # Repo audit scorer (100 pts)
        ├── .claude-plugin/plugin.json
        ├── commands/
        └── skills/
```

## Plugins

### files-organizer
Scans Mac file systems, finds duplicates, analyzes folder structure, detects orphan files, and generates interactive HTML dashboards with reorganization recommendations.

- `/scan ~/Documents` — Scan a directory and generate file inventory
- `/organize ~/Documents` — Full analysis with 3 parallel agents
- `/file-map output.html` — Generate interactive HTML dashboard

### project-health
Deep audit any code repository — scores it out of 100 across 9 categories (git health, structure, code quality, config, database, docs, testing, deps, security). Language-agnostic, works on any repo.

- `/project-health` — Full audit of the current repository
- `/project-health --category testing` — Audit only the testing category
