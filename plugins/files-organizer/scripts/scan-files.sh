#!/bin/bash
# Scan a directory tree and output structured file inventory
# Usage: scan-files.sh <directory> [max-depth]
# Output: tab-separated lines: path, size_bytes, extension, modified_date

DIR="${1:-.}"
MAX_DEPTH="${2:-5}"

if [ ! -d "$DIR" ]; then
  echo "ERROR: Directory '$DIR' does not exist" >&2
  exit 1
fi

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

FIND_EXCLUDES=(
  ! -path '*/.*'
  ! -path '*/node_modules/*'
  ! -path '*/Library/*'
  ! -path '*/__pycache__/*'
  ! -path '*/.git/*'
)

echo "=== SCAN RESULTS FOR: $DIR ==="
echo "=== SCAN DATE: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo ""

# Directory size summary
echo "=== DIRECTORY SIZES ==="
du -h -d 2 "$DIR" 2>/dev/null | sort -rh | head -50
echo ""

# Single find pass: inventory + extension census from one traversal
echo "=== FILE INVENTORY ==="
echo "PATH\tSIZE_BYTES\tEXTENSION\tMODIFIED"
find "$DIR" -maxdepth "$MAX_DEPTH" -type f \
  "${FIND_EXCLUDES[@]}" \
  2>/dev/null | tee "$TMPFILE" | while IFS= read -r file; do
  size=$(stat -f%z "$file" 2>/dev/null || stat --format=%s "$file" 2>/dev/null)
  ext="${file##*.}"
  if [ "$ext" = "$file" ]; then ext="none"; fi
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  mod=$(stat -f%Sm -t%Y-%m-%d "$file" 2>/dev/null || stat --format=%y "$file" 2>/dev/null | cut -d' ' -f1)
  printf '%s\t%s\t%s\t%s\n' "$file" "$size" "$ext" "$mod"
done
echo ""

# Extension census from the same file list (no second find traversal)
echo "=== EXTENSION CENSUS ==="
sed 's/.*\.//' "$TMPFILE" | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -40
echo ""

echo "=== SCAN COMPLETE ==="
