---
description: Scan disk usage across home folders, selected system paths, APFS volumes, and common caches
argument-hint: [directory-path]
allowed-tools: Read, Bash, Glob, Grep
---

Scan disk usage in two phases. Start with a directory-level overview, then collect file metadata only when the user needs a closer look.

Target path: $ARGUMENTS

## Phase 1: Disk overview (always run)

Run the disk scan script. It uses `du` instead of per-file `stat` calls and checks hidden folders, `~/Library`, `/Applications`, `/Library`, `/opt`, APFS volumes, build outputs, and common caches. It may miss unreadable directories, snapshots, and purgeable APFS space.

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/scan-disk.sh "${ARGUMENTS:-$HOME}"
```

Parse the output into a disk-usage report with these sections:

### 1. Disk Overview
- APFS container: total, used, free, percentage
- Per-volume breakdown (System, Data, VM, Preboot, Recovery, any simulator volumes)

### 2. Where the space goes
Present one table for the storage the script could measure. Group it into:
- **Home visible dirs** (~/code, ~/Documents, ~/Downloads, etc.)
- **Home dotfiles** (`~/.cache`, `~/.npm`, `~/.colima`, and similar paths)
- **~/Library** (Application Support, Caches, Containers, Developer, etc.)
- **/Applications**
- **System** (/Library, /opt/homebrew, /private/var)

Compare the measured total with APFS data-volume usage. If the gap is larger than 5 GB, report it and check for permission errors, snapshots, purgeable space, or missed directories.

### 3. Largest Items
- Top code projects by size
- Largest individual files (>100MB)
- Build artifacts & node_modules (with total)

### 4. Cleanup candidates
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

### 5. Cleanup summary
End with 5 to 10 measured cleanup candidates sorted by recoverable space. Include a command only when the target path is explicit, and label whether it is a read-only check or a destructive action.

## Phase 2: File Inventory (only if needed)

If the user asks to drill into a specific directory, or if `/organize` or `/file-map` will be run next, run the file-level scan:

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/scan-files.sh "<target-path>" <max-depth>
```

This produces paths, sizes, extensions, and modification dates for duplicate checks, age analysis, and file-type counts.

## Presentation

- Use tables for repeated fields and comparisons
- Always show sizes in human-readable form (GB/MB)
- Call out the largest measured items
- If totals don't add up, say so and explain why (APFS overhead, snapshots, etc.)
- Keep the report concise and preserve any measurement gaps or warnings
