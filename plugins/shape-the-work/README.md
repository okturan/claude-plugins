# shape-the-work

Choose the mode responsible for the result needed now. Duration is supporting evidence, not the routing rule:

| Route | Best fit |
|---|---|
| None | A clear answer or implementation, even when execution spans sessions |
| OpenSpec Explore | Non-implementation thinking, investigation, or option comparison |
| Wayfinder | A durable tracker map for decision fog that exceeds one session |
| Long-Horizon Prompting | Writing or auditing the launch brief for a hard autonomous run |

The router selects one mode per phase, verifies that the chosen child is operational, declares its real exit condition, and carries verified facts and unresolved decisions into an explicit handoff. It does not assume a particular product or repository.

Long work is not automatically Long-Horizon Prompting. A fully specified multi-session migration remains ordinary execution unless the user asks for an autonomous-run brief. Conversely, reviewing a future twelve-hour launch prompt uses Long-Horizon Prompting even if the review itself takes one short session.

## Install

As a Claude Code plugin:

```text
/plugin marketplace add okturan/claude-plugins
/plugin install shape-the-work@okturan-plugins
```

As a reusable skill for Codex, Claude Code, Cursor, or another supported agent:

```bash
npx skills@latest add okturan/claude-plugins
```

Select `shape-the-work` and the agents that should receive it.

## Use

In Claude Code:

```text
/shape-work Should this checkout become one product or several services?
```

Or invoke the installed skill by name:

```text
$shape-the-work Turn this broad migration idea into the right next phase.
```

The reusable Codex metadata keeps the skill explicit-only. Clear routine requests should proceed without routing overhead.

## Child skills

The router does not copy or bundle its child skills. Install the working set needed by each mode:

- [OpenSpec Explore](https://github.com/Fission-AI/OpenSpec), usually initialized per project
- [Wayfinder](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder), plus `setup-matt-pocock-skills`, `grilling`, `domain-modeling`, and the ticket-type skills it needs
- [Long-Horizon Prompting](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering/tree/main/skills/long-horizon-prompting)

Check readiness without changing the machine:

```bash
bash plugins/shape-the-work/skills/shape-the-work/scripts/check-dependencies.sh --json "$PWD"
```

The script searches project-local `.agents`, `.codex`, and `.claude` skill directories, then the corresponding user-level locations. It reports `ready`, `needs-context-check`, `needs-setup`, or `missing`. A child is never silently approximated or installed.

## Boundaries

- One child mode runs at a time.
- Exploration never writes application code; OpenSpec artifacts may be captured when requested.
- Wayfinder artifacts are linked, not duplicated into OpenSpec.
- Long-Horizon Prompting ends with an audited launch brief; it does not run the harness or agents.
- Publishing, destructive actions, messages, credentials, and purchases remain user-gated.
