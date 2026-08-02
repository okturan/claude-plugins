#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
checker="$repo_root/plugins/shape-the-work/skills/shape-the-work/scripts/check-dependencies.sh"
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/shape-work-test.XXXXXX")"
fixture_root="$(cd "$fixture_root" && pwd -P)"

cleanup() {
  if [[ -n "${fixture_root:-}" && -d "$fixture_root" ]]; then
    rm -rf -- "$fixture_root"
  fi
}
trap cleanup EXIT

assert_contains() {
  local actual="$1"
  local expected="$2"
  if [[ "$actual" != *"$expected"* ]]; then
    printf 'Expected output to contain: %s\n\nActual output:\n%s\n' "$expected" "$actual" >&2
    exit 1
  fi
}

project_root="$fixture_root/project"
start_directory="$project_root/services/api"
fake_home="$fixture_root/home"

mkdir -p \
  "$start_directory" \
  "$project_root/.codex/skills/openspec-explore" \
  "$fake_home/.agents/skills/wayfinder"

touch \
  "$project_root/.codex/skills/openspec-explore/SKILL.md" \
  "$fake_home/.agents/skills/wayfinder/SKILL.md"

json_output="$(
  SHAPE_WORK_HOME_ROOT="$fake_home" \
  SHAPE_WORK_CODEX_ROOT="$fake_home/.codex" \
  bash "$checker" --json "$start_directory"
)"

assert_contains "$json_output" '"name": "openspec-explore", "status": "present"'
assert_contains "$json_output" "$project_root/.codex/skills/openspec-explore/SKILL.md"
assert_contains "$json_output" '"name": "wayfinder", "status": "present"'
assert_contains "$json_output" "$fake_home/.agents/skills/wayfinder/SKILL.md"
assert_contains "$json_output" '"name": "long-horizon-prompting", "status": "missing", "path": null'

mkdir -p "$project_root/.claude/skills/long-horizon-prompting"
touch "$project_root/.claude/skills/long-horizon-prompting/SKILL.md"

text_output="$(
  SHAPE_WORK_HOME_ROOT="$fake_home" \
  SHAPE_WORK_CODEX_ROOT="$fake_home/.codex" \
  bash "$checker" "$start_directory"
)"

assert_contains "$text_output" $'present\tlong-horizon-prompting\t'
assert_contains "$text_output" "$project_root/.claude/skills/long-horizon-prompting/SKILL.md"

if bash "$checker" "$fixture_root/does-not-exist" >/dev/null 2>&1; then
  printf 'Expected a missing start directory to fail.\n' >&2
  exit 1
fi

printf 'shape-the-work dependency checks passed.\n'
