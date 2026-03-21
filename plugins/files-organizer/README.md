# files-organizer

A Claude Code plugin for organizing Mac file systems.

Scans directories, finds duplicates, analyzes folder structure, detects misplaced files, and generates interactive HTML dashboards with reorganization recommendations.

## Commands

### `/scan [directory]`

Deep disk usage scan covering everything including hidden dotfiles, Library, Applications, system dirs, APFS volumes, and cleanable caches. Defaults to home directory. Can drill into specific directories with a file-level inventory.

### `/organize [directory]`

Full analysis. Launches three agents in parallel:

- **dedup-finder** (cyan) — Exact duplicates via MD5, near-duplicates by similar names, redundant archives (ZIP alongside extracted folder), temp/junk files
- **structure-advisor** (green) — Scattered content detection, folder merge candidates, proposed directory hierarchy, migration commands
- **orphan-detector** (yellow) — Misplaced files, stray downloads, lonely files, abandoned directories

Produces prioritized recommendations (quick wins, high impact, reorganization) with risk levels and copy-paste shell commands.

### `/file-map [output.html]`

Generates a self-contained HTML dashboard. Dark theme, collapsible folder explorer, file type badges, recommendation cards with copy-to-clipboard buttons, search/filter. Open directly in a browser — no server needed.

## Components

```
files-organizer/
  .claude-plugin/plugin.json
  commands/
    scan.md              # /scan command
    organize.md          # /organize command
    file-map.md          # /file-map command
  agents/
    dedup-finder.md      # Duplicate detection agent
    structure-advisor.md # Folder analysis agent
    orphan-detector.md   # Misplaced file detection agent
  skills/
    generate-file-map/   # HTML dashboard design patterns
      SKILL.md
      assets/template.html
      references/design-system.md
    mac-file-patterns/   # Mac file organization knowledge (Claude-only)
      SKILL.md
      references/cleanup-checklist.md
  scripts/
    scan-files.sh        # File inventory scanner
    find-duplicates.sh   # MD5-based duplicate finder with size pre-filtering
    similar-names.sh     # Cross-directory similar filename detector
```

## Requirements

- macOS (uses `stat -f%z`, `md5 -q`, and other macOS-specific flags)
- Claude Code with plugin support

## License

MIT
