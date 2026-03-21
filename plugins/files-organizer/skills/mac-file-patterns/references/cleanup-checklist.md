# Mac Cleanup Checklist

## Priority 1: Quick Wins (Safe, No Review Needed)

### Temp/Junk Files
```bash
# Remove Office temp files
find ~ -name '~$*' -type f -delete

# Remove .DS_Store files
find ~ -name '.DS_Store' -type f -delete

# Remove Windows artifacts
find ~ -name 'Thumbs.db' -type f -delete
find ~ -name '$RECYCLE.BIN' -type d -exec rm -rf {} +

# Remove incomplete downloads
find ~/Downloads \( -name '*.crdownload' -o -name '*.partial' \) -type f -delete
```

### Empty Directories
```bash
# Find empty directories (review before deleting)
find ~/Documents ~/Downloads -type d -empty
```

## Priority 2: High Impact (Review First)

### Downloads Cleanup
```bash
# List DMG installers (usually safe to delete after install)
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
    echo "REDUNDANT: $zip (folder exists)"
  fi
done
```

## Priority 3: Reorganization (Careful Planning)

### Find Scattered Content
```bash
# CVs and resumes
find ~ -iname '*cv*' -o -iname '*resume*' -o -iname '*curriculum*' 2>/dev/null | grep -v Library | grep -v '.git'

# Invoices and receipts
find ~ -iname '*invoice*' -o -iname '*factura*' -o -iname '*receipt*' 2>/dev/null | grep -v Library

# Budget files
find ~ -iname '*budget*' -o -iname '*presupuesto*' 2>/dev/null | grep -v Library
```

### Large File Review
```bash
# Files > 500MB
find ~ -type f -size +500M ! -path '*/Library/*' ! -path '*/.git/*' 2>/dev/null | head -20

# Files > 1GB
find ~ -type f -size +1G ! -path '*/Library/*' ! -path '*/.git/*' 2>/dev/null
```

## Space Recovery Estimates

| Action | Typical savings |
|--------|----------------|
| Delete old screenshots | 10-50 GB |
| Remove duplicate ZIPs | 5-20 GB |
| Clean Downloads | 5-15 GB |
| Remove DMG installers | 1-5 GB |
| Delete temp files | 100 MB - 1 GB |
| Archive Creative Market ZIPs to external | 30-40 GB |
