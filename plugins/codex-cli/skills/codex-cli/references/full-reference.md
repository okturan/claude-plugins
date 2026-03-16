# Codex CLI Full Reference (v0.114.0)

## Complete Command Tree

```
codex [OPTIONS] [PROMPT]              # Interactive CLI
├── exec [PROMPT]                     # Non-interactive (aliases: e)
│   ├── resume [SESSION_ID] [PROMPT]  # Resume previous exec session
│   └── review [PROMPT]              # Code review in exec mode
├── review [PROMPT]                   # Code review (non-interactive)
├── login                             # Manage login
│   └── status                       # Show login status
├── logout                            # Remove credentials
├── mcp <COMMAND>                     # Manage MCP servers
│   ├── list [--json]
│   ├── get <NAME> [--json]
│   ├── add <NAME> (--url <URL> | -- <CMD>...)
│   ├── remove <NAME>
│   ├── login <NAME> [--scopes]
│   └── logout <NAME>
├── mcp-server                        # Start as MCP server (stdio)
├── app [PATH]                        # Launch desktop app
├── app-server [--listen <URL>]       # Experimental app server
│   ├── generate-ts
│   └── generate-json-schema
├── completion [SHELL]                # Shell completions (bash/zsh/fish/etc)
├── sandbox <COMMAND>                 # Run commands sandboxed
│   ├── macos [--full-auto] [--log-denials]   # Seatbelt
│   ├── linux [--full-auto]                   # Landlock+seccomp
│   └── windows                               # Restricted token
├── debug
│   └── app-server
├── apply <TASK_ID>                   # Apply latest diff (aliases: a)
├── resume [SESSION_ID] [PROMPT]      # Resume interactive session
├── fork [SESSION_ID] [PROMPT]        # Fork interactive session
├── cloud                             # Codex Cloud (experimental)
│   ├── exec --env <ENV_ID> [QUERY]
│   ├── status <TASK_ID>
│   ├── list [--env] [--limit] [--json]
│   ├── apply <TASK_ID> [--attempt]
│   └── diff <TASK_ID> [--attempt]
└── features                          # Feature flags
    ├── list
    ├── enable <NAME>
    └── disable <NAME>
```

## Global Options (available on most commands)

**IMPORTANT: Global flags must be placed BEFORE the subcommand.** For example: `codex -m o3 --search exec --full-auto "task"`, NOT `codex exec -m o3 --search "task"`.

| Flag | Description |
|------|-------------|
| `-m, --model <MODEL>` | Model the agent should use |
| `-s, --sandbox <MODE>` | Sandbox policy: `read-only`, `workspace-write`, `danger-full-access` |
| `-a, --ask-for-approval <POLICY>` | Approval policy: `untrusted`, `on-request`, `never` |
| `--full-auto` | Alias for `-a on-request --sandbox workspace-write` |
| `--dangerously-bypass-approvals-and-sandbox` | Skip all prompts, no sandbox. EXTREMELY DANGEROUS |
| `-c, --config <key=value>` | Override config value from `~/.codex/config.toml` |
| `--enable <FEATURE>` | Enable a feature flag |
| `--disable <FEATURE>` | Disable a feature flag |
| `-i, --image <FILE>...` | Attach image(s) to initial prompt |
| `-p, --profile <PROFILE>` | Config profile from config.toml |
| `-C, --cd <DIR>` | Set working directory |
| `--search` | Enable live web search tool |
| `--add-dir <DIR>` | Additional writable directories |
| `--no-alt-screen` | Inline mode (no alternate screen buffer) |
| `--oss` | Use local open source model provider (LM Studio or Ollama) |
| `--local-provider <PROVIDER>` | Specify local provider: `lmstudio` or `ollama` |

## Subcommand Details

### codex exec

Run Codex non-interactively. Prompt can be passed as argument or piped from stdin (use `-`).

**Exec-specific options:**

| Flag | Description |
|------|-------------|
| `--skip-git-repo-check` | Allow running outside a Git repository |
| `--ephemeral` | Run without persisting session files |
| `--output-schema <FILE>` | JSON Schema file for structured response |
| `--color <COLOR>` | Output color: `always`, `never`, `auto` |
| `--progress-cursor` | Force cursor-based progress updates |
| `--json` | Print events to stdout as JSONL |
| `-o, --output-last-message <FILE>` | Write last agent message to file |

**Examples:**
```bash
codex exec "refactor auth module to use JWT"
codex exec --full-auto "add unit tests for utils.py"
codex exec -m o3 "fix the failing CI tests"
echo "explain this codebase" | codex exec -
codex exec --output-schema schema.json "analyze dependencies"
```

### codex exec resume

Resume a previous exec session by ID or `--last`.

```bash
codex exec resume --last "continue fixing the tests"
codex exec resume <SESSION_ID> "now add error handling"
```

### codex exec review

Run code review in exec (non-interactive) mode.

```bash
codex exec review --uncommitted
codex exec review --base main
codex exec review --commit abc123
codex exec review --json -o review.md
```

### codex review

Run code review non-interactively.

| Flag | Description |
|------|-------------|
| `--uncommitted` | Review staged, unstaged, and untracked changes |
| `--base <BRANCH>` | Review changes against given base branch |
| `--commit <SHA>` | Review changes introduced by a commit |
| `--title <TITLE>` | Optional commit title for review summary |

