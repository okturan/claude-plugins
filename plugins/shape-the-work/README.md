# shape-the-work

Choose the right level of process for the work in front of you. The plugin routes a task to one of four options:

| Route | Best fit |
|---|---|
| None | Clear work that can proceed normally |
| OpenSpec Explore | One bounded question that needs read-only investigation |
| Wayfinder | A large, ambiguous project that needs a map before a plan |
| Long-Horizon Prompting | A precise objective ready for sustained autonomous execution |

The router selects one mode per phase, declares an exit condition, and carries verified facts and unresolved decisions into an explicit handoff. It does not assume a particular product or repository.

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

The router does not copy or bundle its child skills. Install the modes you intend to use from their upstream sources:

- [OpenSpec Explore](https://github.com/Fission-AI/OpenSpec), usually initialized per project
- [Wayfinder](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder)
- [Long-Horizon Prompting](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering/tree/main/skills/long-horizon-prompting)

Check availability without changing the machine:

```bash
bash plugins/shape-the-work/skills/shape-the-work/scripts/check-dependencies.sh --json "$PWD"
```

The script searches project-local `.agents`, `.codex`, and `.claude` skill directories, then the corresponding user-level locations. A missing child is reported, not silently approximated or installed.

## Boundaries

- One child mode runs at a time.
- Exploration remains read-only.
- Wayfinder artifacts are linked, not duplicated into OpenSpec.
- A long-run brief does not authorize launching agents or changing external systems.
- Publishing, destructive actions, messages, credentials, and purchases remain user-gated.
