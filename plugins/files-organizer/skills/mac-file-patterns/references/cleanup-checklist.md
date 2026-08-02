# Mac Cleanup Checklist

## Step 1: Inventory small cleanup candidates

These commands only list files. Review the results before constructing a deletion command.

### Temporary and generated files
```bash
# List Office lock files. Close the related document before removing a stale lock.
find ~ -name '~$*' -type f

# List Finder metadata files
find ~ -name '.DS_Store' -type f

# List Windows metadata and recycle bins. Recycle bins may contain recoverable files.
find ~ -name 'Thumbs.db' -type f
find ~ -name '$RECYCLE.BIN' -type d

# List incomplete downloads. Confirm no download is active.
find ~/Downloads \( -name '*.crdownload' -o -name '*.partial' \) -type f
```

### Empty Directories
```bash
# Find empty directories (review before deleting)
find ~/Documents ~/Downloads -type d -empty
```

## Step 2: Review larger candidates

### Downloads Cleanup
```bash
# List DMG installers. Keep any installer needed for recovery or offline use.
find ~/Downloads -name '*.dmg' -type f

# List duplicate downloads (file (1).pdf pattern)
find ~/Downloads -regex '.* ([0-9]+)\.[^.]+$' -type f

# List old wetransfer folders
find ~/Downloads -name 'wetransfer-*' -type d

# Files older than 1 year in Downloads
find ~/Downloads -type f -mtime +365
```

### Screenshots Cleanup
```bash
# Count screenshots by year
find ~/Documents/Screenshots -type f -name '*.png' | sed 's/.*Screenshot //' | cut -d'-' -f1 | sort | uniq -c

# List screenshots older than 2 years
find ~/Documents/Screenshots -type f -mtime +730
```

### Archive Redundancy
```bash
# Find ZIP files that have matching extracted folders
for zip in ~/Downloads/*.zip; do
  base=$(basename "$zip" .zip)
  if [ -d "$HOME/Downloads/$base" ]; then
    echo "REVIEW: $zip (same-named folder exists; compare contents)"
  fi
done
```

## Step 3: Plan folder changes

### Find Scattered Content
```bash
# CVs and resumes
find ~ \( -iname '*cv*' -o -iname '*resume*' -o -iname '*curriculum*' \) -not -path '*/Library/*' -not -path '*/.git/*' 2>/dev/null

# Invoices and receipts
find ~ \( -iname '*invoice*' -o -iname '*factura*' -o -iname '*receipt*' \) -not -path '*/Library/*' 2>/dev/null

# Budget files
find ~ \( -iname '*budget*' -o -iname '*presupuesto*' \) -not -path '*/Library/*' 2>/dev/null
```

### Large File Review
```bash
# Files > 500MB
find ~ -type f -size +500M ! -path '*/Library/*' ! -path '*/.git/*' 2>/dev/null | head -20

# Files > 1GB
find ~ -type f -size +1G ! -path '*/Library/*' ! -path '*/.git/*' 2>/dev/null
```

## Report measured recovery only

Do not use fixed savings ranges. Sum the sizes returned by the scan for the exact files under review, and keep potential savings separate from space that was actually recovered.
