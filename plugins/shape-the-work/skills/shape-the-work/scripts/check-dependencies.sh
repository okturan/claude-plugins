#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s [--json] [START_DIRECTORY]\n' "$(basename "$0")" >&2
}

output_format="text"
if [[ "${1:-}" == "--json" ]]; then
  output_format="json"
  shift
fi

if [[ "$#" -gt 1 ]]; then
  usage
  exit 2
fi

start_directory="${1:-$PWD}"
if [[ ! -d "$start_directory" ]]; then
  printf 'Start directory does not exist: %s\n' "$start_directory" >&2
  exit 2
fi

start_directory="$(cd "$start_directory" && pwd -P)"
skill_home_root="${SHAPE_WORK_HOME_ROOT:-$HOME}"
codex_root="${SHAPE_WORK_CODEX_ROOT:-${CODEX_HOME:-$skill_home_root/.codex}}"

find_skill() {
  local skill_name="$1"
  local cursor="$start_directory"
  local candidate

  while :; do
    for candidate in \
      "$cursor/.agents/skills/$skill_name/SKILL.md" \
      "$cursor/.codex/skills/$skill_name/SKILL.md" \
      "$cursor/.claude/skills/$skill_name/SKILL.md"; do
      if [[ -f "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return 0
      fi
    done

    [[ "$cursor" == "/" ]] && break
    cursor="$(dirname "$cursor")"
  done

  for candidate in \
    "$skill_home_root/.agents/skills/$skill_name/SKILL.md" \
    "$codex_root/skills/$skill_name/SKILL.md" \
    "$skill_home_root/.claude/skills/$skill_name/SKILL.md"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

skills=("openspec-explore" "wayfinder" "long-horizon-prompting")
statuses=()
paths=()

for skill_name in "${skills[@]}"; do
  if skill_path="$(find_skill "$skill_name")"; then
    statuses+=("present")
    paths+=("$skill_path")
  else
    statuses+=("missing")
    paths+=("")
  fi
done

if [[ "$output_format" == "json" ]]; then
  printf '{\n  "start_directory": "%s",\n  "skills": [\n' "$(json_escape "$start_directory")"
  for index in "${!skills[@]}"; do
    separator=","
    [[ "$index" -eq $((${#skills[@]} - 1)) ]] && separator=""
    if [[ -n "${paths[$index]}" ]]; then
      path_json="\"$(json_escape "${paths[$index]}")\""
    else
      path_json="null"
    fi
    printf '    {"name": "%s", "status": "%s", "path": %s}%s\n' \
      "${skills[$index]}" "${statuses[$index]}" "$path_json" "$separator"
  done
  printf '  ]\n}\n'
else
  printf 'STATUS\tSKILL\tPATH\n'
  for index in "${!skills[@]}"; do
    printf '%s\t%s\t%s\n' \
      "${statuses[$index]}" "${skills[$index]}" "${paths[$index]:--}"
  done
fi
