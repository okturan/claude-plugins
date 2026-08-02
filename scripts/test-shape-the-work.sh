#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
checker="$repo_root/plugins/shape-the-work/skills/shape-the-work/scripts/check-dependencies.sh"
fake_openspec="$repo_root/scripts/fixtures/shape-work-openspec"
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

assert_status() {
  local output="$1"
  local skill_name="$2"
  local expected_status="$3"
  # JavaScript source is intentionally single-quoted so Bash does not expand it.
  # shellcheck disable=SC2016
  SHAPE_WORK_OUTPUT="$output" node -e '
const value = JSON.parse(process.env.SHAPE_WORK_OUTPUT);
const skill = value.skills.find(item => item.name === process.argv[1]);
if (!skill) throw new Error(`missing result for ${process.argv[1]}`);
if (skill.status !== process.argv[2]) {
  throw new Error(`${process.argv[1]}: expected ${process.argv[2]}, received ${skill.status}`);
}
' "$skill_name" "$expected_status"
}

run_checker() {
  FAKE_OPENSPEC_ROOT="${FAKE_OPENSPEC_ROOT:-$project_root}" \
  FAKE_OPENSPEC_FAIL="${FAKE_OPENSPEC_FAIL:-0}" \
  SHAPE_WORK_HOME_ROOT="$fake_home" \
  SHAPE_WORK_CODEX_ROOT="$fake_home/.codex" \
  PATH="$fake_bin:$PATH" \
  bash "$checker" --json "$start_directory"
}

project_root="$fixture_root/project"
start_directory="$project_root/services/api"
fake_home="$fixture_root/home"
fake_bin="$fixture_root/bin"

mkdir -p \
  "$start_directory" \
  "$project_root/.codex/skills/openspec-explore" \
  "$fake_home/.agents/skills/wayfinder" \
  "$fake_bin"

touch \
  "$project_root/.codex/skills/openspec-explore/SKILL.md" \
  "$fake_home/.agents/skills/wayfinder/SKILL.md"

ln -s "$fake_openspec" "$fake_bin/openspec"
git -C "$project_root" init -q

json_output="$(run_checker)"
assert_status "$json_output" "openspec-explore" "ready"
assert_status "$json_output" "wayfinder" "needs-setup"
assert_status "$json_output" "long-horizon-prompting" "missing"
assert_contains "$json_output" 'missing required: grilling, domain-modeling, docs/agents/issue-tracker.md contract'
assert_contains "$json_output" 'setup helper setup-matt-pocock-skills not found'

mkdir -p \
  "$project_root/.agents/skills/grilling" \
  "$project_root/.agents/skills/domain-modeling" \
  "$project_root/docs/agents"
touch \
  "$project_root/.agents/skills/grilling/SKILL.md" \
  "$project_root/.agents/skills/domain-modeling/SKILL.md"
printf '# Agent issue tracker\n\n## Wayfinding operations\n\nUse the configured tracker.\n' \
  > "$project_root/docs/agents/issue-tracker.md"

json_output="$(run_checker)"
assert_status "$json_output" "wayfinder" "ready"
assert_contains "$json_output" 'optional ticket skills missing: research, prototype'

long_horizon_directory="$project_root/.claude/skills/long-horizon-prompting"
mkdir -p "$long_horizon_directory/references"
touch \
  "$long_horizon_directory/SKILL.md" \
  "$long_horizon_directory/references/task-brief-template.md" \
  "$long_horizon_directory/references/vendor-guidance.md" \
  "$long_horizon_directory/references/research-evidence.md" \
  "$long_horizon_directory/references/cdc-prompt-annotated.md"

json_output="$(run_checker)"
assert_status "$json_output" "long-horizon-prompting" "ready"
assert_contains "$json_output" 'execution machinery is separate'

FAKE_OPENSPEC_ROOT="$fixture_root" json_output="$(run_checker)"
assert_status "$json_output" "openspec-explore" "needs-context-check"
assert_contains "$json_output" "differs from target Git root $project_root"

FAKE_OPENSPEC_FAIL=1 json_output="$(run_checker)"
assert_status "$json_output" "openspec-explore" "needs-setup"
assert_contains "$json_output" 'openspec list --json failed from the target directory'

without_openspec_output="$(
  SHAPE_WORK_HOME_ROOT="$fake_home" \
  SHAPE_WORK_CODEX_ROOT="$fake_home/.codex" \
  PATH="/usr/bin:/bin" \
  /bin/bash "$checker" --json "$start_directory"
)"
assert_status "$without_openspec_output" "openspec-explore" "needs-setup"
assert_contains "$without_openspec_output" 'openspec CLI not found'

text_output="$(
  FAKE_OPENSPEC_ROOT="$project_root" \
  SHAPE_WORK_HOME_ROOT="$fake_home" \
  SHAPE_WORK_CODEX_ROOT="$fake_home/.codex" \
  PATH="$fake_bin:$PATH" \
  bash "$checker" "$start_directory"
)"
assert_contains "$text_output" $'ready\tlong-horizon-prompting\t'
assert_contains "$text_output" $'STATUS\tSKILL\tPATH\tDETAIL'

if bash "$checker" "$fixture_root/does-not-exist" >/dev/null 2>&1; then
  printf 'Expected a missing start directory to fail.\n' >&2
  exit 1
fi

printf 'shape-the-work dependency checks passed.\n'
