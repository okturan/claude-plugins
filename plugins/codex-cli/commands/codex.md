---
description: Run Codex CLI — review (no args) or exec (with args)
argument-hint: [task description]
allowed-tools: ["Bash(codex:*)"]
---

**Before running any codex command**, check if the current directory is a git repo:
```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```
If it returns anything other than "true", you MUST add `--skip-git-repo-check` after `exec` in all exec commands.

Determine the action based on arguments provided:

**If no arguments were provided** (`$ARGUMENTS` is empty):
Run a code review of uncommitted changes using Codex:

```bash
# In a git repo:
codex review --uncommitted

# NOT in a git repo — use exec review with --skip-git-repo-check:
codex exec --skip-git-repo-check review --uncommitted
```

Execute this command and present the review output to the user.

**If arguments were provided** (`$ARGUMENTS` is not empty):
Delegate the task to Codex in non-interactive mode with safe defaults:

```bash
# In a git repo:
codex exec --full-auto "$ARGUMENTS"

# NOT in a git repo:
codex exec --skip-git-repo-check --full-auto "$ARGUMENTS"
```

Execute this command and present the output to the user.

**Important — flag placement rules:**
- **Global-only flags** (`--search`, `-s`, `-a`) MUST go **before** the subcommand: `codex --search exec ...`
- **Exec-specific flags** (`--skip-git-repo-check`, `--json`, `-o`) MUST go **after** `exec`: `codex exec --skip-git-repo-check ...`
- **Flexible flags** (`-m`, `-C`, `-c`, `-i`, `--full-auto`) work in either position
- Mixing these up causes `unexpected argument` errors

**Other notes:**
- If the user's task description mentions a specific model (e.g., "use o3"), add `-m <model>` (works before or after `exec`)
- If the task mentions a specific directory, add `-C <dir>` (works before or after `exec`)
- If the task mentions web search, add `--search` **before** `exec` (global-only flag)
- Always show the constructed command before running it so the user can see exactly what will execute
- If codex is not installed, inform the user to install it: `npm install -g @openai/codex` or `brew install codex`
