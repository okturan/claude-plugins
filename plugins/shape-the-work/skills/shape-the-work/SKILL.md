---
name: shape-the-work
description: Route a task to OpenSpec Explore, Wayfinder, Long-Horizon Prompting, or ordinary execution. Use when a user asks which work-shaping skill fits, when uncertainty and task size make the right mode unclear, or when planning a handoff between exploration, specification, and sustained autonomous work. Do not invoke merely because a clear, routine task has several steps.
---

# Shape the Work

Choose the smallest work-shaping mode that fits the task, load that skill, and keep handoffs explicit. This is a general router. It does not assume a particular repository, product, or implementation stack.

## Operating rule

Use at most one child mode at a time:

1. Classify the current phase.
2. Check whether the selected child skill is available.
3. State the route and its exit condition.
4. Read the selected child skill's `SKILL.md` in full and follow it faithfully.
5. Stop or hand off when the exit condition is met.

Do not blend fragments from all three skills into a new process. A task may move between modes over time, but each transition must be named.

## Route the task

| Route | Choose it when | Primary output | Exit condition |
|---|---|---|---|
| **None** | The outcome and constraints are clear, ordinary repository inspection can answer remaining questions, and the work fits a normal session | The requested answer or implementation | The task is complete |
| **OpenSpec Explore** | A bounded product, policy, behavior, or design question needs read-only investigation before anyone commits to a change | Evidence, alternatives, tradeoffs, and unresolved decisions | The user has enough clarity to stop, specify, or implement |
| **Wayfinder** | The project is too large or foggy to plan linearly; goals, constraints, dependencies, or major decisions still need mapping | A navigable map of decisions, risks, workstreams, and candidate tickets | A bounded workstream or ticket can be selected |
| **Long-Horizon Prompting** | The objective is already precise enough for hours or days of autonomous execution and needs checkpoints, verification, recovery, and a durable run brief | A long-run execution prompt or managed run contract | The run finishes, reaches a decision gate, or reports a real blocker |

Use these tie-breakers:

- Prefer **None** when normal reasoning and tools are enough.
- Prefer **OpenSpec Explore** for one bounded uncertainty in an existing project.
- Prefer **Wayfinder** when the uncertainty is the shape of the project itself.
- Prefer **Long-Horizon Prompting** only after the objective and acceptance criteria are concrete.
- If two routes seem plausible, select the earlier phase: map before exploring a ticket, and explore before launching a long run.

Task duration alone does not select Long-Horizon Prompting. A vague multi-day goal belongs in Wayfinder first.

## Check dependencies

The router is self-contained, but the three child skills are external dependencies. Before selecting one, run the bundled read-only checker from the active project directory:

```bash
skill_directory="<directory containing this SKILL.md>"
bash "$skill_directory/scripts/check-dependencies.sh" --json "$PWD"
```

Replace the placeholder with the resolved skill directory. The checker searches project-local and common user-level skill roots without modifying anything.

If the chosen child is missing:

1. Say that it is missing; do not pretend to execute it.
2. Read [references/dependencies.md](references/dependencies.md).
3. Offer the appropriate installation path or a clearly labelled lightweight fallback.
4. Do not install anything unless the user asks.

A missing unselected child does not block the current route.

## Declare the mode contract

Before doing substantial work, report:

```text
Route: <None | OpenSpec Explore | Wayfinder | Long-Horizon Prompting>
Why: <one concrete sentence>
Dependency: <available at path | missing | not needed>
Mode: <read-only exploration | project mapping | run preparation/execution | ordinary work>
Output: <the artifact or result this phase will produce>
Exit: <the event that ends this phase>
```

Keep this short. It is an operating contract, not a preamble.

## Run the selected child

### OpenSpec Explore

- Load `openspec-explore` from the active skill catalog or the path reported by the checker.
- Stay read-only unless that skill and the user explicitly authorize a later transition.
- Inspect actual code, behavior, data, and active OpenSpec context before judging policy.
- Return evidence, tradeoffs, and open questions. Do not silently turn exploration into a proposal or implementation.

### Wayfinder

- Load `wayfinder` from the active skill catalog or the reported path.
- Use it to expose goals, unknowns, decision points, dependencies, and promising workstreams.
- Preserve Wayfinder's own artifact model. Do not shadow-copy every Wayfinder ticket into OpenSpec.
- End by selecting a bounded next workstream, not by claiming the whole program is specified.

### Long-Horizon Prompting

- Load `long-horizon-prompting` from the active skill catalog or the reported path.
- Confirm that the objective, scope, acceptance checks, authority, and stop conditions are explicit.
- Produce the durable run brief and checkpoint/recovery contract that the child skill requires.
- Preparing a long-run prompt does not authorize launching agents, changing external systems, publishing, or spending money. Start the run only when the user requested execution.

### None

- State that no special work-shaping skill adds value.
- Continue with ordinary reasoning and tools.
- Do not manufacture an artifact merely to justify the router.

## Hand off between phases

Use a handoff only when the current exit condition has been met. Include:

- the chosen objective;
- verified facts and their sources;
- decisions already made;
- unresolved decisions and who owns them;
- scope and explicit non-scope;
- acceptance checks;
- relevant artifact paths;
- the recommended next route and why.

Common transitions are:

```text
Wayfinder --select bounded workstream--> OpenSpec Explore
OpenSpec Explore --decision is clear--> None
OpenSpec Explore --change needs a formal spec--> OpenSpec proposal workflow
Wayfinder/OpenSpec --objective is execution-ready--> Long-Horizon Prompting
Long-Horizon Prompting --decision gate reached--> OpenSpec Explore or user decision
```

OpenSpec proposal or implementation workflows are separate from `openspec-explore`. Route to them only if they exist and the user asks to proceed beyond exploration.

## Preserve boundaries

- Treat child skills as upstream dependencies, not content to paraphrase from memory.
- Do not modify or vendor child skills as part of routing.
- Keep one canonical artifact for each decision or requirement; link to it instead of duplicating it.
- Re-run routing when the objective, authority, or uncertainty materially changes.
- Ask before destructive actions, publication, external messages, credential use, purchases, or broad scope expansion.
- Describe agent topology only if the selected child requires it. This skill orchestrates phases, not a standing swarm.

## Response shape

Lead with the selected route. Then give the reason, dependency state, phase result, and next handoff if one is warranted. If the user asked only which skill to use, stop after the recommendation and dependency guidance.
