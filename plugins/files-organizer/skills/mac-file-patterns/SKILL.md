---
name: mac-file-patterns
description: Analyze macOS file structures, classify files, review cleanup candidates, or plan a folder reorganization. Covers standard Mac directories, file extensions, and English or Spanish filename patterns. Treat every deletion as a review step.
version: 0.2.0
user-invocable: false
---

# Mac File Organization Patterns

## Standard Mac Directory Purposes

| Directory | Purpose | Common clutter |
|-----------|---------|----------------|
| ~/Documents | Long-term personal & work files | Loose files that may belong in existing project folders |
| ~/Downloads | Temporary landing zone | Installers, partial downloads, and copied archives |
| ~/Desktop | Quick access, active work | Screenshots and temporary working files |
| ~/Pictures | Photos Library (managed by Apple) | Rarely needs manual organization |
| ~/Movies | iMovie projects, media | Exports and old project media |
| ~/Music | Music app, GarageBand | Managed by apps |
| ~/Dropbox | Cloud sync | Local copies from inactive sync folders |

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

Finder hides home-directory names that start with `.`, and shallow scans often omit them. Measure these directories before estimating how much space they use. Some hold caches; others hold active configuration, databases, credentials, or tool state.

### Common large dotdirs

| Directory | What it is | Review or cleanup path |
|-----------|------------|------------------------|
| `~/.cache/huggingface` | Downloaded ML models | Review model names and confirm they can be downloaded again |
| `~/.npm` | npm package cache | Inspect with `npm cache verify`; use npm's cleanup command if needed |
| `~/.cache/uv` | Python uv cache | `uv cache clean` |
| `~/.cache/pip` | pip download cache | `pip cache purge` |
| `~/.bun/install/cache` | Bun package cache | Measure this exact subdirectory; do not remove the rest of `~/.bun` |
| `~/.gradle/caches` | Gradle caches | Check for offline-build requirements before removal |
| `~/.m2/repository` | Maven dependencies | Check for local-only artifacts and offline-build requirements |
| `~/.cargo/registry` | Rust crate cache | Use `cargo cache` if installed, or review entries manually |
| `~/.colima` / `~/.lima` | Container VM images and state | `colima delete` removes the VM; confirm its data is disposable first |
| `~/.codex/worktrees` | Codex worktrees | Confirm each worktree is stale and has no uncommitted changes |
| `~/.cache/puppeteer` | Downloaded Puppeteer browsers | Confirm affected projects can download the browsers again |
| `~/.cache/torch` | Downloaded PyTorch assets | Review model and checkpoint files before removal |
| `~/.rustup` | Rust toolchains | List toolchains with `rustup toolchain list`; uninstall only unused ones |
| `~/.platformio` | PlatformIO packages and state | Keep if PlatformIO projects still use it |
| `~/.rbenv` | Ruby versions | List versions with `rbenv versions`; remove only unused versions |
| `~/.vscode` | VS Code extensions and data | Manage extensions in VS Code; do not treat the whole directory as cache |

Some entries are disposable caches, while others mix cache data with active state. Prefer each tool's own cleanup command. Before suggesting manual deletion, name the exact path, measure it, and explain what will need to be downloaded or rebuilt.

### ~/Library hidden costs

Many scans exclude `~/Library`. Measure it rather than assuming which application uses the most space:

| Subdirectory | What it contains | What to check |
|-------------|------------------|---------------|
| `Application Support/Google/Chrome` | Chrome profiles, databases, and extensions | Profile ownership and sync status |
| `Application Support/Code` | VS Code extensions, caches, and WebStorage | Extension and workspace state |
| `Caches/` | Per-application caches | The owning app's cleanup or reset instructions |
| `Containers/` | Sandboxed application data | Whether the app still uses the container |
| `Developer/Xcode/DerivedData` | Xcode build output | Close Xcode and confirm builds can be regenerated |
| `Developer/CoreSimulator` | Simulator data | Installed runtimes and devices in Xcode |

Do not delete all of `~/Library/Caches` as one operation. Review the largest child directories and use application-specific cleanup where possible.

### System-level space consumers

| Location | What it is | Review path |
|----------|------------|-------------|
| `/Library/Developer/CoreSimulator` | iOS Simulator runtimes and APFS volumes | Check Xcode's installed platforms and `xcrun simctl list` |
| `/Library/Frameworks/Python.framework` | Python installations | Confirm which interpreter each project uses |
| `/opt/homebrew` | Homebrew packages and support files | Run `brew cleanup --dry-run` before `brew cleanup` |
| `/Applications/Xcode.app` | Xcode | Remove only if Xcode is no longer needed |

`xcrun simctl delete unavailable` removes devices tied to unavailable runtimes. Review `xcrun simctl list` first.

## Common Cleanup Targets

### Review before deleting
- `~$*.docx` / `~$*.xlsx`: Office lock files; remove only after closing the document and confirming the lock is stale
- `.DS_Store`: Finder metadata that macOS can recreate
- `$RECYCLE.BIN/`: recoverable files from a Windows recycle bin; inspect before emptying
- `Thumbs.db`: Windows thumbnail cache
- `.Spotlight-V100/`: Spotlight index data that macOS may rebuild
- `.Trashes/`: recoverable files from macOS Trash on external drives; inspect before emptying

### Other cleanup candidates
- `.dmg` files in Downloads, after confirming the installer is no longer needed
- `*.partial` / `*.crdownload` files, after confirming no download is active
- Duplicate downloads: `file (1).pdf`, `file (2).pdf`
- wetransfer folders with hash names (after extracting content)
- Empty directories

### Build artifacts in code projects
These are often reproducible, but removal can break offline work or discard local-only output. Check the project and its lock files first:
- `node_modules/` (restore with the project's package manager)
- `build/`, `dist/`, `.next/`, `.expo/` (build output)
- `DerivedData/`, `.build/` (Xcode and Swift build output)
- `Pods/` (CocoaPods dependencies)
- `.gradle/` (project-level Gradle cache)

## Additional Resources

### Reference Files
- **`references/cleanup-checklist.md`**: read-only inventory commands grouped by review effort
