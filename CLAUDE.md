# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Claude Code plugin (`files-organizer`) that scans Mac file systems, finds duplicates, analyzes folder structure, detects orphan files, and generates interactive HTML dashboards with reorganization recommendations.

## Architecture

This repo root IS the plugin. Install with `claude plugins add .`

- **commands/** — 3 slash commands: `/scan`, `/organize`, `/file-map`
- **agents/** — 3 subagents: `dedup-finder`, `structure-advisor`, `orphan-detector`
- **skills/** — 2 skills: `generate-file-map` (HTML dashboard generation), `mac-file-patterns` (organization knowledge, Claude-only)
- **scripts/** — 3 bash scripts for filesystem scanning, duplicate detection, similar name finding
- **examples/** — Original `my-mac-file-map.html` dashboard (the project that inspired this plugin)
- **.claude-plugin/** — Plugin manifest (`plugin.json`) and `marketplace.json`

## Key Design Patterns

- Dark theme with GitHub-inspired color palette (CSS custom properties)
- Color-coded file type badges (`.ext-doc`, `.ext-img`, `.ext-vid`, etc.)
- Category tags (`.tag-personal`, `.tag-work`, `.tag-creative`, `.tag-3dprint`)
- Recommendation cards with copy-to-clipboard shell commands
- Self-contained single-file HTML output (no external dependencies)
- Design system reference: `skills/generate-file-map/references/design-system.md`
- HTML template: `skills/generate-file-map/assets/template.html`

## Usage

- `/scan ~/Documents` — Scan a directory and generate file inventory
- `/organize ~/Documents` — Full analysis with 3 parallel agents, produces recommendations
- `/file-map output.html` — Generate interactive HTML dashboard

## To Preview Example

Open `examples/my-mac-file-map.html` directly in a browser. No server needed.
