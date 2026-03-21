---
name: codex-cli
description: This skill should be used when the user asks to "build a codex command", "codex flags", "how to use codex", "codex cli", "codex syntax", "what does codex do", "codex help", "explain codex", or has questions about Codex CLI command structure, flags, or usage patterns. Provides complete knowledge of the Codex CLI (v0.116.0) command structure, flags, usage patterns, and sandbox/approval policies so that commands can be constructed correctly without consulting help pages. Do NOT trigger this skill for action requests like "run codex", "check with codex", "use codex", "codex review", "codex exec", or "delegate to codex" — those should invoke the `/codex-cli:codex` command instead.
---

**ACTION ROUTING:** If the user wants to **run** Codex (any action like "try again", "review", "check", "delegate", "use codex"), stop reading these docs and immediately run the `/codex-cli:codex` command. This skill is only for answering questions about Codex CLI syntax and flags.

# Codex CLI Quick Reference

Codex CLI (`codex`) is OpenAI's command-line coding agent. It runs interactively or non-interactively, can review code, manage sessions, connect MCP servers, and delegate tasks to cloud infrastructure.

## Default Model

Default flags for every codex invocation: `-m gpt-5.4 -c reasoning.effort="xhigh"`

Only use a different model if the user explicitly requests it.

## Core Commands

### Running Tasks

**Interactive** (opens TUI):
```bash
codex -m gpt-5.4 -c reasoning.effort="xhigh" "describe the task"
```

**Non-interactive** (`exec`):
```bash
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec "task description"
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec --full-auto "task"
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec --json "structured output"
echo "task" | codex -m gpt-5.4 -c reasoning.effort="xhigh" exec -
```

### Code Review (non-interactive)

```bash
codex -m gpt-5.4 -c reasoning.effort="xhigh" review --uncommitted
codex -m gpt-5.4 -c reasoning.effort="xhigh" review --base main
codex -m gpt-5.4 -c reasoning.effort="xhigh" review --commit abc123
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec --json review --uncommitted
```

Both `codex review` and `codex exec review` are non-interactive. Use `codex exec review` when additional exec flags are needed (e.g., `--json`, `-o`).

### Session Management

```bash
codex -m gpt-5.4 -c reasoning.effort="xhigh" resume --last
codex -m gpt-5.4 -c reasoning.effort="xhigh" resume <SESSION_ID> "follow-up"
codex -m gpt-5.4 -c reasoning.effort="xhigh" fork --last "try different approach"
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec resume --last "continue"
```

## Flag Placement

Three categories with strict placement rules:

| Category | Flags | Placement |
|----------|-------|-----------|
| Global-only | `-s`, `-a`, `--search`, `--oss` | Before the subcommand only |
| Flexible | `-m`, `-C`, `-c`, `-i`, `--full-auto` | Before or after subcommand |
| Exec-specific | `--skip-git-repo-check`, `--json`, `-o`, `--ephemeral` | After `exec` only |

`--full-auto` is an alias for `-a on-request --sandbox workspace-write`.

For `codex exec review`, exec-specific flags work between `exec` and `review`, or after `review`.

```
codex [GLOBAL-ONLY / FLEXIBLE FLAGS] exec [EXEC-SPECIFIC / FLEXIBLE FLAGS] "prompt"
```

## MCP Server Management

```bash
codex mcp list                                         # list servers
codex mcp add my-server -- node server.js              # add stdio server
codex mcp add my-server --url https://example.com/mcp  # add HTTP server
codex mcp remove my-server                             # remove server
codex mcp-server                                       # start codex AS an MCP server
```

## Other Commands

- `codex apply <TASK_ID>` — Apply a diff as `git apply` to the local working tree
- `codex completion <SHELL>` — Generate shell completions (bash, zsh, fish, powershell, elvish)
- `codex features list` — Inspect feature flags and their state
- `codex cloud exec --env <ENV_ID> "task"` — Submit cloud task (experimental)

## Constructing Commands

1. **Set the model**: `-m gpt-5.4 -c reasoning.effort="xhigh"` before the subcommand
2. **Choose mode**: `codex exec` for non-interactive, plain `codex` for TUI
3. **Check for git repo**: If not a git repo, add `--skip-git-repo-check` after `exec`
4. **Choose sandbox**: Default to `--full-auto`. Use `--sandbox danger-full-access` only when explicitly needed
5. **Pass the prompt**: As a positional argument or pipe via stdin with `-`
6. **Capture output**: Use `--json` for JSONL events, `-o file` to save last message

## Troubleshooting

**"Not inside a trusted directory" error**: The directory is not a git repo. Add `--skip-git-repo-check` after `exec`:
```bash
codex -m gpt-5.4 -c reasoning.effort="xhigh" exec --skip-git-repo-check --full-auto "task"
```
`--skip-git-repo-check` is exec-specific — it goes after `exec`, not before it.

**"unexpected argument" error**: A flag is in the wrong position. Global-only flags go before the subcommand, exec-specific flags go after `exec`.

## Additional Resources

For the complete command tree, all flags, config overrides, and troubleshooting:
- **`references/full-reference.md`**
