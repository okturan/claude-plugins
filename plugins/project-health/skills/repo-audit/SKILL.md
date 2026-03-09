---
name: repo-audit
description: "Comprehensive repository health audit methodology with 9 scoring categories and diagnostic procedures. Use this skill when performing a project health check, repo audit, code quality assessment, or when the /project-health command is invoked."
---

# Repository Audit

Methodology for auditing any git repository across 9 categories, scoring each, and producing an actionable report. All categories are independent — run their diagnostic commands in parallel.

Common exclusions for all `find`/`grep` commands: `.git`, `node_modules`, `.claude`, `__pycache__`, `.venv`, `vendor`, `dist`, `build`, `target`.

## Audit Categories

### 1. Repository & Git Health (15 pts)

```bash
git rev-list --count HEAD
git log --oneline -20
git remote -v
git branch -a
git status
git stash list
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print $3, $4}' | sort -rn | head -20
```

**Scoring:**
- Remote configured (3 pts)
- Clean working tree (3 pts)
- Descriptive commit messages (3 pts)
- No huge blobs in history — files > 10MB (3 pts)
- Sensible branching strategy (3 pts)

### 2. Project Structure & Organization (15 pts)

```bash
ls -la
find . -maxdepth 2 -type d -not -path './.git/*' | sort
find . -type f -not -path './.git/*' -not -path './.claude/*' -not -path '*/node_modules/*' -not -path '*/__pycache__/*' -not -path '*/.venv/*' -not -path '*/vendor/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' | xargs ls -lhS 2>/dev/null | head -30
```

**Scoring:**
- Clear separation of concerns (4 pts)
- Logical module/directory naming (3 pts)
- No loose files that belong in subdirs (3 pts)
- Config/data/code properly separated (3 pts)
- No clutter — temp files, old backups, duplicates (2 pts)

### 3. Code Quality (15 pts)

Detect the primary language first, then run appropriate checks.

**For any language:**
```bash
# Line counts — only show files over 500 lines (god file candidates)
find . -type f \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.go' -o -name '*.rs' -o -name '*.java' \) -not -path '*/node_modules/*' -not -path './.git/*' -not -path '*/.venv/*' -exec wc -l {} + | awk '$1 > 500' | sort -rn
```

**Language-specific checks:**
- Python: imports, docstrings (`"""`), type hints, `TODO/FIXME/HACK` markers
- JavaScript/TypeScript: ESLint config, JSDoc, `console.log` left in, `any` type usage
- Go: `go vet`, exported function docs, error handling patterns
- Rust: `clippy` warnings, `unsafe` blocks, documentation
- General: dead code indicators (`pass`, commented-out blocks), consistency

**Scoring:**
- No god files (> 500 lines without good reason) (3 pts)
- Consistent code style (3 pts)
- Documentation on public interfaces (3 pts)
- No dead code or commented-out blocks (3 pts)
- Type annotations or equivalent (3 pts)

### 4. Configuration & Environment (10 pts)

```bash
ls .env .env.example .gitignore requirements.txt package.json pyproject.toml Cargo.toml go.mod 2>/dev/null
cat .gitignore 2>/dev/null
```

**Scoring:**
- Comprehensive .gitignore (3 pts)
- No credentials committed (3 pts) — use the sensitive-file scan from Category 9
- .env.example or equivalent provided (2 pts)
- Proper packaging config present (2 pts)

### 5. Data & Database (10 pts)

```bash
find . \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) -not -path './.git/*' -exec ls -lh {} \; 2>/dev/null
# Look for migration patterns
grep -rn 'CREATE TABLE\|ALTER TABLE\|migration\|schema_version' --include='*.py' --include='*.js' --include='*.ts' --include='*.go' --include='*.rs' --include='*.java' --include='*.sql' . 2>/dev/null | grep -v 'node_modules\|\.git' | head -20
```

**Scoring:**
- No stale/legacy databases checked in (3 pts)
- Migration system in place if DB exists (3 pts)
- Data files organized, not in root (2 pts)
- Reasonable DB sizes (2 pts)