**Examples:**
```bash
codex review --uncommitted
codex review --base main
codex review --commit abc1234
codex review --base develop "focus on security issues"
```

### codex resume

Resume a previous interactive session.

| Flag | Description |
|------|-------------|
| `--last` | Continue the most recent session |
| `--all` | Show all sessions (disables cwd filtering) |

```bash
codex resume --last
codex resume <SESSION_ID>
codex resume --last "now implement the error handling"
```

### codex fork

Fork a previous interactive session (new branch from existing conversation).

```bash
codex fork --last
codex fork <SESSION_ID> "try a different approach"
```

### codex login / logout

```bash
codex login                              # Interactive login
codex login --with-api-key               # Pipe API key from stdin
printenv OPENAI_API_KEY | codex login --with-api-key
codex login status                       # Show login status
codex logout                             # Remove credentials
```

### codex mcp

Manage external MCP (Model Context Protocol) servers.

```bash
# List configured servers
codex mcp list
codex mcp list --json

# Get server details
codex mcp get my-server
codex mcp get my-server --json

# Add stdio server
codex mcp add my-server -- node /path/to/server.js

# Add HTTP server
codex mcp add my-server --url https://example.com/mcp

# Add with env vars (stdio only)
codex mcp add my-server --env API_KEY=xxx -- node server.js

# Add HTTP server with bearer token
codex mcp add my-server --url https://example.com/mcp --bearer-token-env-var MY_TOKEN

# Authenticate with OAuth
codex mcp login my-server --scopes "read,write"
codex mcp logout my-server

# Remove server
codex mcp remove my-server
```

### codex mcp-server

Start Codex itself as an MCP server over stdio.

```bash
codex mcp-server
```

### codex cloud (experimental)

Run tasks on Codex Cloud infrastructure.

```bash
# Submit a cloud task
codex cloud exec --env env_123 "fix the login bug"
codex cloud exec --env env_123 --branch feature/auth --attempts 3 "add OAuth support"

# List cloud tasks
codex cloud list
codex cloud list --env env_123 --limit 5 --json

# Check task status
codex cloud status task_abc123

# View diff from cloud task
codex cloud diff task_abc123
codex cloud diff task_abc123 --attempt 2

# Apply cloud task changes locally
codex cloud apply task_abc123
codex cloud apply task_abc123 --attempt 2
```

### codex apply

Apply the latest diff produced by a Codex agent as `git apply` to the local working tree.

```bash
codex apply <TASK_ID>
```

### codex sandbox

Run commands within Codex-provided sandbox.

```bash
# macOS (Seatbelt)
codex sandbox macos -- npm test
codex sandbox macos --full-auto -- python script.py
codex sandbox macos --log-denials -- make build

# Linux (Landlock+seccomp)
codex sandbox linux -- cargo test
codex sandbox linux --full-auto -- ./run.sh
```

### codex app

Launch the Codex desktop application.

```bash
codex app              # Open current directory
codex app /path/to/project
```

### codex app-server

Start the app server (experimental).

```bash
codex app-server                           # stdio transport (default)
codex app-server --listen ws://0.0.0.0:8080  # WebSocket transport
codex app-server generate-ts               # Generate TypeScript bindings
codex app-server generate-json-schema      # Generate JSON Schema
```

### codex features

Manage feature flags.

```bash
codex features list           # Show all features with state
codex features enable <NAME>  # Enable in config.toml
codex features disable <NAME> # Disable in config.toml
```

### codex completion

Generate shell completion scripts.

```bash
codex completion bash > /etc/bash_completion.d/codex
codex completion zsh > ~/.zfunc/_codex
codex completion fish > ~/.config/fish/completions/codex.fish
```

## Config Override Examples

The `-c` flag accepts dotted TOML paths:

```bash
codex -c model="o3" "do something"
codex -c 'sandbox_permissions=["disk-full-read-access"]' exec "task"
codex -c shell_environment_policy.inherit=all exec "task"
codex -c model_provider=oss --oss "use local model"
```

## Approval Policies Explained

| Policy | Behavior |
|--------|----------|
| `untrusted` | Only trusted commands (ls, cat, sed) run without approval. Others escalate to user |
| `on-request` | Model decides when to ask for approval |
| `on-failure` | DEPRECATED. Run all, ask only on failure. Prefer `on-request` or `never` |
| `never` | Never ask. Failures returned directly to model |

## Sandbox Modes Explained

| Mode | Behavior |
|------|----------|
| `read-only` | Model can only read files, no writes |
| `workspace-write` | Model can write within the workspace |
| `danger-full-access` | Full filesystem access. No restrictions |

## Common Patterns

### Quick code review of uncommitted work
```bash
codex review --uncommitted
```

### Delegate a task non-interactively with full automation
```bash
codex exec --full-auto "add input validation to all API endpoints"
```

### Use a specific model
```bash
codex -m o3 "explain this codebase architecture"
```

### Review changes against main branch
```bash
codex review --base main
```

### Non-interactive review with JSON output
```bash
codex exec review --uncommitted --json -o review-output.md
```

### Resume the last session
```bash
codex resume --last
```

### Run in a different directory
```bash
codex -C /path/to/project exec "fix the tests"
```
