---
description: Analyze file structure and generate reorganization recommendations
argument-hint: [directory-path]
allowed-tools: Read, Bash, Glob, Grep, Agent, Write
model: opus
---

Run a comprehensive file organization analysis on the specified directory (default: user's home personal directories) and generate actionable reorganization recommendations.

Target: $ARGUMENTS

**Phase 1 - Scan the filesystem:**

If a recent scan hasn't been done, run the scan script first:
```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/scan-files.sh "<target-path>"
```

**Phase 2 - Launch analysis agents in parallel:**

Use the Agent tool to launch these three specialized agents concurrently (all in a single message):

1. **dedup-finder** agent - Find duplicate and near-duplicate files
   - Provide the target directory path
   - Ask it to run `${CLAUDE_PLUGIN_ROOT}/scripts/find-duplicates.sh` and `${CLAUDE_PLUGIN_ROOT}/scripts/similar-names.sh`

2. **structure-advisor** agent - Analyze folder relationships and suggest consolidation
   - Provide the target directory path and the scan results summary
   - Ask it to identify scattered related content and propose a cleaner folder structure

3. **orphan-detector** agent - Find misplaced files and suggest relocation
   - Provide the target directory path
   - Ask it to identify files that don't belong where they are

**Phase 3 - Compile recommendations:**

After all agents complete, compile their findings into a structured report:

### Recommendations Report

1. **Duplicates to remove** - Exact duplicates with sizes and `rm` commands
2. **Near-duplicates to review** - Similar files that may be versions of each other
3. **Folders to merge** - Directories with overlapping content that should be consolidated
4. **Files to relocate** - Orphan files with suggested destinations
5. **Proposed folder structure** - A clean directory tree showing where things should live
6. **Cleanup commands** - Ready-to-copy shell commands for each action (mkdir, mv, rm)
7. **Estimated space savings** - How much space each action would recover

Group recommendations by priority:
- **Quick wins** (safe deletes: temp files, .DS_Store, ~$ files, empty dirs)
- **High impact** (large duplicates, archive candidates)
- **Reorganization** (moves and merges that improve structure)

Present each recommendation with:
- What to do
- Why (reasoning)
- The shell command to execute it
- Risk level (safe / review first / backup first)

Ask the user if they want to generate an HTML dashboard with these findings using `/file-map`.
