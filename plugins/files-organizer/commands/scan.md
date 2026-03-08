---
description: Scan a directory and generate structured file inventory
argument-hint: [directory-path] [max-depth]
allowed-tools: Read, Bash, Glob, Grep
---

Scan the filesystem at the specified path (default: user's home personal directories) and generate a structured inventory of all files.

Target path: $ARGUMENTS

If no path is provided, scan these directories in the user's home folder:
- ~/Documents
- ~/Downloads
- ~/Desktop
- ~/Pictures
- ~/Movies
- ~/Music
- ~/Dropbox (if it exists)

**Scanning process:**

1. Run the scan script to collect file metadata:
   ```
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/scan-files.sh "<target-path>" <max-depth>
   ```

2. Parse and summarize the output:
   - Total file count and storage used
   - Top 10 largest directories
   - File extension census (count by type)
   - Date range of files (oldest to newest)

3. Present a concise summary organized by:
   - **Storage breakdown** by top-level folder
   - **File type distribution** (documents, images, video, audio, 3D, archives, design, code)
   - **Age analysis** (files by year)
   - **Large files** (anything > 500MB)

4. Save the raw scan data mentally for use by `/organize` or `/file-map` commands.

Keep the output concise and scannable. Use tables where appropriate. Highlight anything unusual (extremely large files, very old files, suspicious temp files).
