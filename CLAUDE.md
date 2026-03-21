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
    ├── project-health/            # Repo audit scorer (100 pts)
    │   ├── .claude-plugin/plugin.json
    │   ├── commands/
    │   └── skills/
    └── codex-cli/                 # OpenAI Codex CLI knowledge + runner
        ├── .claude-plugin/plugin.json
        ├── commands/
        └── skills/
```

## Plugins

### files-organizer
Find duplicates, analyze folder structure, and generate an HTML dashboard for any directory.

- `/scan ~/Documents` - file inventory
- `/organize ~/Documents` - full analysis with 3 parallel agents
- `/file-map output.html` - interactive HTML dashboard

### project-health
Audit any git repo and score it out of 100 across 9 categories.

- `/project-health` - full audit
- `/project-health --category testing` - single category

### codex-cli
Run or learn about OpenAI's Codex CLI from within Claude Code.

- `/codex-cli:codex <task>` - delegate task to Codex CLI
- `/codex-cli:codex` - code review of uncommitted changes
- `/codex-cli:codex-cli` - Codex CLI syntax and flag reference
