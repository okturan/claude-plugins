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

git_root() {
  local root
  if root="$(git -C "$start_directory" rev-parse --show-toplevel 2>/dev/null)" && [[ -d "$root" ]]; then
    (cd "$root" && pwd -P)
    return 0
  fi
  return 1
}

path_is_within() {
  local child="$1"
  local parent="${2%/}"
  [[ -n "$parent" ]] || parent="/"

  if [[ "$parent" == "/" ]]; then
    [[ "$child" == /* ]]
  else
    [[ "$child" == "$parent" || "$child" == "$parent/"* ]]
  fi
}

join_items() {
  local result=""
  local item
  for item in "$@"; do
    if [[ -n "$result" ]]; then
      result="$result, $item"
    else
      result="$item"
    fi
  done
  printf '%s' "$result"
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
statuses=("" "" "")
paths=("" "" "")
details=("" "" "")

openspec_path=""
if openspec_path="$(find_skill "openspec-explore")"; then
  paths[0]="$openspec_path"
  if ! command -v openspec >/dev/null 2>&1; then
    statuses[0]="needs-setup"
    details[0]="openspec CLI not found"
  else
    openspec_version="$(openspec --version 2>/dev/null || true)"
    openspec_version="${openspec_version%%$'\n'*}"
    if ! openspec_output="$(cd "$start_directory" && openspec list --json 2>/dev/null)"; then
      statuses[0]="needs-setup"
      details[0]="openspec list --json failed from the target directory"
    else
      resolved_root="$(printf '%s' "$openspec_output" | node -e '
let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", chunk => { input += chunk; });
process.stdin.on("end", () => {
  try {
    const value = JSON.parse(input);
    if (typeof value?.root?.path === "string") process.stdout.write(value.root.path);
  } catch {}
});
' 2>/dev/null || true)"
      target_root="$(git_root || true)"

      if [[ -z "$resolved_root" ]]; then
        statuses[0]="needs-context-check"
        details[0]="openspec list --json did not report root.path; verify the project or named store manually"
      elif [[ ! -d "$resolved_root" ]]; then
        statuses[0]="needs-context-check"
        details[0]="OpenSpec resolved a missing root: $resolved_root"
      else
        resolved_root="$(cd "$resolved_root" && pwd -P)"
        if [[ -z "$target_root" ]]; then
          statuses[0]="needs-context-check"
          details[0]="OpenSpec root is $resolved_root; no target Git root was available for comparison"
        elif ! path_is_within "$resolved_root" "$target_root"; then
          statuses[0]="needs-context-check"
          details[0]="OpenSpec root $resolved_root is outside target Git root $target_root"
        elif ! path_is_within "$start_directory" "$resolved_root"; then
          statuses[0]="needs-context-check"
          details[0]="OpenSpec root $resolved_root does not contain target directory $start_directory"
        else
          statuses[0]="ready"
          if [[ -n "$openspec_version" ]]; then
            details[0]="openspec $openspec_version resolved target root $resolved_root"
          else
            details[0]="OpenSpec resolved target root $resolved_root"
          fi
        fi
      fi
    fi
  fi
else
  statuses[0]="missing"
  details[0]="openspec-explore skill not found"
fi

wayfinder_path=""
if wayfinder_path="$(find_skill "wayfinder")"; then
  paths[1]="$wayfinder_path"
  wayfinder_missing=()
  wayfinder_optional_missing=()
  tracker_problem=""

  if ! find_skill "grilling" >/dev/null; then
    wayfinder_missing+=("grilling")
  fi
  if ! find_skill "domain-modeling" >/dev/null; then
    wayfinder_missing+=("domain-modeling")
  fi

  target_root="$(git_root || true)"
  if [[ -z "$target_root" ]]; then
    tracker_problem="target Git root and docs/agents/issue-tracker.md contract"
  elif [[ ! -f "$target_root/docs/agents/issue-tracker.md" ]]; then
    tracker_problem="docs/agents/issue-tracker.md contract"
  elif ! grep -Eiq '^[[:space:]]*#{1,6}[[:space:]]+Wayfinding operations([[:space:]]|$)' "$target_root/docs/agents/issue-tracker.md"; then
    tracker_problem="Wayfinding operations section in docs/agents/issue-tracker.md"
  fi

  if [[ -n "$tracker_problem" ]]; then
    wayfinder_missing+=("$tracker_problem")
  fi

  if ! find_skill "research" >/dev/null; then
    wayfinder_optional_missing+=("research")
  fi
  if ! find_skill "prototype" >/dev/null; then
    wayfinder_optional_missing+=("prototype")
  fi

  if [[ "${#wayfinder_missing[@]}" -gt 0 ]]; then
    statuses[1]="needs-setup"
    details[1]="missing required: $(join_items "${wayfinder_missing[@]}")"
    if [[ -n "$tracker_problem" ]]; then
      if setup_path="$(find_skill "setup-matt-pocock-skills")"; then
        details[1]="${details[1]}; setup helper found at $setup_path"
      else
        details[1]="${details[1]}; setup helper setup-matt-pocock-skills not found"
      fi
    fi
  else
    statuses[1]="ready"
    details[1]="required companions and tracker contract found"
  fi

  if [[ "${#wayfinder_optional_missing[@]}" -gt 0 ]]; then
    details[1]="${details[1]}; optional ticket skills missing: $(join_items "${wayfinder_optional_missing[@]}")"
  fi
else
  statuses[1]="missing"
  details[1]="wayfinder skill not found"
fi

long_horizon_path=""
if long_horizon_path="$(find_skill "long-horizon-prompting")"; then
  paths[2]="$long_horizon_path"
  long_horizon_directory="$(dirname "$long_horizon_path")"
  long_horizon_missing=()
  for reference in \
    "task-brief-template.md" \
    "vendor-guidance.md" \
    "research-evidence.md" \
    "cdc-prompt-annotated.md"; do
    if [[ ! -f "$long_horizon_directory/references/$reference" ]]; then
      long_horizon_missing+=("references/$reference")
    fi
  done

  if [[ "${#long_horizon_missing[@]}" -gt 0 ]]; then
    statuses[2]="needs-setup"
    details[2]="missing required: $(join_items "${long_horizon_missing[@]}")"
  else
    statuses[2]="ready"
    details[2]="ready for brief authoring and audit; execution machinery is separate"
  fi
else
  statuses[2]="missing"
  details[2]="long-horizon-prompting skill not found"
fi

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
    printf '    {"name": "%s", "status": "%s", "path": %s, "detail": "%s"}%s\n' \
      "${skills[$index]}" \
      "${statuses[$index]}" \
      "$path_json" \
      "$(json_escape "${details[$index]}")" \
      "$separator"
  done
  printf '  ]\n}\n'
else
  printf 'STATUS\tSKILL\tPATH\tDETAIL\n'
  for index in "${!skills[@]}"; do
    printf '%s\t%s\t%s\t%s\n' \
      "${statuses[$index]}" \
      "${skills[$index]}" \
      "${paths[$index]:--}" \
      "${details[$index]}"
  done
fi
