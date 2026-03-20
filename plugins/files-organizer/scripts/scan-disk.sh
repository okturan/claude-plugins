#!/bin/bash
# Deep system-wide disk usage analysis
# Usage: scan-disk.sh [home-dir]
# Produces a comprehensive overview using du/diskutil (no slow per-file stat calls)
# Parallelizes independent du calls for speed (~30-60s instead of 3-4 min)

HOME_DIR="${1:-$HOME}"
TMPDIR_SCAN=$(mktemp -d)
trap 'rm -rf "$TMPDIR_SCAN"' EXIT

echo "=== DISK SCAN FOR: $HOME_DIR ==="
echo "=== SCAN DATE: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo ""

# ── APFS Container & Volume Info (instant, no du) ──
echo "=== APFS VOLUMES ==="
diskutil apfs list 2>/dev/null | grep -E "Container Reference|Capacity Ceiling|Capacity Not Allocated|Name:|Capacity Consumed|Role" | sed 's/^[| ]*//'
echo ""
echo "=== DISK SUMMARY ==="
df -h / 2>/dev/null | tail -1 | awk '{printf "Disk: %s total, %s used, %s free, %s capacity\n", $2, $3, $4, $5}'
echo ""

# ── Launch all heavy du scans in parallel ──
# Each writes to its own temp file; we cat them in order at the end.

# 1. Home visible dirs
(
  echo "=== HOME VISIBLE DIRS ==="
  for d in "$HOME_DIR"/*/; do
    [ -d "$d" ] || continue
    du -sh "$d" 2>/dev/null
  done | sort -rh
  echo ""
) > "$TMPDIR_SCAN/01-home-visible" 2>/dev/null &

# 2. Home dotfiles
(
  echo "=== HOME DOTFILES ==="
  total_file=$(mktemp)
  echo 0 > "$total_file"
  for d in "$HOME_DIR"/.[!.]*; do
    [ -e "$d" ] || continue
    line=$(du -sk "$d" 2>/dev/null)
    size_kb=$(echo "$line" | awk '{print $1}')
    size_h=$(du -sh "$d" 2>/dev/null | awk '{print $1}')
    if [ "${size_kb:-0}" -gt 10240 ] 2>/dev/null; then
      printf '%s\t%s\n' "$size_h" "$d"
    fi
    prev=$(cat "$total_file")
    echo $((prev + ${size_kb:-0})) > "$total_file"
  done | sort -rh
  total_dot=$(cat "$total_file")
  rm -f "$total_file"
  printf '\nDotfiles total: %s\n' "$(echo "$total_dot" | awk '{if ($1>1048576) printf "%.1fG", $1/1048576; else if ($1>1024) printf "%.0fM", $1/1024; else printf "%dK", $1}')"
  echo ""
) > "$TMPDIR_SCAN/02-home-dotfiles" 2>/dev/null &

# 3. ~/Library breakdown
(
  echo "=== LIBRARY BREAKDOWN ==="
  if [ -d "$HOME_DIR/Library" ]; then
    du -sh "$HOME_DIR/Library" 2>/dev/null | awk '{printf "Library total: %s\n", $1}'
    echo "Top subdirs:"
    du -sh "$HOME_DIR/Library"/*/ 2>/dev/null | sort -rh | head -15
    echo ""
    if [ -d "$HOME_DIR/Library/Application Support" ]; then
      echo "Application Support detail:"
      du -sh "$HOME_DIR/Library/Application Support"/*/ 2>/dev/null | sort -rh | head -10
    fi
    echo ""
    if [ -d "$HOME_DIR/Library/Caches" ]; then
      echo "Caches detail:"
      du -sh "$HOME_DIR/Library/Caches"/*/ 2>/dev/null | sort -rh | head -10
    fi
  fi
  echo ""
) > "$TMPDIR_SCAN/03-library" 2>/dev/null &

# 4. /Applications
(
  echo "=== APPLICATIONS ==="
  du -sh /Applications/ 2>/dev/null | awk '{printf "Applications total: %s\n", $1}'
  du -sh /Applications/*/ 2>/dev/null | sort -rh | head -15
  echo ""
) > "$TMPDIR_SCAN/04-applications" 2>/dev/null &

# 5. System Library
(
  echo "=== SYSTEM LIBRARY ==="
  du -sh /Library/ 2>/dev/null | awk '{printf "System Library total: %s\n", $1}'
  du -sh /Library/*/ 2>/dev/null | sort -rh | head -10
  echo ""
) > "$TMPDIR_SCAN/05-sys-library" 2>/dev/null &

# 6. /opt and /private/var
(
  echo "=== OTHER SYSTEM ==="
  for d in /opt /private/var /private/tmp /usr/local; do
    [ -d "$d" ] && du -sh "$d" 2>/dev/null
  done
  echo ""
  if [ -d /opt/homebrew ]; then
    echo "Homebrew breakdown:"
    du -sh /opt/homebrew/Cellar/ /opt/homebrew/Caskroom/ /opt/homebrew/lib/ 2>/dev/null | sort -rh
  elif [ -d /usr/local/Homebrew ]; then
    echo "Homebrew breakdown:"
    du -sh /usr/local/Cellar/ /usr/local/Caskroom/ /usr/local/lib/ 2>/dev/null | sort -rh
  fi
  echo ""
) > "$TMPDIR_SCAN/06-system" 2>/dev/null &

