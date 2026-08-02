# files-organizer

A Claude Code plugin for reviewing files on macOS.

It inventories disk usage, groups exact duplicate candidates, flags files that may be misplaced, and writes a standalone HTML report. The plugin prints commands for review. It does not move or delete files on its own.

## Commands

### `/scan [directory]`

Runs a broad disk-usage scan that includes hidden folders, `~/Library`, applications, selected system paths, APFS volumes, and common caches. It defaults to the home directory. Permission errors and APFS accounting can leave gaps, which the report must show.

### `/organize [directory]`

Launches three agents in parallel:

- **dedup-finder:** groups content-identical files, similar filenames, archives with nearby extracted folders, and temporary-file candidates
- **structure-advisor:** finds related files in different locations and proposes a smaller directory structure
- **orphan-detector:** flags files that appear misplaced and suggests existing folders that may fit better

The report separates low-risk review items from moves and deletions that need closer inspection. Suggested shell commands are printed for review, not executed.

### `/file-map [output.html]`

Writes one HTML file with folder sizes, file counts, duplicate candidates, a collapsible directory view, search, and copyable commands. It opens directly in a browser without a server.

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
