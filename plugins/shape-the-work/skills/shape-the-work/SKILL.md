---
name: shape-the-work
description: Route work by the artifact needed now—not by duration—to ordinary execution, OpenSpec Explore, Wayfinder, or Long-Horizon Prompting. Use when a user asks which work-shaping skill fits, when task size and uncertainty make the mode unclear, or when managing explicit handoffs among investigation, durable decision mapping, and launch-brief design for autonomous runs. Do not invoke merely because clear routine work is lengthy or has several steps.
---

# Shape the Work

Choose the smallest mode that owns the result the user needs now. This router is general-purpose; it does not assume a repository, product, implementation stack, or issue tracker.

## Operating rule

Use at most one child mode at a time:

1. Identify the requested artifact or action.
2. Classify the current phase; use duration only as supporting evidence.
3. Check whether the selected child is operational, not merely installed.
4. State the route and exit condition.
5. Read the selected child's `SKILL.md` in full and follow it faithfully.
6. Stop or name the next handoff when the child's own exit condition is met.

Do not blend fragments from all three children into a new process. A task may move between modes, but each transition must be explicit.

## Route by owned artifact

| Route | Choose it when the user needs | Primary output | Exit condition |
|---|---|---|---|
| **None** | An answer or implementation whose outcome and constraints are clear enough to proceed | The requested result | The task is complete; length does not change the route |
| **OpenSpec Explore** | Thinking, investigation, option comparison, or requirement clarification without application implementation | Grounded evidence, alternatives, tradeoffs, and decisions | The user has enough clarity to stop, capture an OpenSpec artifact, propose a change, or proceed normally |
| **Wayfinder** | A durable, shared map because the decision space itself exceeds one session and the way to the destination is still hidden | A canonical tracker map and child decision tickets | Charting ends when the initial map, currently specifiable tickets, and their frontier exist; Wayfinding ends when the way is clear and no decision fog remains |
| **Long-Horizon Prompting** | A launch prompt or pre-launch audit for a hard autonomous or parallel run | A pseudo-formal task brief with success, non-counting, audit, reporting, and return conditions | The brief passes pre-launch red-teaming and is ready to hand to a separate execution harness |

Apply these precedence rules:

- Route by the requested artifact before judging clarity or duration.
- A clear multi-session migration remains **None** unless the user asks for an autonomous-run brief.
- A multi-day but bounded investigation remains **OpenSpec Explore**.
- A huge unresolved decision space becomes **Wayfinder** only when it warrants a persistent tracker map.
- Writing or reviewing a future long-run prompt is **Long-Horizon Prompting**, even if today's prompt-editing session is short.
- A vague hard problem can enter **Long-Horizon Prompting** when the requested output is its launch brief; precision is a launch gate, not an activation prerequisite.

If no child owns the requested artifact, choose **None**. Do not force every long task into Long-Horizon Prompting.

## Check operational readiness

Run the bundled checker from the active project directory before loading a child:

```bash
skill_directory="<directory containing this SKILL.md>"
bash "$skill_directory/scripts/check-dependencies.sh" --json "$PWD"
```

Replace the placeholder with the resolved skill directory. Interpret the selected child's status:

- `ready`: required local prerequisites were found.
- `needs-context-check`: the child exists, but the resolved project/store context may not match the target.
- `needs-setup`: the child exists, but a required runtime, companion skill, reference, or tracker contract is missing.
- `missing`: the child skill itself was not found.

A route can still be recommended when it is not ready, but do not execute it. Read [references/dependencies.md](references/dependencies.md), report the exact prerequisite, and offer setup. Do not install or configure anything unless the user asks. Missing unselected children do not block the chosen route.

## Declare the mode contract

Before substantial work, report:

```text
Route: <None | OpenSpec Explore | Wayfinder | Long-Horizon Prompting>
Why: <one concrete sentence about the artifact this mode owns>
Dependency: <ready at path | needs context check | needs setup | missing | not needed>
Mode: <ordinary work | non-implementation exploration | decision mapping | launch-brief design/review>
Output: <the artifact or result this phase will produce>
Exit: <the selected child's real exit condition>
```

