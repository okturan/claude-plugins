# project-health

Deep audit any code repository with a score out of 100. Language-agnostic, works on any git repo.

## Categories (9)

| Category | Max Points |
|----------|-----------|
| Repository & Git | 15 |
| Project Structure | 15 |
| Code Quality | 15 |
| Config & Environment | 10 |
| Data & Database | 10 |
| Documentation | 10 |
| Testing & CI | 15 |
| Dependencies | 5 |
| Security | 5 |

## Usage

```
/project-health                        # Full audit
/project-health --category testing     # Single category
```

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

## Installation

```
/install-plugin okturan/claude-plugins:project-health
```

Or add to your project manually:
```bash
claude --plugin-dir /path/to/project-health
```
