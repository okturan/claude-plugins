# human-writing

Write outward-facing prose that reads like a person wrote it, and strip AI tells from existing drafts.

Two parts:

- **Skill** (`human-writing`) — auto-activates when drafting social posts, blog posts, READMEs, announcements, emails, or marketing copy. Covers both halves of the problem: avoiding AI tells, and writing with the specificity and rhythm that make text read as human in the first place.
- **Command** (`/humanize`) — explicit two-pass rewrite of existing text: identify the tells present, then rewrite while preserving meaning, technical claims, and the author's voice.

## Usage

```
/humanize path/to/draft.md
/humanize <pasted text>
```

Or just ask Claude to write a post/README/announcement — the skill loads on its own.

## What it will not do

Invent specifics. The strongest human marker is detail only the author could know, so the skill asks for real numbers and real events, or leaves bracketed questions in the draft. It also won't flatten a distinctive voice or alter technical claims for the sake of style.

## Prior art

[blader/humanizer](https://github.com/blader/humanizer) is a good cleanup-focused skill built on the same Wikipedia catalog. This plugin differs in emphasis: drafting-first (collect real material, budget rhetorical devices, vary rhythm) with cleanup as the second pass, not the product.

## Sources

- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
- [The Field Guide to AI Slop](https://www.ignorance.ai/p/the-field-guide-to-ai-slop)
