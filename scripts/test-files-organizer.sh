#!/bin/bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
FIXTURE=$(mktemp -d)
trap 'rm -rf "$FIXTURE"' EXIT

mkdir -p "$FIXTURE/alpha" "$FIXTURE/beta"
printf 'same duplicate payload\n' > "$FIXTURE/alpha/report.txt"
printf 'same duplicate payload\n' > "$FIXTURE/beta/report.txt"
printf 'a standalone note\n' > "$FIXTURE/alpha/note.md"

duplicates=$(bash "$ROOT_DIR/plugins/files-organizer/scripts/find-duplicates.sh" "$FIXTURE" 1)
grep -q "Duplicate groups found: 1" <<< "$duplicates"
grep -q "$FIXTURE/alpha/report.txt" <<< "$duplicates"
grep -q "$FIXTURE/beta/report.txt" <<< "$duplicates"

inventory=$(bash "$ROOT_DIR/plugins/files-organizer/scripts/scan-files.sh" "$FIXTURE" 5)
grep -q $'PATH\tSIZE_BYTES\tEXTENSION\tMODIFIED' <<< "$inventory"
grep -q "$FIXTURE/alpha/note.md" <<< "$inventory"
grep -q "=== EXTENSION CENSUS ===" <<< "$inventory"

similar=$(bash "$ROOT_DIR/plugins/files-organizer/scripts/similar-names.sh" "$FIXTURE" 4)
grep -q "'report' found in 2 directories" <<< "$similar"
grep -q "$FIXTURE/alpha/report.txt" <<< "$similar"
grep -q "$FIXTURE/beta/report.txt" <<< "$similar"

echo "File-organizer fixture tests passed."
