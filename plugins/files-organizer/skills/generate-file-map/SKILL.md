---
name: generate-file-map
description: This skill should be used when the user asks to "generate a file map", "create an HTML dashboard", "visualize my files", "create a file map HTML", "update the file map", "build a storage dashboard", "map my folders", "scan my files into a dashboard", or "create a file structure report". It produces a self-contained HTML file visualizing file structure, storage usage, and organization recommendations.
version: 0.2.0
---

# Generate File Map

Create interactive, self-contained HTML dashboards that visualize file structure, storage usage, and organization recommendations for Mac file systems.

## Data Gathering

To populate the dashboard with file data, run the scan scripts at `${CLAUDE_PLUGIN_ROOT}/scripts/`:
- `scan-files.sh <directory>` - Collects file inventory, directory sizes, extension census
- `find-duplicates.sh <directory>` - Identifies duplicate files by MD5 hash
- `similar-names.sh <directory>` - Finds files with similar names across directories

## Template

Read and adapt the HTML template at `assets/template.html`. Replace HTML comments (e.g., `<!-- TITLE -->`, `<!-- STAT CARDS -->`) with actual data from the scan results. The template contains the full design system (dark theme, GitHub-inspired palette via CSS custom properties) and all component styles.

## Component Patterns

### Recommendation Cards
When organization recommendations are available, render action cards:
```html
<div class="rec-card rec-[type]">
  <div class="rec-header">
    <span class="rec-icon">[icon]</span>
    <span class="rec-title">[title]</span>
    <span class="rec-impact">[size impact]</span>
  </div>
  <div class="rec-body">[description]</div>
  <button class="copy-btn" onclick="copyCmd(this)"
    data-cmd="[shell command]">Copy command</button>
</div>
```
Types: `rec-delete` (red), `rec-move` (blue), `rec-merge` (green), `rec-archive` (yellow)

### Layout Patterns
- **Stat cards**: CSS grid with `auto-fit, minmax(200px, 1fr)`
- **Storage bar**: Inline `<div>` segments in a flex container
- **Sections**: `.section` cards with `.section-header` (clickable) + `.section-body`
- **Collapsible content**: `<details>` elements for folder contents
- **Search**: Input field filtering visible sections via JS

## JavaScript Requirements

The dashboard must include:
1. **Section collapse** - Click `.section-header` to toggle `.section-body`
2. **Copy to clipboard** - `copyCmd(btn)` copies `data-cmd` to clipboard, shows feedback
3. **Search filter** - Input filters sections by text content
4. **No external dependencies** - Everything inline in a single HTML file

## Additional Resources

### Asset Files
- **`assets/template.html`** - Base HTML template with all styles, JS, and component patterns

### Reference Files
- **`references/design-system.md`** - CSS custom properties, file type badge classes, category tag classes
