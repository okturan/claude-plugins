# Child skill dependencies

`shape-the-work` owns routing and handoffs. It does not vendor the three modes it can select. Keeping them external preserves their upstream instructions and update paths.

## OpenSpec Explore

- Skill name: `openspec-explore`
- Source: [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)
- Typical location: a project's `.agents/skills/openspec-explore/SKILL.md`, `.claude/skills/openspec-explore/SKILL.md`, or equivalent agent-specific directory
- Install path: initialize or update OpenSpec in the project using the current OpenSpec documentation

OpenSpec Explore is commonly project-local because it works with that project's OpenSpec state. Do not copy it into an unrelated project merely to satisfy the router.

## Wayfinder

- Skill name: `wayfinder`
- Source: [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder)
- Install with the cross-agent installer:

```bash
npx skills@latest add mattpocock/skills
```

Select `wayfinder` and the agents that should receive it.

## Long-Horizon Prompting

- Skill name: `long-horizon-prompting`
- Source: [Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering/tree/main/skills/long-horizon-prompting)
- Install with the cross-agent installer:

```bash
npx skills@latest add muratcankoylan/Agent-Skills-for-Context-Engineering
```

Select `long-horizon-prompting` and the agents that should receive it.

## Missing dependency behavior

The dependency checker reports availability only; it never installs or changes a skill. If the selected dependency is absent, either ask the user to install it or offer a lightweight fallback that is explicitly not the upstream skill. Never claim upstream guarantees when running the fallback.

Versions are maintained by their respective upstream repositories. Review upstream changes before updating a pinned or customized installation.
