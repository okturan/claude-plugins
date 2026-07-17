---
description: Rewrite text to remove AI writing tells while keeping the author's voice and meaning
argument-hint: [text, file path, or nothing to be asked]
allowed-tools: Read, Glob, Grep, Edit
---

Rewrite the given text so it reads like a person wrote it, using the human-writing skill.

Arguments: $ARGUMENTS

**Procedure:**

1. Resolve the input. If `$ARGUMENTS` is a file path, read the file. If it's pasted text, use it directly. If empty, ask the user what text to work on and stop until they answer.

2. Load the human-writing skill and read its `references/ai-tells.md` catalog in full.

3. Pass one — identify. List the tells actually present in this text by category. If the text also lacks human markers (no specifics, no stakes, uniform rhythm), note that; removing tells alone will not fix it.

4. Pass two — rewrite. Preserve meaning, technical claims, and quoted material exactly. Keep the author's voice: if samples of their real writing are available in the conversation or repo, match their habits. Where the text needs a concrete detail you don't have, insert a bracketed question like `[what did this cost?]` rather than inventing one.

5. Output the rewritten text first, then a plain list of at most six changes (pattern → fix), then any bracketed questions that need the author's answers.

6. Only edit a file in place if the user explicitly asked for that; otherwise leave the original untouched and deliver the rewrite in the response.
