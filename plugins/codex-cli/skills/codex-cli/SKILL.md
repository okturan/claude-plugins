---
name: codex-cli
description: This skill should be used when the user asks to "build a codex command", "codex flags", "how to use codex", "codex cli", "codex syntax", "what does codex do", "codex help", "explain codex", or has questions about Codex CLI command structure, flags, or usage patterns. Provides complete knowledge of the Codex CLI (v0.114.0) command structure, flags, usage patterns, and sandbox/approval policies so that commands can be constructed correctly without consulting help pages. Do NOT trigger this skill for action requests like "run codex", "check with codex", "use codex", "codex review", "codex exec", or "delegate to codex" — those should invoke the `/codex` command instead.
---

> **ACTION ROUTING:** If the user's intent is to **run** Codex (e.g., "check with codex", "run codex", "use codex to review", "delegate to codex"), do NOT just read these docs — invoke the `/codex` command via the Skill tool instead. This skill is for **learning about** Codex CLI, not for executing it.

# Codex CLI Knowledge

Codex CLI (`codex`) is OpenAI's command-line coding agent. It runs interactively or non-interactively, can review code, manage sessions, connect MCP servers, and delegate tasks to cloud infrastructure.

## Core Commands

### Running Tasks

**Interactive** (opens TUI):
```bash
codex "describe the task"
codex -m o3 "use a specific model"
```

**Non-interactive** (`exec`):
```bash
codex exec "task description"
codex exec --full-auto "task with auto-approval and workspace-write sandbox"
codex exec -m o3 --json "structured output"
echo "task" | codex exec -    # read from stdin
```

### Code Review (non-interactive)

```bash
codex review --uncommitted                    # review current changes
codex review --base main                      # review against branch
codex review --commit abc123                  # review a specific commit
codex exec review --uncommitted --json        # review with JSONL output
```

Note: Both `codex review` and `codex exec review` are non-interactive. Use `codex exec review` when additional exec flags are needed (e.g., `--json`, `-o`).

### Session Management

```bash
codex resume --last                           # continue most recent session
codex resume <SESSION_ID> "follow-up prompt"  # resume specific session
codex fork --last "try different approach"     # fork session as new branch
codex exec resume --last "continue in exec"   # resume in non-interactive mode
```

## Key Flags

### Global-only flags (MUST go BEFORE the subcommand)

These flags are rejected if placed after `exec`:

| Flag | Purpose |
|------|---------|
| `-s, --sandbox <MODE>` | `read-only` / `workspace-write` / `danger-full-access` |
| `-a, --ask-for-approval <POLICY>` | `untrusted` / `on-request` / `never` |
| `--search` | Enable web search tool |
| `--oss` | Use local model provider (LM Studio/Ollama) |

### Flexible flags (work before OR after `exec`)

| Flag | Purpose |
|------|---------|
| `-m, --model <MODEL>` | Select model (e.g., `o3`) |
| `-C, --cd <DIR>` | Set working directory |
| `-c, --config <key=value>` | Override config.toml values (dotted TOML paths) |
| `-i, --image <FILE>` | Attach image to prompt |
| `--full-auto` | Shorthand for `-a on-request -s workspace-write` |

### Exec-specific flags (MUST go AFTER `exec`)

These flags are rejected if placed before `exec`:

| Flag | Purpose |
|------|---------|
| `--skip-git-repo-check` | Allow running outside a Git repository |
| `--json` | Print events to stdout as JSONL |
| `-o, --output-last-message <FILE>` | Write last agent message to file |
| `--ephemeral` | Run without persisting session files |
| `--output-schema <FILE>` | JSON Schema file for structured response |

Note: For `codex exec review`, exec-specific flags like `--json` and `-o` can go either between `exec` and `review`, or after `review`. Both work.

## MCP Server Management

```bash
codex mcp list                                         # list servers
codex mcp add my-server -- node server.js              # add stdio server
codex mcp add my-server --url https://example.com/mcp  # add HTTP server
codex mcp add my-server --env KEY=val -- node server.js # with env vars
codex mcp remove my-server                             # remove server
codex mcp login my-server --scopes "read,write"        # OAuth auth
codex mcp-server                                       # start codex AS an MCP server
```

