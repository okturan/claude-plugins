---
name: codex-cli
description: This skill should be used when the user asks to "use codex", "run codex", "check with codex", "codex review", "codex exec", "delegate to codex", "get codex's opinion", "build a codex command", "codex flags", "how to use codex", mentions "codex cli", or references OpenAI's Codex CLI tool in any way. Provides complete knowledge of the Codex CLI (v0.114.0) command structure, flags, usage patterns, and sandbox/approval policies so that commands can be constructed correctly without consulting help pages.
---

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

| Flag | Purpose |
|------|---------|
| `-m, --model <MODEL>` | Select model (e.g., `o3`) |
| `-s, --sandbox <MODE>` | `read-only` / `workspace-write` / `danger-full-access` |
| `-a, --ask-for-approval <POLICY>` | `untrusted` / `on-request` / `never` |
| `--full-auto` | Shorthand for `-a on-request -s workspace-write` |
| `-C, --cd <DIR>` | Set working directory |
| `--search` | Enable web search tool |
| `-i, --image <FILE>` | Attach image to prompt |
| `-c, --config <key=value>` | Override config.toml values (dotted TOML paths) |
| `--oss` | Use local model provider (LM Studio/Ollama) |
| `--json` | Print events to stdout as JSONL (exec mode) |
| `-o, --output-last-message <FILE>` | Write last agent message to file (exec mode) |

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

**IMPORTANT:** Global flags (`-m`, `-C`, `--search`, `-s`, `-a`) must go BEFORE the subcommand. Example: `codex -m o3 --search exec --full-auto "task"`.

1. **Choose interactive vs non-interactive**: Use `codex exec` for scripted/automated use, plain `codex` for interactive TUI sessions
2. **Set the model** if needed: `-m o3` or via `-c model="model-name"` — place before subcommand
3. **Choose sandbox level**: Default to `--full-auto` for safe autonomous execution. Use `--sandbox danger-full-access` only when explicitly needed
4. **Pass the prompt**: As a positional argument or pipe via stdin with `-`
5. **Capture output**: Use `--json` for JSONL events, `-o file` to save last message

## Additional Resources

For the complete command tree with every flag and subcommand, consult:
- **`references/full-reference.md`** — Exhaustive reference for all commands, flags, examples, config overrides, and common patterns
