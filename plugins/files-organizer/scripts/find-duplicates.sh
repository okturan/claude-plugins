#!/bin/bash
# Find duplicate files by MD5 hash within a directory
# Usage: find-duplicates.sh <directory> [min-size-bytes]
# Output: Groups of duplicate files with their sizes

DIR="${1:-.}"
MIN_SIZE="${2:-1024}"  # Default: ignore files < 1KB

if [ ! -d "$DIR" ]; then
  echo "ERROR: Directory '$DIR' does not exist" >&2
  exit 1
fi

echo "=== DUPLICATE FILE ANALYSIS ==="
echo "=== Directory: $DIR ==="
echo "=== Min size: $MIN_SIZE bytes ==="
echo "=== Date: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo ""

# Find files, compute MD5, group by hash
echo "Scanning files..."
TMPFILE=$(mktemp)

find "$DIR" -type f \
  ! -path '*/.*' \
  ! -path '*/node_modules/*' \
  ! -path '*/Library/*' \
  ! -path '*/.git/*' \
  -size +"${MIN_SIZE}c" \
  2>/dev/null | while IFS= read -r file; do
  size=$(stat -f%z "$file" 2>/dev/null || stat --format=%s "$file" 2>/dev/null)
  hash=$(md5 -q "$file" 2>/dev/null || md5sum "$file" 2>/dev/null | cut -d' ' -f1)
  printf '%s\t%s\t%s\n' "$hash" "$size" "$file"
done | sort > "$TMPFILE"

echo ""
echo "=== DUPLICATE GROUPS ==="

# Find hashes that appear more than once
cut -f1 "$TMPFILE" | sort | uniq -d | while IFS= read -r hash; do
  echo "--- Duplicate group (MD5: $hash) ---"
  grep "^$hash" "$TMPFILE" | while IFS=$'\t' read -r h size path; do
    human_size=$(echo "$size" | awk '{
      if ($1 >= 1073741824) printf "%.1f GB", $1/1073741824;
      else if ($1 >= 1048576) printf "%.1f MB", $1/1048576;
      else if ($1 >= 1024) printf "%.1f KB", $1/1024;
      else printf "%d B", $1;
    }')
    echo "  [$human_size] $path"
  done
  echo ""
done

# Summary
total_dupes=$(cut -f1 "$TMPFILE" | sort | uniq -d | wc -l | tr -d ' ')
echo "=== SUMMARY ==="
echo "Duplicate groups found: $total_dupes"

if [ "$total_dupes" -gt 0 ]; then
  # Calculate wasted space
  wasted=$(cut -f1 "$TMPFILE" | sort | uniq -d | while IFS= read -r hash; do
    grep "^$hash" "$TMPFILE" | tail -n +2 | cut -f2
  done | awk '{sum+=$1} END {print sum}')
  wasted_human=$(echo "$wasted" | awk '{
    if ($1 >= 1073741824) printf "%.1f GB", $1/1073741824;
    else if ($1 >= 1048576) printf "%.1f MB", $1/1048576;
    else if ($1 >= 1024) printf "%.1f KB", $1/1024;
    else printf "%d B", $1;
  }')
  echo "Space wasted by duplicates: $wasted_human"
fi

rm -f "$TMPFILE"
echo ""
echo "=== ANALYSIS COMPLETE ==="