## Codex Cloud (Experimental)

```bash
codex cloud exec --env <ENV_ID> "task"       # submit cloud task
codex cloud list [--env <ENV_ID>] [--json]   # list tasks
codex cloud status <TASK_ID>                 # check status
codex cloud diff <TASK_ID> [--attempt N]     # view diff
codex cloud apply <TASK_ID> [--attempt N]    # apply changes locally
```

## Sandbox & Safety

Three sandbox modes control filesystem access:
- **read-only**: No writes allowed
- **workspace-write**: Writes within workspace only
- **danger-full-access**: Full filesystem access

Three approval policies control command execution:
- **untrusted**: Only trusted commands (ls, cat, sed) run without approval
- **on-request**: Model decides when to ask
- **never**: Never ask, failures go back to model

`--full-auto` combines `on-request` approval with `workspace-write` sandbox for the common "just do it safely" pattern.

Use `codex sandbox macos -- <cmd>` or `codex sandbox linux -- <cmd>` to run arbitrary commands inside the Codex sandbox without the agent.

## Authentication

Manage credentials with `codex login` and `codex logout`. Use `codex login status` to check current auth state. Pipe an API key via `printenv OPENAI_API_KEY | codex login --with-api-key`.

## Other Commands

- `codex apply <TASK_ID>` — Apply a diff produced by a Codex agent as `git apply` to the local working tree
- `codex completion <SHELL>` — Generate shell completions (bash, zsh, fish, powershell, elvish)
- `codex features list` — Inspect feature flags and their state

## Constructing Commands

When building a `codex` invocation:

**CRITICAL — flag placement rules:**
- **Global-only flags** (`--search`, `-s`, `-a`) MUST go **BEFORE** the subcommand
- **Exec-specific flags** (`--skip-git-repo-check`, `--json`, `-o`, `--ephemeral`) MUST go **AFTER** `exec`
- **Flexible flags** (`-m`, `-C`, `-c`, `-i`, `--full-auto`) work in either position
- Getting this wrong causes `unexpected argument` errors

```
codex [GLOBAL-ONLY / FLEXIBLE FLAGS] exec [EXEC-SPECIFIC / FLEXIBLE FLAGS] "prompt"
```

**Correct examples:**
```bash
codex -m o3 exec --full-auto "task"                          # -m before exec (works)
codex exec -m o3 --full-auto "task"                          # -m after exec (also works)
codex exec --skip-git-repo-check --full-auto "task"          # exec flag after exec
codex -m o3 exec --skip-git-repo-check --full-auto "task"    # combined
codex exec --json review --uncommitted                       # --json between exec and review
codex exec review --uncommitted --json                       # --json after review (also works)
```

**WRONG — will error:**
```bash
codex --skip-git-repo-check exec --full-auto "task"          # exec-specific before exec ✗
codex --json exec "task"                                      # exec-specific before exec ✗
codex exec --search "task"                                    # global-only after exec ✗
codex exec -a never "task"                                    # global-only after exec ✗
```

### Steps:
1. **Choose interactive vs non-interactive**: Use `codex exec` for scripted/automated use, plain `codex` for interactive TUI sessions
2. **Set the model** if needed: `-m o3` or via `-c model="model-name"` — place before subcommand
3. **Check for git repo**: If the directory is NOT a git repo, add `--skip-git-repo-check` AFTER `exec`
4. **Choose sandbox level**: Default to `--full-auto` for safe autonomous execution. Use `--sandbox danger-full-access` only when explicitly needed
5. **Pass the prompt**: As a positional argument or pipe via stdin with `-`
6. **Capture output**: Use `--json` for JSONL events, `-o file` to save last message

## Troubleshooting

### "Not inside a trusted directory" error
This means the current directory is not a git repository. Add `--skip-git-repo-check` **after** `exec`:
```bash
codex exec --skip-git-repo-check --full-auto "task"
```
**Do NOT** put `--skip-git-repo-check` before `exec` — it is an exec-specific flag.

## Additional Resources

For the complete command tree with every flag and subcommand, consult:
- **`references/full-reference.md`** — Exhaustive reference for all commands, flags, examples, config overrides, and common patterns
