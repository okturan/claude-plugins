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

SIZEFILE=$(mktemp)
HASHFILE=$(mktemp)
trap 'rm -f "$SIZEFILE" "$HASHFILE"' EXIT

format_size() {
  awk '{
    if ($1 >= 1073741824) printf "%.1f GB", $1/1073741824;
    else if ($1 >= 1048576) printf "%.1f MB", $1/1048576;
    else if ($1 >= 1024) printf "%.1f KB", $1/1024;
    else printf "%d B", $1;
  }' <<< "$1"
}

echo "=== DUPLICATE FILE ANALYSIS ==="
echo "=== Directory: $DIR ==="
echo "=== Min size: $MIN_SIZE bytes ==="
echo "=== Date: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo ""

# Phase 1: Collect file sizes (cheap)
echo "Scanning file sizes..."
find "$DIR" -type f \
  ! -path '*/.git/*' \
  ! -path '*/node_modules/*' \
  ! -path '*/Library/*' \
  ! -path '*/.Trash/*' \
  ! -path '*/__pycache__/*' \
  -size +"${MIN_SIZE}c" \
  2>/dev/null | while IFS= read -r file; do
  size=$(stat -f%z "$file" 2>/dev/null || stat --format=%s "$file" 2>/dev/null)
  printf '%s\t%s\n' "$size" "$file"
done > "$SIZEFILE"

# Phase 2: Only hash files whose size appears more than once
echo "Hashing potential duplicates..."
dup_sizes=$(cut -f1 "$SIZEFILE" | sort | uniq -d)

while IFS=$'\t' read -r size file; do
  if echo "$dup_sizes" | grep -qxF "$size"; then
    hash=$(md5 -q "$file" 2>/dev/null || md5sum "$file" 2>/dev/null | cut -d' ' -f1)
    printf '%s\t%s\t%s\n' "$hash" "$size" "$file"
  fi
done < "$SIZEFILE" | sort > "$HASHFILE"

echo ""
echo "=== DUPLICATE GROUPS ==="

# Compute duplicate hashes once
dup_hashes=$(cut -f1 "$HASHFILE" | sort | uniq -d)

echo "$dup_hashes" | while IFS= read -r hash; do
  [ -z "$hash" ] && continue
  echo "--- Duplicate group (MD5: $hash) ---"
  awk -F'\t' -v h="$hash" '$1 == h' "$HASHFILE" | while IFS=$'\t' read -r _h size path; do
    echo "  [$(format_size "$size")] $path"
  done
  echo ""
done

# Summary
total_dupes=$(echo "$dup_hashes" | grep -c . 2>/dev/null || echo 0)
echo "=== SUMMARY ==="
echo "Duplicate groups found: $total_dupes"

if [ "$total_dupes" -gt 0 ]; then
  wasted=$(echo "$dup_hashes" | while IFS= read -r hash; do
    [ -z "$hash" ] && continue
    awk -F'\t' -v h="$hash" '$1 == h' "$HASHFILE" | tail -n +2 | cut -f2
  done | awk '{sum+=$1} END {print sum+0}')
  echo "Space wasted by duplicates: $(format_size "$wasted")"
fi

echo ""
echo "=== ANALYSIS COMPLETE ==="
