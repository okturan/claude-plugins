# Child skill readiness

`shape-the-work` owns routing and handoffs. It does not vendor the child modes, so each selected child must be installed and operational in the target project.

## Status meanings

- `ready`: the checker found the child and its deterministic local prerequisites.
- `needs-context-check`: the child exists, but its resolved project or store may not match the target.
- `needs-setup`: the child exists, but a runtime, companion, reference, or tracker contract is missing.
- `missing`: the child `SKILL.md` was not found.

The checker is read-only. It never installs skills, changes project configuration, or creates tracker artifacts.

## OpenSpec Explore

- Skill: `openspec-explore`
- Source: [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)
- Runtime: the `openspec` CLI
- Context: a project-local OpenSpec root or an explicitly selected registered store

Initialize or update OpenSpec using its current documentation. Before exploration, run `openspec list --json` from the actual target project or resolve the named store with `openspec store list --json`. Confirm the returned root or store belongs to the requested project; a parent workspace can otherwise expose unrelated changes.

## Wayfinder

- Skill: `wayfinder`
- Source: [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder)
- Required companions for charting: `grilling`, `domain-modeling`
- Setup capability: `setup-matt-pocock-skills`
- Conditional ticket capabilities: `research`, `prototype`
- Project contract: `docs/agents/issue-tracker.md` with a `Wayfinding operations` section

Install the working set with the cross-agent installer:

```bash
npx skills@latest add mattpocock/skills \
  --skill wayfinder setup-matt-pocock-skills grilling domain-modeling research prototype
```

Then run `setup-matt-pocock-skills` once for the target repository. Installing only `wayfinder` leaves its charting workflow incomplete.

`research` and `prototype` are conditional rather than immediate blockers, but install them if those ticket types may appear.

## Long-Horizon Prompting

- Skill: `long-horizon-prompting`
- Source: [Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering/tree/main/skills/long-horizon-prompting)
- Required bundled references: task-brief template, vendor guidance, research evidence, and the annotated example

Install with:

```bash
npx skills@latest add muratcankoylan/Agent-Skills-for-Context-Engineering \
  --skill long-horizon-prompting
```

This child is ready when it can write and audit the brief. Runtime budgets, sandboxes, evaluators, topology, durable checkpointing, and the execution loop are separate capabilities and are not implied by a `ready` result.

## Missing or incomplete dependencies

Report the exact missing prerequisite. Offer installation or setup, but do not perform it unless the user asks. A lightweight fallback must be labelled as ordinary reasoning, not as execution of the missing upstream skill.

Versions remain owned by their upstream repositories. Re-read the selected child's installed `SKILL.md` on every invocation; do not rely on a remembered contract.
