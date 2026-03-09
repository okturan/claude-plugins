# project-health

A Claude Code plugin for auditing any code repository.

Scores repos out of 100 across 9 categories. Language-agnostic — works on any git repo with Python, JavaScript, TypeScript, Go, Rust, or Java.

## Commands

### `/project-health`

Full audit of the current repository. Runs all 9 categories in parallel, scores each, and presents an actionable report with concrete improvements.

### `/project-health --category <name>`

Audit a single category. Valid names: `git`, `structure`, `code`, `config`, `data`, `docs`, `testing`, `deps`, `security`.

## Categories

| Category | Max Points | What it checks |
|----------|-----------|----------------|
| Repository & Git | 15 | Remotes, clean tree, commit messages, large blobs, branching |
| Project Structure | 15 | Separation of concerns, naming, clutter, config/data/code split |
| Code Quality | 15 | God files, style consistency, docs, dead code, type annotations |
| Config & Environment | 10 | .gitignore, credentials, .env.example, packaging config |
| Data & Database | 10 | Stale DBs, migrations, data file organization |
| Documentation | 10 | README, LICENSE, CHANGELOG, AI-aware docs, code docs |
| Testing & CI | 15 | Tests, CI/CD, linting, pre-commit hooks |
| Dependencies | 5 | Pinned versions, unused deps, runtime version, lock files |
| Security | 5 | Hardcoded secrets, sensitive file permissions, auth scopes |

## Example Output

```
.-----------------------------------------------.
|          PROJECT HEALTH REPORT                 |
|          my-project                            |
'-----------------------------------------------'

  OVERALL SCORE: 72 / 100

  BREAKDOWN
  ---------------------------------------------
  Category                Score    Status
  ---------------------------------------------
  Repository & Git        12/15    [########--]
  Project Structure       13/15    [#########-]
  Code Quality            10/15    [#######---]
  Config & Environment     8/10    [########--]
  Data & Database          8/10    [########--]
  Documentation            6/10    [######----]
  Testing & CI             5/15    [###-------]
  Dependencies             5/5     [##########]
  Security                 5/5     [##########]
  ---------------------------------------------

  TOP IMPROVEMENTS (by impact)
  ---------------------------------------------
  1. [+6 pts] Add test suite for core modules
     -> Create tests/ directory with pytest setup

  2. [+4 pts] Set up CI pipeline
     -> Add .github/workflows/ci.yml with lint + test

  STRENGTHS
  ---------------------------------------------
  - Clean git history with descriptive commits
  - All dependencies pinned with versions
  - No secrets or credentials in codebase
```

## Components

```
project-health/
  .claude-plugin/plugin.json
  commands/
    project-health.md    # /project-health command
  skills/
    repo-audit/          # 9-category audit methodology (Claude-only)
      SKILL.md
```

## Requirements

- Any git repository
- Claude Code with plugin support

## License

MIT
