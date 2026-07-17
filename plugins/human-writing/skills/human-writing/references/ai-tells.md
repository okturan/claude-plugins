# AI Tells — Full Catalog

Patterns that mark text as machine-written, with fixes. Judge by density and co-occurrence: one hit means nothing, five different categories in one piece means everything.

## Punctuation and formatting

**Em-dash density.** More than ~1 per 100 words, or any sentence with two. Replace with commas, parentheses, periods, or a restructure.
- Before: `The codec — a neural model — runs in the browser — no server needed.`
- After: `The codec is a neural model. It runs in the browser, no server needed.`

**Bolded key phrases** mechanically scattered through prose, **emoji bullets** (✅ 🚀 💡), arrow chains (`A → B → C`), hashtag piles, horizontal rules between every section, title-case headings in body text.

**Curly quotes** in technical or code-adjacent writing where the author would have typed straight ones.

## Constructions

**Negative parallelism.** "It's not X, it's Y." / "This isn't about X. It's about Y." / "Not just X, but Y." One antithesis can be the best line in a piece; three is a fingerprint.
- Before: `This isn't a compression trick. It's a rethinking of what audio means.`
- After: `It compresses speech to 160 bits per second.`

**Tricolons everywhere.** Three adjectives, three phrases, three benefits, in list after list. Cut to one strong item or extend to an honest, uneven list.
- Before: `fast, simple, and powerful`
- After: `fast` (pick the one that's true and provable)

**Question pivots.** "The result? ..." "The best part? ..." "The catch? ..." State it directly.

**Trailing participles.** Sentences that end with ", highlighting...", ", underscoring...", ", making it easier than ever to...". Cut the trailer or make it its own sentence with its own evidence.

**Copula avoidance.** "serves as", "stands as", "functions as", "represents", "marks" where the word is "is". Also "boasts", "features", "offers" where the word is "has".

**False ranges.** "From X to Y" where X and Y aren't endpoints of anything: "from startups to enterprises, from ideas to impact".

**Synonym cycling.** Calling the same thing "the tool", "the solution", "the platform", "the offering" to avoid repeating its name. Repeating the name is fine. Humans do it constantly.

**Audience bracketing.** "Whether you're a seasoned engineer or just starting out...". Address one reader.

## Vocabulary

Words models reach for far more often than people: delve, tapestry, testament, showcase, underscore, boast, foster, garner, pivotal, crucial, vital, robust, seamless, vibrant, nestled, intricate, meticulous, landscape, realm, journey, elevate, enhance, empower, leverage, harness, unlock, unleash, game-changer, cutting-edge, groundbreaking, transformative, ever-evolving, fast-paced, at its core, it's worth noting, moreover/furthermore as paragraph openers.

None of these is banned. Two in a paragraph is a smell. Replace with the plain word: use → not leverage, improve → not elevate, big → not transformative.

## Structure and flow

**Kicker addiction.** Every paragraph closing on a mic-drop line. Real writing lets most paragraphs just end; the writer spends the punchline once.

**Uniform rhythm.** All sentences 15–25 words, all paragraphs 2–3 sentences. Break the grid: one 40-word sentence that wanders like speech, one 4-word one.

**Signposting.** "Let's dive in." "Let's break it down." "Here's the thing:". Delete; start with the content.

**Formulaic wrap-ups.** "In conclusion", "Ultimately", "The future looks bright", "Only time will tell", "Challenges remain, but...". End when the content ends.

**Summary-sandwich.** Intro that previews the three points, body with the three points, outro that restates the three points. Say it once.

## Tone and stance

**Significance inflation.** "marks a pivotal moment", "a testament to", "cementing its role in", attached to ordinary facts. State the fact; let the reader rank it.

**Unearned profundity.** "Something shifted." "And that changes everything." Profundity has to be paid for with evidence in the preceding sentences.

**Hedge stacks.** "could potentially help to", "may possibly enable". Pick a claim and make it.

**Chatbot residue.** "Great question", "I hope this helps", "Certainly!", knowledge-cutoff disclaimers, "as an AI". Delete on sight.

**Sycophancy toward the subject.** Press-release adjectives about one's own work. A wart is more convincing than a superlative.

## Human markers (what to add, not just what to remove)

- Specifics only the author could know: exact numbers, tool names, dates, the thing that failed
- One admitted limitation or open question, stated without a redemption arc
- Opinions with stakes: "I have real affection for Codec2, but..."
- References anchored in time and place rather than "in today's world"
- Rhythm that varies because thought varies
- Endings that stop

## False positives

Not evidence of AI on their own: a single em dash, formal register, perfect grammar, the word "however", a lone rule-of-three, a "moreover". Columnists use em dashes; academics write formally. Look for many categories co-occurring, and for the absence of human markers, before concluding anything.

## Sources

- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) — maintained by WikiProject AI Cleanup
- [The Field Guide to AI Slop](https://www.ignorance.ai/p/the-field-guide-to-ai-slop) — Charlie Guo
- Prior art: [blader/humanizer](https://github.com/blader/humanizer) — cleanup-focused skill built on the same Wikipedia catalog
