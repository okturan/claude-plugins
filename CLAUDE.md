# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a single-file static HTML project: `my-mac-file-map.html` — an interactive dashboard that visualizes the personal file structure and storage usage on a Mac. It displays storage breakdowns, file type census, and folder-by-folder details with collapsible sections.

## Architecture

- **Single file**: `my-mac-file-map.html` — self-contained HTML with inline CSS and JS
- **No build tools, dependencies, or package manager**
- **No tests**

## Tech Stack

- Vanilla HTML/CSS/JS
- CSS custom properties for theming (dark theme with GitHub-inspired color palette)
- Collapsible sections via `<details>` elements and a click handler on `.section-header`

## Key Design Patterns

- Color-coded file type badges (`.ext-doc`, `.ext-img`, `.ext-vid`, etc.)
- Category tags (`.tag-personal`, `.tag-work`, `.tag-creative`, `.tag-3dprint`)
- Storage breakdown uses inline `<div>` segments styled as a stacked bar chart
- Stat cards grid uses `auto-fit` with `minmax(200px, 1fr)`

## To Preview

Open `my-mac-file-map.html` directly in a browser. No server needed.
