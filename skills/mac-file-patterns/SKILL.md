---
name: mac-file-patterns
description: This skill should be used when a task involves analyzing macOS file structures, recommending folder hierarchies, classifying files by type or purpose, identifying cleanup targets, or suggesting reorganization strategies for personal Mac file systems. Covers standard Mac directories, file extension categories, bilingual (English/Spanish) filename patterns, and safe-to-delete file types.
version: 0.2.0
user-invocable: false
---

# Mac File Organization Patterns

## Standard Mac Directory Purposes

| Directory | Purpose | Common clutter |
|-----------|---------|----------------|
| ~/Documents | Long-term personal & work files | Becomes a dumping ground for everything |
| ~/Downloads | Temporary landing zone | Never cleaned up, accumulates for years |
| ~/Desktop | Quick access, active work | Screenshots, temp files pile up |
| ~/Pictures | Photos Library (managed by Apple) | Rarely needs manual organization |
| ~/Movies | iMovie projects, media | Usually small unless active video editing |
| ~/Music | Music app, GarageBand | Managed by apps |
| ~/Dropbox | Cloud sync | Often abandoned with large orphan files |

## Recommended Personal Folder Structure

```
~/Documents/
  Work/
    [Company]/
      Projects/
      Admin/           (contracts, invoices, HR)
  Personal/
    Finance/           (budgets, tax, bank statements)
    Medical/
    Legal/             (IDs, visas, permits, contracts)
    Travel/
  Creative/
    Design-Projects/   (client or personal design work)
    Assets/            (fonts, templates, stock images)
    3D-Printing/       (STL, GCODE organized by project)
  Education/
    [Course or Topic]/
  Archive/             (old projects, reference material)
```

## File Category Classification

### By extension
- **Documents**: .docx, .doc, .pdf, .pages, .txt, .rtf, .md
- **Spreadsheets**: .xlsx, .xls, .numbers, .csv
- **Presentations**: .pptx, .ppt, .key
- **Images**: .png, .jpg, .jpeg, .gif, .webp, .heic, .svg
- **Video**: .mp4, .mov, .avi, .mkv
- **Audio**: .mp3, .wav, .m4a, .aac
- **Design**: .ai, .psd, .afdesign, .sketch, .fig, .eps
- **3D printing**: .stl, .3mf, .gcode, .obj
- **Fonts**: .ttf, .otf, .woff, .woff2
- **Archives**: .zip, .rar, .7z, .tar.gz, .dmg
- **Code**: .html, .css, .js, .py, .swift

### By purpose
Classify by searching filenames for keywords. Account for both English and Spanish terms:
- **CVs/Resumes**: "cv", "resume", "curriculum"
- **Invoices**: "invoice" / "factura", "receipt" / "recibo"
- **Budgets**: "budget" / "presupuesto", "financial"
- **Contracts**: "contract" / "contrato", "agreement"
- **Recipes**: "recipe" / "receta"
- **Letters**: "letter" / "carta"

### Bilingual filename equivalents
Files may use Spanish or English naming. Common pairs:
- Documents/Documentos, Recipes/Recetas, Invoice/Factura
- Budget/Presupuesto, Contract/Contrato, Letter/Carta

## Common Cleanup Targets

### Always safe to delete
- `~$*.docx` / `~$*.xlsx` - Office temp lock files
- `.DS_Store` - macOS folder metadata
- `$RECYCLE.BIN/` - Windows recycle bin (from external drives)
- `Thumbs.db` - Windows thumbnail cache
- `.Spotlight-V100/` - Spotlight index data
- `.Trashes/` - macOS trash on external drives

### Usually safe to delete (verify first)
- `.dmg` files in Downloads (installers, delete after install)
- `*.partial` / `*.crdownload` - Incomplete downloads
- Duplicate downloads: `file (1).pdf`, `file (2).pdf`
- wetransfer folders with hash names (after extracting content)
- Empty directories

## Additional Resources

### Reference Files
- **`references/cleanup-checklist.md`** - Detailed cleanup procedures with bash commands by priority
