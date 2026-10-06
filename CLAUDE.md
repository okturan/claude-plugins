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
    ├── shape-the-work/            # Work-shaping mode router
    │   ├── .claude-plugin/plugin.json
    │   ├── commands/
    │   └── skills/
    └── restart/                   # /restart mod (function hooks, needs herdr)
        ├── .claude-plugin/plugin.json
        └── hooks/                 # hooks.json, register.ts, relaunch.ts + test
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
Route by the artifact needed now: ordinary execution, OpenSpec exploration, a Wayfinder decision map, or a Long-Horizon launch brief.

- `/shape-work <task>` - select one mode for the current phase
- Child skills stay external and operational readiness is checked before use
- The router is general-purpose and explicit-only in Codex

### restart
Reopen the current session on the newest installed Claude Code with the same conversation and launch flags. A mod: function hooks in TypeScript, Claude Code 2.1.287 or later.

- `/restart` - a detached helper ends the session with SIGTERM (a mod's `/exit` does not), then types `claude <flags> --resume <id>` into the herdr pane
- Needs herdr; outside herdr it prints the command instead of exiting
- `claude plugin test plugins/restart` runs `relaunch.test.ts`; `.claude-plugin/types/` is generated and ignored
