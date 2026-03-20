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

## Hidden Dotfiles & Developer Caches

Dotfiles (directories starting with `.` in the home folder) are invisible in Finder and often overlooked by file scanners. They routinely consume 20-80+ GB on developer machines. Always scan these — they are often the single largest category of reclaimable space.

### Common large dotdirs

| Directory | What it is | Typical size | Cleanup command |
|-----------|-----------|-------------|-----------------|
| `~/.cache/huggingface` | Downloaded ML models | 5-50 GB | `rm -rf ~/.cache/huggingface/` |
| `~/.npm` | npm package cache | 2-10 GB | `npm cache clean --force` |
| `~/.cache/uv` | Python uv cache | 1-5 GB | `uv cache clean` |
| `~/.cache/pip` | pip download cache | 0.5-3 GB | `pip cache purge` |
| `~/.bun` | Bun runtime cache | 1-3 GB | `rm -rf ~/.bun/install/cache` |
| `~/.gradle` | Gradle build cache | 1-5 GB | `rm -rf ~/.gradle/caches/` |
| `~/.m2` | Maven repository cache | 0.5-3 GB | `rm -rf ~/.m2/repository/` |
| `~/.cargo/registry` | Rust crate cache | 0.5-3 GB | `cargo cache --autoclean` |
| `~/.colima` / `~/.lima` | Container VM images | 5-20 GB | `colima delete` |
| `~/.codex/worktrees` | Codex stale worktrees | 1-10 GB | `rm -rf ~/.codex/worktrees/` |
| `~/.cache/puppeteer` | Puppeteer browsers | 0.5-2 GB | `rm -rf ~/.cache/puppeteer/` |
| `~/.cache/torch` | PyTorch model cache | 0.5-5 GB | `rm -rf ~/.cache/torch/` |
| `~/.rustup` | Rust toolchains | 1-3 GB | Keep if using Rust |
| `~/.platformio` | PlatformIO (IoT) | 0.5-2 GB | Keep if using PlatformIO |
| `~/.rbenv` | Ruby versions | 0.5-2 GB | Keep if using Ruby |
| `~/.vscode` | VS Code extensions | 1-3 GB | Manage in VS Code |

All cache directories regenerate on demand — cleaning them is always safe, just costs a re-download next time they're needed.

### ~/Library hidden costs

`~/Library` is excluded from many scans but often holds 20-50+ GB:

| Subdirectory | What it is | Typical offenders |
|-------------|-----------|-------------------|
| `Application Support/Google/Chrome` | Chrome profiles, data, extensions | 5-15 GB |
| `Application Support/Code` | VS Code extensions, cache, WebStorage | 2-5 GB |
| `Caches/` | App caches (Chrome, Homebrew, Playwright, pip) | 3-10 GB |
| `Containers/` | Sandboxed app data (iMessage, Slack) | 2-5 GB |
| `Developer/Xcode/DerivedData` | Xcode build cache | 1-5 GB |
| `Developer/CoreSimulator` | iOS simulator runtime data | 1-5 GB |

Clean Caches: `rm -rf ~/Library/Caches/*` (regenerates automatically)
Clean DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/`

### System-level space consumers

| Location | What it is | Typical size |
|----------|-----------|-------------|
| `/Library/Developer/CoreSimulator` | iOS Simulator runtimes (separate APFS volumes!) | 10-30 GB |
| `/Library/Frameworks/Python.framework` | System Python installs | 2-5 GB |
| `/opt/homebrew` | Homebrew packages | 3-10 GB |
| `/Applications/Xcode.app` | Xcode IDE | 5-15 GB |

Clean old simulators: `xcrun simctl delete unavailable`
Clean Homebrew: `brew cleanup --prune=all`

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

### Build artifacts in code projects
These regenerate automatically when you build/install again:
- `node_modules/` — `rm -rf` per project, `npm install` to restore
- `build/`, `dist/`, `.next/`, `.expo/` — build outputs
- `DerivedData/`, `.build/` — Xcode/Swift build caches
- `Pods/` — CocoaPods dependencies
- `.gradle/` — Gradle build cache (project-level)

## Additional Resources

### Reference Files
- **`references/cleanup-checklist.md`** - Detailed cleanup procedures with bash commands by priority
