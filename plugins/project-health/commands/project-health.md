---
description: Run a comprehensive health audit on the current repository
argument-hint: [--category git|structure|code|config|data|docs|testing|deps|security]
allowed-tools: Read, Bash, Glob, Grep
---

Run a full health audit on the current working directory's git repository. Score it out of 100 across 9 categories and suggest concrete improvements.

Arguments: $ARGUMENTS

If a `--category` argument is provided, run only that single category audit and show its detailed breakdown. Otherwise, run all 9 categories.

**Procedure:**

1. Verify the current directory is a git repository. If not, tell the user and stop.

2. Load the repo-audit skill for detailed audit procedures and scoring criteria.

3. Run all 9 audit categories (or the specified one):
   - Repository & Git Health (15 pts)
   - Project Structure & Organization (15 pts)
   - Code Quality (15 pts)
   - Configuration & Environment (10 pts)
   - Data & Database (10 pts)
   - Documentation (10 pts)
   - Testing & CI (15 pts)
   - Dependencies & Packaging (5 pts)
   - Security (5 pts)

4. For each category, run the diagnostic commands, evaluate against the scoring criteria, and assign a score.

5. Present the final report in a clean ASCII table with:
   - Overall score out of 100
   - Per-category scores with progress bars
   - Top improvements sorted by point impact
   - Strengths section

6. Be honest and specific. Each improvement must have a concrete next step.

This is a **read-only** audit — do not modify any files.