Keep this short. It is an operating contract, not a preamble.

## Run the selected child

### OpenSpec Explore

- Load `openspec-explore` from the active catalog or reported path.
- Confirm the resolved OpenSpec root or named store belongs to the intended project. Do not adopt an unrelated ancestor-workspace change merely because it is nearest.
- Treat this as non-implementation exploration: inspect code, behavior, data, and OpenSpec context, but never write application code.
- Creating or updating OpenSpec proposals, designs, or specs is allowed only when the user asks; it remains part of Explore mode, not application implementation.
- Return evidence, alternatives, decisions, and open questions. Do not silently turn exploration into implementation.

### Wayfinder

- Load `wayfinder` from the active catalog or reported path.
- Require its tracker contract plus the `grilling` and `domain-modeling` companions before charting. If they are absent, stop at a setup recommendation rather than simulating Wayfinder.
- Preserve its canonical tracker map, child decision tickets, frontier, fog, claims, and one-ticket-per-session rule.
- Treat Wayfinder as planning by default. Charting stops after the initial map, currently specifiable tickets, and their frontier exist; the overall effort continues until the way to the destination is clear.
- Hand a decision ticket to OpenSpec Explore only when that bounded product or design investigation genuinely benefits from OpenSpec. Record the resulting decision back in the Wayfinder ticket and map.
- Before creating issues, assignments, dependency edges, or local tracker files, ensure the user authorized those tracker writes.

### Long-Horizon Prompting

- Load `long-horizon-prompting` from the active catalog or reported path.
- Use it only to write, strengthen, or red-team the launch brief for a hard autonomous or parallel run.
- Let it turn a vague hard problem into precise definitions, a success predicate, non-counting outcomes, an adversarial audit checklist, reporting requirements, and return conditions.
- Do not use it as the runtime, harness, evaluator, checkpoint store, topology manager, or executor. Those are separate capabilities.
- Do not launch the run. End when the brief passes its pre-launch rubric and identify the separately authorized execution or harness handoff.

### None

- State that none of the three specialist artifacts is needed.
- Continue with ordinary reasoning and tools, whether the work takes minutes or multiple sessions.
- Use normal plans, checkpoints, tests, or progress records as the task requires; do not manufacture a specialist artifact merely because the task is long.

## Hand off between phases

Carry forward:

- the objective;
- verified facts and sources;
- decisions already made;
- unresolved decisions and their owner;
- scope and explicit non-scope;
- acceptance checks;
- canonical artifact paths or tracker links;
- the next route and why it owns the next output.

Common transitions are:

```text
Wayfinder --bounded design ticket--> OpenSpec Explore
OpenSpec Explore --decision reached--> Wayfinder (record ticket resolution)
Wayfinder --way fully clear--> OpenSpec proposal workflow or None
OpenSpec Explore --clarity reached--> OpenSpec artifact capture, proposal workflow, or None
Any phase --launch brief requested for hard autonomous run--> Long-Horizon Prompting
Long-Horizon Prompting --brief passes audit--> separately authorized harness/execution
```

OpenSpec proposal and implementation workflows are separate from `openspec-explore`. Long-run execution is separate from `long-horizon-prompting`.

## Preserve boundaries

- Treat child skills as upstream dependencies, not instructions to paraphrase from memory.
- Do not vendor or silently approximate a missing child.
- Keep one canonical artifact for each decision or requirement; link instead of duplicating.
- Re-run routing when the requested artifact, authority, or uncertainty materially changes.
- Ask before destructive actions, tracker writes, publication, external messages, credential use, purchases, or broad scope expansion.
- Describe agent topology only when a separate orchestration capability owns it. This skill orchestrates phases, not a standing swarm.

## Response shape

Lead with the route, artifact-based reason, readiness state, output, and exit. If the user asked only which skill to use, stop after the recommendation and readiness guidance.
