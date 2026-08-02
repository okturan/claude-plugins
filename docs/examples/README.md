# Example provenance

These captures show repository output, not invented product screens. Run `node scripts/render-plugin-examples.mjs` to rebuild the SVG files. CI runs the same script with `--check` and fails when a capture no longer matches its source.

## files-organizer

`files-organizer.svg` comes from a temporary three-file directory. Two files contain the same 23-byte payload. The third is different. The renderer runs `find-duplicates.sh` and checks the hash group and byte totals. It then replaces the temporary directory and timestamp with stable labels. The fixture matches the one in [`scripts/test-files-organizer.sh`](../../scripts/test-files-organizer.sh).

## project-health

`project-health.svg` records an audit of this repository at [`7e3e5d6`](https://github.com/okturan/claude-plugins/commit/7e3e5d6). The score follows the nine-category rubric in [`repo-audit`](../../plugins/project-health/skills/repo-audit/SKILL.md).

| Category | Score | Evidence for the snapshot |
|---|---:|---|
| Repository & Git | 15/15 | Configured remote, clean tree, descriptive history, no blob above 14 KB, and short-lived feature branches |
| Project Structure | 15/15 | Named directories hold the manifests, components, scripts, and docs. The tree contains no temporary files |
| Code Quality | 15/15 | No source file exceeds 500 lines. Command-line entry points document their use. A scan found no dead-code markers |
| Config & Environment | 10/10 | Repository-specific ignore rules and plugin packaging are present. The project needs no environment file or credential |
| Data & Database | 10/10 | N/A: the repository contains no database or application data |
| Documentation | 8/10 | Setup, license, security policy, and agent instructions are present. The project keeps no changelog |
| Testing & CI | 12/15 | CI enforces fixture tests and ShellCheck on macOS and Linux. The project has no local pre-commit check |
| Dependencies | 5/5 | The tools have no runtime package dependency. CI uses Node 22 and pins GitHub Actions by commit |
| Security | 5/5 | Scans found no credential-shaped files, hardcoded secret values, or sensitive filenames in history |

The two deductions are visible in the capture. This is a dated result, not a promise that every future commit will keep the same score.

## human-writing

`human-writing.svg` uses exact opening lines from the plugin README before and after commit [`1759db3`](https://github.com/okturan/claude-plugins/commit/1759db3). Reproduce the source diff with:

```bash
git diff 7ecdf43..1759db3 -- plugins/human-writing/README.md
```

The capture wraps long lines to fit the image but does not change their wording.

## shape-the-work

`shape-the-work.svg` comes from a controlled Git repository in a temporary directory. The renderer installs the repository's fake OpenSpec executable and makes OpenSpec Explore ready. It leaves Wayfinder without its companions and tracker contract. Long-Horizon Prompting remains absent. The renderer then runs the real dependency checker and verifies all three statuses. [`scripts/test-shape-the-work.sh`](../../scripts/test-shape-the-work.sh) covers the same states and several failure paths.
