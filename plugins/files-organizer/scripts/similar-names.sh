#!/bin/bash
# Find files with similar names across different directories
# Helps detect scattered related content (e.g., "CV" files in multiple folders)
# Usage: similar-names.sh <directory> [min-name-length]

DIR="${1:-.}"
MIN_LEN="${2:-4}"  # Minimum filename length to consider

if [ ! -d "$DIR" ]; then
  echo "ERROR: Directory '$DIR' does not exist" >&2
  exit 1
fi

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

format_size() {
  awk '{
    if ($1 >= 1073741824) printf "%.1f GB", $1/1073741824;
    else if ($1 >= 1048576) printf "%.1f MB", $1/1048576;
    else if ($1 >= 1024) printf "%.1f KB", $1/1024;
    else printf "%d B", $1;
  }' <<< "$1"
}

echo "=== SIMILAR FILENAME ANALYSIS ==="
echo "=== Directory: $DIR ==="
echo "=== Date: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo ""

# Collect all filenames with paths and sizes in one pass
find "$DIR" -type f \
  ! -path '*/.git/*' \
  ! -path '*/node_modules/*' \
  ! -path '*/Library/*' \
  ! -path '*/.Trash/*' \
  ! -path '*/__pycache__/*' \
  2>/dev/null | while IFS= read -r file; do
  basename=$(basename "$file")
  name="${basename%.*}"
  # Normalize: lowercase, replace separators with spaces, collapse whitespace
  normalized=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[_-]/ /g' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
  if [ ${#normalized} -ge "$MIN_LEN" ]; then
    size=$(stat -f%z "$file" 2>/dev/null || stat --format=%s "$file" 2>/dev/null)
    printf '%s\t%s\t%s\n' "$normalized" "$file" "$size"
  fi
done | sort > "$TMPFILE"

echo "=== FILES WITH SAME BASE NAME IN DIFFERENT DIRECTORIES ==="
echo ""

# Find normalized names that appear in multiple directories
cut -f1 "$TMPFILE" | sort | uniq -d | while IFS= read -r name; do
  dirs=$(awk -F'\t' -v n="$name" '$1 == n {print $2}' "$TMPFILE" | while IFS= read -r p; do dirname "$p"; done | sort -u | wc -l | tr -d ' ')
  if [ "$dirs" -gt 1 ]; then
    echo "--- '$name' found in $dirs directories ---"
    awk -F'\t' -v n="$name" '$1 == n' "$TMPFILE" | while IFS=$'\t' read -r _n path size; do
      echo "  [$(format_size "$size")] $path"
    done
    echo ""
  fi
done

echo ""
echo "=== COMMON KEYWORD CLUSTERS ==="
echo "(Files sharing keywords in their names)"
echo ""

# Extract significant words from filenames using the cached file list
cut -f2 "$TMPFILE" | sed 's|.*/||; s/\.[^.]*$//' | tr '[:upper:]' '[:lower:]' | sed 's/[_-]/ /g' | tr ' ' '\n' | sort | uniq -c | sort -rn | awk '$1 > 3 && length($2) > 3 {print $1, $2}' | head -30

echo ""
echo "=== ANALYSIS COMPLETE ==="
