---
description: Generate an interactive HTML dashboard visualizing file structure and recommendations
argument-hint: [output-filename]
allowed-tools: Read, Write, Bash, Glob, Grep
---

Generate an interactive HTML file map dashboard. Use the generate-file-map skill for design patterns and the mac-file-patterns skill for organization knowledge.

Output file: $ARGUMENTS (default: file-map.html in current directory)

**Process:**

1. **Gather data** - If no recent scan/organize data is available, run a quick scan:
   ```
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/scan-files.sh ~
   ```

2. **Read the template** for design patterns:
   ```
   Read ${CLAUDE_PLUGIN_ROOT}/skills/generate-file-map/assets/template.html
   ```

3. **Generate the HTML dashboard** with these sections:

   a. **Header** - Title, scan date, total storage summary

   b. **Stat cards** - Total storage, file count, largest folder, duplicates found

   c. **Storage breakdown bar** - Color-coded stacked bar showing space by category

   d. **File type census** - Table with extension, count, category tags

   e. **Folder explorer** - Collapsible sections for each top-level directory with:
      - Folder size and file count
      - Subfolders with sizes
      - Notable files

   f. **Recommendations panel** (if organize data available):
      - Dedup cards with "copy rm command" buttons
      - Merge suggestions with before/after folder trees
      - Orphan alerts with suggested destinations
      - Each card has a "Copy command" button using clipboard API

   g. **Proposed structure** - Side-by-side current vs. proposed folder tree

   h. **Key findings table** - Finding, size impact, suggested action

4. **Design requirements:**
   - Dark theme matching the existing file map style (GitHub-inspired palette)
   - CSS custom properties for theming
   - Collapsible sections via `<details>` elements
   - Color-coded file type badges
   - Category tags (personal, work, creative, 3dprint)
   - Responsive grid layout
   - Copy-to-clipboard buttons for shell commands
   - No external dependencies (fully self-contained HTML)
   - Search/filter input for finding files quickly

5. **Write the file** to the specified output path.

6. **Report** the output path and file size to the user.
