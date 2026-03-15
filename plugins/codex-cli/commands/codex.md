---
description: Run Codex CLI — review (no args) or exec (with args)
argument-hint: [task description]
allowed-tools: ["Bash(codex:*)"]
---

Determine the action based on arguments provided:

**If no arguments were provided** (`$ARGUMENTS` is empty):
Run a code review of uncommitted changes using Codex:

```bash
codex review --uncommitted
```

Execute this command and present the review output to the user.

**If arguments were provided** (`$ARGUMENTS` is not empty):
Delegate the task to Codex in non-interactive mode with safe defaults:

```bash
codex exec --full-auto "$ARGUMENTS"
```

Execute this command and present the output to the user.

**Important notes:**
- If the user's task description mentions a specific model (e.g., "use o3"), add `-m <model>` to the command
- If the task mentions a specific directory, add `-C <dir>`
- If the task mentions web search, add `--search`
- Always show the constructed command before running it so the user can see exactly what will execute
- If codex is not installed, inform the user to install it: `npm install -g @openai/codex` or `brew install codex`