# 7. Code projects + build artifacts (single traversal per code dir)
(
  echo "=== CODE PROJECTS ==="
  SEEN_INODES=""
  for codedir in "$HOME_DIR/code" "$HOME_DIR/Code" "$HOME_DIR/Projects" "$HOME_DIR/projects" "$HOME_DIR/Developer" "$HOME_DIR/dev" "$HOME_DIR/src"; do
    if [ -d "$codedir" ]; then
      inode=$(stat -f%i "$codedir" 2>/dev/null)
      case "$SEEN_INODES" in *":$inode:"*) continue ;; esac
      SEEN_INODES="$SEEN_INODES:$inode:"
      echo "Projects in $codedir:"
      du -sh "$codedir"/*/ 2>/dev/null | sort -rh | head -20
      echo ""
    fi
  done

  echo "=== BUILD ARTIFACTS & DEPENDENCIES ==="
  SEEN_INODES=""
  for codedir in "$HOME_DIR/code" "$HOME_DIR/Code" "$HOME_DIR/Projects" "$HOME_DIR/projects" "$HOME_DIR/Developer" "$HOME_DIR/dev" "$HOME_DIR/src"; do
    if [ -d "$codedir" ]; then
      inode=$(stat -f%i "$codedir" 2>/dev/null)
      case "$SEEN_INODES" in *":$inode:"*) continue ;; esac
      SEEN_INODES="$SEEN_INODES:$inode:"
    else continue; fi
    find "$codedir" -maxdepth 4 -type d \( \
      -name "node_modules" -o -name ".build" -o -name "build" -o \
      -name "dist" -o -name "Pods" -o -name ".gradle" -o \
      -name "DerivedData" -o -name ".next" -o -name ".expo" -o \
      -name "__pycache__" -o -name ".turbo" -o -name ".parcel-cache" \
    \) -prune 2>/dev/null | while read d; do
      size_kb=$(du -sk "$d" 2>/dev/null | awk '{print $1}')
      if [ "${size_kb:-0}" -gt 51200 ]; then
        size=$(du -sh "$d" 2>/dev/null | awk '{print $1}')
        printf '%s\t%s\n' "$size" "$d"
      fi
    done
  done | sort -rh
  echo ""
) > "$TMPDIR_SCAN/07-code" 2>/dev/null &

# 8. Large files (uses find+stat, not du — fast)
(
  echo "=== LARGE FILES >100MB ==="
  find "$HOME_DIR" -maxdepth 6 -type f -size +100M \
    ! -path "*/Library/*" ! -path "*/.Trash/*" \
    2>/dev/null | while read f; do
    size=$(stat -f%z "$f" 2>/dev/null)
    printf '%s\t%s\n' "$size" "$f"
  done | sort -rn | head -30 | awk -F'\t' '{
    sz=$1;
    if (sz>1073741824) printf "%.1f GB\t%s\n", sz/1073741824, $2;
    else printf "%.0f MB\t%s\n", sz/1048576, $2
  }'
  echo ""
) > "$TMPDIR_SCAN/08-large-files" 2>/dev/null &

# 9. Cleanable space (small dirs, fast du calls)
(
  echo "=== CLEANABLE SPACE ==="
  for d in \
    "$HOME_DIR/.cache/huggingface" "$HOME_DIR/.cache/uv" \
    "$HOME_DIR/.cache/puppeteer" "$HOME_DIR/.cache/torch" \
    "$HOME_DIR/.cache/pip" "$HOME_DIR/.npm" "$HOME_DIR/.bun" \
    "$HOME_DIR/.gradle" "$HOME_DIR/.m2" "$HOME_DIR/.colima" \
    "$HOME_DIR/.codex/worktrees" "$HOME_DIR/.cargo/registry" \
    "$HOME_DIR/Library/Caches" \
    "$HOME_DIR/Library/Developer/Xcode/DerivedData" \
    "/Library/Developer/CoreSimulator/Volumes" \
    "/Library/Developer/CoreSimulator/Images" \
  ; do
    [ -d "$d" ] && du -sh "$d" 2>/dev/null | awk -v path="$d" '{printf "%s\t%s\n", $1, path}'
  done | sort -rh
  echo ""
  echo "=== VIRTUAL MACHINES & CONTAINERS ==="
  for d in "$HOME_DIR/.colima" "$HOME_DIR/.lima" \
    "$HOME_DIR/Library/Containers/com.docker.docker" \
    "$HOME_DIR/.docker" "$HOME_DIR/.orbstack"; do
    [ -d "$d" ] && du -sh "$d" 2>/dev/null | awk -v path="$d" '{printf "%s\t%s\n", $1, path}'
  done
  echo ""
) > "$TMPDIR_SCAN/09-cleanable" 2>/dev/null &

# ── Wait for all parallel jobs, then output in order ──
wait

for f in "$TMPDIR_SCAN"/0*; do
  cat "$f"
done

echo "=== SCAN COMPLETE ==="
