---
name: human-writing
description: "Write outward-facing prose that reads like a person wrote it, and remove AI tells from existing drafts. Use when writing or editing social posts, blog posts, READMEs, announcements, emails, marketing copy, or docs prose — or when the user asks to humanize text, remove AI slop, or make writing sound less like AI."
---

# Human Writing

Two failure modes make text read as machine-written. The first is AI tells: patterns language models produce far more often than people do, like em-dash chains and "It's not X, it's Y". The second is sterile correctness: grammatically clean text with no specifics, no rhythm, and no evidence a person was ever near it. Fixing the tells without fixing the sterility produces flat copy that fools nobody. Do both.

## Before drafting: collect real material

Writing reads as human when it contains things only the author could know. Before drafting anything outward-facing, gather:

- Real numbers: bytes, dollars, minutes, versions, counts
- Real names: the tool, the paper, the person, the place
- What actually went wrong along the way
- One limitation or wart the author would admit to a friend

If this material isn't in the conversation or the project files, ask for it, or leave bracketed questions in the draft: `[how long did the export actually take?]`. **Never invent specifics.** A fabricated anecdote or number is worse than a vague sentence: it turns the piece into a lie the author has to catch before publishing. Flag every placeholder you leave.

## Drafting rules

1. **Concrete beats abstract.** Replace general claims with instances. "Slow" → "40 seconds to load". "A large model" → "595MB".
2. **Plain verbs.** is, has, got, made, found. Not "serves as", "boasts", "features", "leverages", "showcases".
3. **Vary the rhythm.** Mix long sentences with short ones. If three consecutive sentences share a shape, break one. Same for paragraphs: uniform 2–3 sentence blocks each landing on a punchline is a machine signature.
4. **Say it like you'd say it.** Read the draft aloud in your head. Any phrase the author wouldn't say to a colleague across a desk, rewrite until they would.
5. **One device per piece.** Antithesis, tricolon, punchy fragment, kicker: pick at most one and spend it where it matters most. The tell is density, not existence.
6. **Stop at the end.** When the content is done, stop. No moral, no bow, no "Ultimately...", no reflexive call to action.
7. **No decoration.** No hashtag piles, no emoji bullets, no bolded key phrases, no arrow chains, unless the venue genuinely requires them.

## Revising: scan for tells

Work through these in order of signal strength. The full catalog with before/after examples is in [references/ai-tells.md](references/ai-tells.md) — read it before any explicit humanize/de-slop request.

| Category | Look for |
|----------|----------|
| Punctuation | More than ~1 em dash per 100 words; curly quotes in technical text |
| Constructions | "It's not X, it's Y"; tricolons ("fast, simple, and powerful"); question pivots ("The result? ..."); trailing participles (", making it easier than ever") |
| Vocabulary | delve, showcase, testament, tapestry, landscape, pivotal, crucial, robust, seamless, vibrant, leverage, elevate, journey, game-changer |
| Structure | Every paragraph ending on a kicker; uniform paragraph lengths; signposting ("Let's break it down"); formulaic wrap-ups ("The future looks bright") |
| Tone | Significance inflation ("marks a pivotal moment"); unearned profundity ("Something shifted."); hedge stacks ("could potentially help"); chatbot residue ("I hope this helps") |

## What not to do

- Don't treat one em dash or one triad as proof. Humans use these; models overuse them. Judge density and co-occurrence.
- Don't flatten a distinctive voice into house style. If the author writes long looping sentences, opens with "So," or swears, keep it.
- Don't touch quoted material, and don't alter technical claims. Precision outranks style: never swap an exact term for a friendlier wrong one.
- Don't trade one formula for another. Deleting every em dash and sprinkling "honestly" everywhere is the same disease with different symptoms.

## Voice matching

If samples of the author's real writing are available (earlier posts, emails, commit messages), mirror the measurable habits: typical sentence length, contraction use, how they open, how casual they run. When no sample exists, default to plain and direct.

## Output for rewrite requests

Return the rewritten text first, then a short list of what changed (pattern → fix), six items at most. Skip the list when the user only wants the text.
