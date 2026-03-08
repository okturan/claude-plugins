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

echo "=== SIMILAR FILENAME ANALYSIS ==="
echo "=== Directory: $DIR ==="
echo "=== Date: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo ""

TMPFILE=$(mktemp)

# Collect all filenames with their paths
find "$DIR" -type f \
  ! -path '*/.*' \
  ! -path '*/node_modules/*' \
  ! -path '*/Library/*' \
  ! -path '*/.git/*' \
  2>/dev/null | while IFS= read -r file; do
  basename=$(basename "$file")
  # Strip extension for comparison
  name="${basename%.*}"
  # Normalize: lowercase, strip common prefixes/suffixes
  normalized=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[_-]/ /g' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
  if [ ${#normalized} -ge "$MIN_LEN" ]; then
    printf '%s\t%s\n' "$normalized" "$file"
  fi
done | sort > "$TMPFILE"

echo "=== FILES WITH SAME BASE NAME IN DIFFERENT DIRECTORIES ==="
echo ""

# Find normalized names that appear in multiple directories
cut -f1 "$TMPFILE" | sort | uniq -d | while IFS= read -r name; do
  dirs=$(grep "^${name}	" "$TMPFILE" | cut -f2 | xargs -I{} dirname {} | sort -u | wc -l | tr -d ' ')
  if [ "$dirs" -gt 1 ]; then
    echo "--- '$name' found in $dirs directories ---"
    grep "^${name}	" "$TMPFILE" | cut -f2 | while IFS= read -r path; do
      size=$(stat -f%z "$path" 2>/dev/null || stat --format=%s "$path" 2>/dev/null)
      human_size=$(echo "$size" | awk '{
        if ($1 >= 1073741824) printf "%.1f GB", $1/1073741824;
        else if ($1 >= 1048576) printf "%.1f MB", $1/1048576;
        else if ($1 >= 1024) printf "%.1f KB", $1/1024;
        else printf "%d B", $1;
      }')
      echo "  [$human_size] $path"
    done
    echo ""
  fi
done

echo ""
echo "=== COMMON KEYWORD CLUSTERS ==="
echo "(Files sharing keywords in their names)"
echo ""

# Extract significant words from filenames and find clusters
cut -f2 "$TMPFILE" | xargs -I{} basename {} | sed 's/\.[^.]*$//' | tr '[:upper:]' '[:lower:]' | sed 's/[_-]/ /g' | tr ' ' '\n' | sort | uniq -c | sort -rn | awk '$1 > 3 && length($2) > 3 {print $1, $2}' | head -30

rm -f "$TMPFILE"
echo ""
echo "=== ANALYSIS COMPLETE ==="
