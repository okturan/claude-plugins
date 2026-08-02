---
description: Score the current repository against nine documented categories
argument-hint: [--category git|structure|code|config|data|docs|testing|deps|security]
allowed-tools: Read, Bash, Glob, Grep
---

Score the current working directory's Git repository out of 100 across nine categories. Show the evidence behind each deduction and give a concrete next step.

Arguments: $ARGUMENTS

If a `--category` argument is provided, run only that single category audit and show its detailed breakdown. Otherwise, run all 9 categories.

**Procedure:**

1. Verify the current directory is a git repository. If not, tell the user and stop.

2. Load the repo-audit skill for the full list of categories, diagnostic commands, scoring criteria, and report format.

3. Run the diagnostic commands for all categories, or for the selected category. The nine categories are independent, so run their commands in parallel.

4. Score each category against its rubric, then present the report as specified in the skill.
