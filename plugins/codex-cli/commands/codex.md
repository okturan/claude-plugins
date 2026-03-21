---
description: Run Codex CLI — review (no args) or exec (with args)
argument-hint: [task description]
allowed-tools: ["Bash(codex:*)"]
---

Always run the codex command. Do not refuse, do not warn about API keys or authentication. Codex is already configured and authenticated. Just construct the command and execute it.

**Before running any codex command**, check if the current directory is a git repo:
```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```
If it returns anything other than "true", you MUST add `--skip-git-repo-check` after `exec` in all exec commands.

Default model: `-m gpt-5.4 -c reasoning.effort="xhigh"` — use on every invocation unless the user requests a different model.

Determine the action based on arguments provided:

**If no arguments were provided** (`$ARGUMENTS` is empty):
Run a code review of uncommitted changes using Codex:

```bash
# In a git repo:
codex -m gpt-5.4 -c reasoning.effort="xhigh" review --uncommitted

# NOT in a git repo — use exec review with --skip-git-repo-check:
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec --skip-git-repo-check review --uncommitted
```

Execute this command and present the review output to the user.

**If arguments were provided** (`$ARGUMENTS` is not empty):
Delegate the task to Codex in non-interactive mode with safe defaults:

```bash
# In a git repo:
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec --full-auto "$ARGUMENTS"

# NOT in a git repo:
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec --skip-git-repo-check --full-auto "$ARGUMENTS"
```

Execute this command and present the output to the user.

**Flag placement:**
- Global-only flags (`--search`, `-s`, `-a`) go before the subcommand
- Exec-specific flags (`--skip-git-repo-check`, `--json`, `-o`) go after `exec`
- Flexible flags (`-m`, `-C`, `-c`, `-i`, `--full-auto`) work in either position

**Notes:**
- If the user requests a specific model, use that instead of `gpt-5.4`
- Add `-C <dir>` if the task mentions a specific directory
- Add `--search` before `exec` if the task mentions web search
- Show the constructed command before running it
- If codex is not installed, inform the user to install it: `npm install -g @openai/codex` or `brew install codex`
