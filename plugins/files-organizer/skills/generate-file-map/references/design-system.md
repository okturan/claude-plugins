# Design System Reference

## CSS Custom Properties

| Variable | Value | Usage |
|----------|-------|-------|
| `--bg` | `#0d1117` | Page background |
| `--card` | `#161b22` | Card/section background |
| `--border` | `#30363d` | Borders |
| `--text` | `#c9d1d9` | Body text |
| `--head` | `#f0f6fc` | Headings |
| `--accent` | `#58a6ff` | Links, highlights |
| `--green` | `#3fb950` | Success, safe actions |
| `--yellow` | `#d29922` | Warnings, review items |
| `--pink` | `#f778ba` | Large files, attention |
| `--purple` | `#bc8cff` | Creative assets |
| `--orange` | `#d18616` | 3D printing, archive |

## File Type Badge Classes

Color-coded inline badges for file extensions. Apply as `<span class="ext ext-TYPE">ext</span>`:

| Class | Color | Extensions |
|-------|-------|------------|
| `.ext-doc` | Blue (#1f3a5f bg) | docx, pages, txt, rtf, soulver, ics |
| `.ext-img` | Purple (#2d1f3f bg) | png, jpg, jpeg, svg, webp, heic, gif |
| `.ext-vid` | Pink (#3f1f2f bg) | mp4, mov, MOV |
| `.ext-design` | Green (#1f3f2f bg) | ai, psd, afdesign, key |
| `.ext-spread` | Yellow (#3f3a1f bg) | xlsx, xls, numbers, csv |
| `.ext-3d` | Orange (#3f2a1f bg) | stl, 3mf, gcode |
| `.ext-archive` | Gray (#2a2a2a bg) | zip, rar, 7z, dmg |
| `.ext-audio` | Magenta (#3f1f3f bg) | mp3, wav, m4a |
| `.ext-pdf` | Red (#3f1f1f bg) | pdf, PDF |

## Category Tag Classes

Rounded pill badges for content categories. Apply as `<span class="tag tag-TYPE">label</span>`:

| Class | Color | Usage |
|-------|-------|-------|
| `.tag-personal` | Blue | Personal files, media |
| `.tag-work` | Yellow | Work/business documents |
| `.tag-creative` | Purple | Design, art, creative assets |
| `.tag-3dprint` | Orange | 3D printing files |

## Recommendation Card Types

| Type class | Border color | Usage |
|------------|-------------|-------|
| `.rec-delete` | Red (`--red`) | Files to delete |
| `.rec-move` | Blue (`--accent`) | Files to relocate |
| `.rec-merge` | Green (`--green`) | Folders to consolidate |
| `.rec-archive` | Yellow (`--yellow`) | Files to archive externally |
