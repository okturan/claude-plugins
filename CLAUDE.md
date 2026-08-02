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
    ├── human-writing/             # Prose drafting and rewrite guidance
    │   ├── .claude-plugin/plugin.json
    │   ├── commands/
    │   └── skills/
    └── shape-the-work/            # Work-shaping mode router
        ├── .claude-plugin/plugin.json
        ├── commands/
        └── skills/
```

## Plugins

### files-organizer
Scan a directory, group duplicate candidates, review file placement, and write an HTML report.

- `/scan ~/Documents` - inventory file sizes and types
- `/organize ~/Documents` - run the three file-analysis agents
- `/file-map output.html` - write a standalone HTML report

### project-health
Score a Git repository out of 100 across nine categories.

- `/project-health` - run all category checks
- `/project-health --category testing` - run one category

### human-writing
Draft plain prose and rewrite text with common AI-writing patterns.

- `/humanize draft.md` - report the patterns found, then rewrite the file
- The skill loads when drafting posts, READMEs, announcements, or emails

### shape-the-work
Route a task to ordinary execution, OpenSpec Explore, Wayfinder, or Long-Horizon Prompting.

- `/shape-work <task>` - select one mode for the current phase
- Child skills stay external and are checked before use
- The router is general-purpose and explicit-only in Codex
