#!/bin/bash
# Scan a directory tree and output structured file inventory as JSON-like text
# Usage: scan-files.sh <directory> [max-depth]
# Output: tab-separated lines: path, size_bytes, type, extension, modified_date, md5 (for files < 50MB)

DIR="${1:-.}"
MAX_DEPTH="${2:-5}"

if [ ! -d "$DIR" ]; then
  echo "ERROR: Directory '$DIR' does not exist" >&2
  exit 1
fi

echo "=== SCAN RESULTS FOR: $DIR ==="
echo "=== SCAN DATE: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo ""

# Directory size summary
echo "=== DIRECTORY SIZES ==="
du -h -d 2 "$DIR" 2>/dev/null | sort -rh | head -50
echo ""

# File inventory
echo "=== FILE INVENTORY ==="
echo "PATH\tSIZE_BYTES\tEXTENSION\tMODIFIED"
find "$DIR" -maxdepth "$MAX_DEPTH" -type f \
  ! -path '*/.*' \
  ! -path '*/node_modules/*' \
  ! -path '*/Library/*' \
  ! -path '*/__pycache__/*' \
  ! -path '*/.git/*' \
  2>/dev/null | while IFS= read -r file; do
  size=$(stat -f%z "$file" 2>/dev/null || stat --format=%s "$file" 2>/dev/null)
  ext="${file##*.}"
  if [ "$ext" = "$file" ]; then ext="none"; fi
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  mod=$(stat -f%Sm -t%Y-%m-%d "$file" 2>/dev/null || stat --format=%y "$file" 2>/dev/null | cut -d' ' -f1)
  printf '%s\t%s\t%s\t%s\n' "$file" "$size" "$ext" "$mod"
done
echo ""

# Extension census
echo "=== EXTENSION CENSUS ==="
find "$DIR" -maxdepth "$MAX_DEPTH" -type f \
  ! -path '*/.*' \
  ! -path '*/node_modules/*' \
  ! -path '*/Library/*' \
  2>/dev/null | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -40
echo ""

# Potential duplicates by size
echo "=== POTENTIAL DUPLICATES (same size files) ==="
find "$DIR" -maxdepth "$MAX_DEPTH" -type f \
  ! -path '*/.*' \
  ! -path '*/node_modules/*' \
  ! -path '*/Library/*' \
  -size +1k \
  2>/dev/null -exec stat -f"%z %N" {} \; 2>/dev/null | sort -n | uniq -d -w 15 | head -30
echo ""

echo "=== SCAN COMPLETE ==="
