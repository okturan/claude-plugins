---
description: Run a comprehensive health audit on the current repository
argument-hint: [--category git|structure|code|config|data|docs|testing|deps|security]
allowed-tools: Read, Bash, Glob, Grep
---

Run a full health audit on the current working directory's git repository. Score it out of 100 across 9 categories and suggest concrete improvements.

Arguments: $ARGUMENTS

If a `--category` argument is provided, run only that single category audit and show its detailed breakdown. Otherwise, run all 9 categories.

**Procedure:**

1. Verify the current directory is a git repository. If not, tell the user and stop.

2. Load the repo-audit skill for the full list of categories, diagnostic commands, scoring criteria, and report format.

3. Run the diagnostic commands for all categories (or the specified one). All 9 categories are independent — run their commands in parallel for speed.

4. Score each category against its rubric, then present the report as specified in the skill.
