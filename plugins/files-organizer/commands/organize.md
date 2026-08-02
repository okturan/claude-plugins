---
description: Review duplicates, file placement, and folder structure before proposing changes
argument-hint: [directory-path]
allowed-tools: Read, Bash, Glob, Grep, Agent, Write
model: opus
---

Review the specified directory and propose file moves or removals. Default to the user's personal home directories. Do not change the filesystem.

Target: $ARGUMENTS

**Phase 1: Scan the filesystem**

If a recent scan hasn't been done, run the file-level scan script (note: this is `scan-files.sh`, not the deep disk scan from `/scan`):
```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/scan-files.sh "<target-path>"
```

**Phase 2: Launch analysis agents in parallel**

Use the Agent tool to launch these three specialized agents concurrently (all in a single message):

1. **dedup-finder** agent - Find duplicate and near-duplicate files
   - Provide the target directory path
   - Ask it to run `${CLAUDE_PLUGIN_ROOT}/scripts/find-duplicates.sh` and `${CLAUDE_PLUGIN_ROOT}/scripts/similar-names.sh`

2. **structure-advisor** agent - Analyze folder relationships and suggest consolidation
   - Provide the target directory path and the scan results summary
   - Ask it to identify related content in different locations and propose a smaller folder structure

3. **orphan-detector** agent - Find misplaced files and suggest relocation
   - Provide the target directory path
   - Ask it to identify files that don't belong where they are

**Phase 3: Compile recommendations**

After all agents complete, compile their findings into a structured report:

### Recommendations Report

1. **Content-identical files**: sizes, paths, and a recommendation about which copy to keep
2. **Similar files to review**: files that may be different versions despite similar names
3. **Folders that may overlap**: directories with related content
4. **Files that may be misplaced**: current paths and suggested destinations
5. **Proposed folder structure**: a directory tree based on the user's existing categories
6. **Commands to review**: quoted `mkdir`, `mv`, or `rm` commands for each proposed action
7. **Measured space recovery**: totals based on the scanned files, without estimates for unscanned data

Group recommendations by priority:
- **Low-risk review** (OS metadata, inactive Office lock files, and empty directories)
- **Large items** (content-identical files and archive candidates)
- **Folder changes** (moves and merges that affect the user's filing system)

Present each recommendation with:
- What to do
- Why (reasoning)
- The shell command to execute it
- Risk level (safe / review first / backup first)

After the report, mention that `/file-map` can turn the same findings into an HTML file.