If no database is used, award 8/10 by default (deduct only if data files are messy).

### 6. Documentation (10 pts)

```bash
ls README.md CHANGELOG.md CONTRIBUTING.md LICENSE CLAUDE.md .cursorrules .github/copilot-instructions.md 2>/dev/null
wc -l README.md 2>/dev/null
```

**Scoring:**
- README with setup instructions (3 pts)
- LICENSE present (2 pts)
- CHANGELOG or version history (2 pts)
- AI-aware docs (CLAUDE.md, etc.) (1 pt)
- Code-level documentation adequate (2 pts)

### 7. Testing & CI (15 pts)

```bash
find . -name 'test_*' -o -name '*_test.*' -o -name '*.test.*' -o -name '*_spec.*' -o -name 'conftest.py' 2>/dev/null | head -20
ls -d .github/workflows/ .circleci/ .travis.yml Jenkinsfile .flake8 .pylintrc ruff.toml .eslintrc* biome.json .pre-commit-config.yaml .husky/ 2>/dev/null
```

**Scoring:**
- Tests exist and cover core logic (5 pts)
- CI/CD pipeline configured (4 pts)
- Linting configured and enforced (3 pts)
- Pre-commit hooks or equivalent (3 pts)

### 8. Dependencies & Packaging (5 pts)

```bash
ls requirements.txt package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock go.sum .python-version .nvmrc .tool-versions 2>/dev/null
head -20 requirements.txt 2>/dev/null
```

**Scoring:**
- All deps pinned with versions (2 pts)
- No unused dependencies (1 pt)
- Runtime version documented (1 pt)
- Lock file committed (1 pt)

### 9. Security (5 pts)

```bash
# Sensitive files anywhere in the repo
find . -maxdepth 3 \( -name 'credentials*' -o -name 'token*' -o -name '*.pem' -o -name '*.key' -o -name '.env' \) -not -path './.git/*' 2>/dev/null
# Hardcoded secrets patterns
grep -rn 'api_key\|password\|secret\|token' --include='*.py' --include='*.js' --include='*.ts' --include='*.go' --include='*.rs' --include='*.java' . 2>/dev/null | grep -v 'node_modules\|\.git\|test_\|_test\.' | grep -v 'def \|#\|//\|import\|"""' | head -20
```

The sensitive-file scan here also serves Category 4 (credentials check) — no need to run it twice.

**Scoring:**
- No hardcoded secrets in code (2 pts)
- Sensitive files have restrictive permissions (1 pt)
- Auth scopes minimal / least privilege (1 pt)
- No secrets in git history (1 pt)

## Report Format

```
.-----------------------------------------------.
|          PROJECT HEALTH REPORT                 |
|          {repo-name}                           |
'-----------------------------------------------'

  OVERALL SCORE: XX / 100

  BREAKDOWN
  ---------------------------------------------
  Category                Score    Status
  ---------------------------------------------
  Repository & Git        __/15    [########--]
  Project Structure       __/15    [#########-]
  Code Quality            __/15    [#######---]
  Config & Environment    __/10    [########--]
  Data & Database         __/10    [##########]
  Documentation           __/10    [########--]
  Testing & CI            __/15    [----------]
  Dependencies            __/5     [####------]
  Security                __/5     [##########]
  ---------------------------------------------

  TOP IMPROVEMENTS (by impact)
  ---------------------------------------------
  1. [+N pts] Description of improvement
     -> Concrete action to take

  2. [+N pts] Description of improvement
     -> Concrete action to take

  STRENGTHS
  ---------------------------------------------
  - Thing the project does well
  - Another strength
```

Progress bars: 10 chars wide. `filled = round(score / max_score * 10)`. Use `#` for filled, `-` for empty.

## Notes

- Be honest and specific — vague "could be better" is useless
- Each improvement must have a concrete next step
- Acknowledge what's already good
- This is read-only analysis — never modify files
- Auto-detect the primary language and adapt checks accordingly
- Skip categories that don't apply (e.g., database for a pure frontend project) — award default points and note "N/A"
