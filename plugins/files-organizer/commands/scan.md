---
description: Deep scan of disk usage — covers everything including hidden dotfiles, Library, Applications, system dirs, APFS volumes, and cleanable caches
argument-hint: [directory-path] [max-depth]
allowed-tools: Read, Bash, Glob, Grep
---

Perform a comprehensive disk usage scan. This is a two-phase process: first a fast system-wide overview, then an optional file-level inventory if the user wants to drill deeper.

Target path: $ARGUMENTS

## Phase 1: Deep Disk Scan (always run)

Run the deep disk scan script. This is fast (uses du, not per-file stat) and covers everything the old scan missed: hidden dotfiles, ~/Library, /Applications, /Library, /opt, APFS volumes, build artifacts, and cleanable caches.

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/scan-disk.sh "$HOME"
```

Parse the output and present a **complete disk usage map** organized as:

### 1. Disk Overview
- APFS container: total, used, free, percentage
- Per-volume breakdown (System, Data, VM, Preboot, Recovery, any simulator volumes)

### 2. Where The Space Goes
Present a single table that accounts for ALL space on the data volume. Group into:
- **Home visible dirs** (~/code, ~/Documents, ~/Downloads, etc.)
- **Home dotfiles** (~/.cache, ~/.npm, ~/.colima, etc.) — this is the category most scans miss entirely
- **~/Library** (Application Support, Caches, Containers, Developer, etc.)
- **/Applications**
- **System** (/Library, /opt/homebrew, /private/var)

The goal is that these categories sum to roughly match the APFS data volume usage. If there's a gap > 5GB, investigate (APFS snapshots, purgeable space, missed directories).

### 3. Largest Items
- Top code projects by size
- Largest individual files (>100MB)
- Build artifacts & node_modules (with total)

### 4. Cleanable Space
Present a table of reclaimable items with:
- What it is
- Size
- How to clean it (specific command)
- Risk level (safe / verify first / use with caution)
- Total potential savings

Categorize cleanable items:
- **Package caches**: npm, pip, uv, bun, cargo, gradle, m2, pnpm
- **Build artifacts**: node_modules, DerivedData, build/, dist/, .next
- **Tool caches**: Hugging Face models, Playwright browsers, Puppeteer
- **VM/container images**: Colima/Lima, Docker, OrbStack
- **App caches**: ~/Library/Caches (browser, Homebrew, etc.)
- **Stale data**: old worktrees, archived sessions

### 5. Actionable Summary
End with a concise "quick wins" table: the top 5-10 cleanup actions sorted by space recovered, with the exact command to run each.

## Phase 2: File Inventory (only if needed)

If the user asks to drill into a specific directory, or if `/organize` or `/file-map` will be run next, run the file-level scan:

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/scan-files.sh "<target-path>" <max-depth>
```

This produces per-file metadata (path, size, extension, date) useful for duplicate detection, age analysis, and file type distribution.

## Presentation

- Use tables for everything — they're scannable
- Always show sizes in human-readable form (GB/MB)
- Bold the biggest items and quick wins
- If totals don't add up, say so and explain why (APFS overhead, snapshots, etc.)
- Keep it concise — the user can ask to drill deeper into anything
