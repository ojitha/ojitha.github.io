---
name: blog-post-linkedin
description: Use this skill whenever the user wants to draft a LinkedIn post promoting a Jekyll blog post from `/Users/ojitha/GitHub/ojitha.github.io/_posts/`. Triggers include phrases like "create a LinkedIn post for X.md", "write LinkedIn copy", "make a LinkedIn announcement", "share this post on LinkedIn", "promote on LinkedIn", or any request to write SEO-friendly social copy for a `_posts/*.md` file. Make sure to use this skill any time a `_posts/*.md` filename is mentioned together with LinkedIn or social sharing — even if the user does not say "skill" or "SEO".
---

# Blog Post → LinkedIn (ojitha.github.io)

Generate a structured LinkedIn post that promotes a single blog post under `/Users/ojitha/GitHub/ojitha.github.io/_posts/`. The output is **plain text printed in the response** — the user copies it directly into LinkedIn. **Do not create any file. Do not write to disk.**

## Required input

1. **Markdown filename** — a file in `_posts/`. Bare name (`2026-05-05-Gemma4.md`) or full path. Resolve to the absolute path before reading.

If missing, ask once and then proceed.

## URL derivation rule

Build the canonical published URL from three pieces:

- **Category** — lowercase the **first** entry in the front-matter `categories:` list.
- **Date** — split the `YYYY-MM-DD` from the filename (or front-matter `date:`) into `YYYY/MM/DD`.
- **Slug** — the filename with the leading `YYYY-MM-DD-` prefix and trailing `.md` removed.

Combined as:

```
https://ojitha.github.io/<category>/<YYYY>/<MM>/<DD>/<slug>.html
```

**Worked example.** `2026-05-05-Gemma4.md` with `categories: [AI]` →
`https://ojitha.github.io/ai/2026/05/05/Gemma4.html`

Edge cases:
- Multiple categories → use the first.
- Spaces in the slug (older posts) → URL-encode as `%20`.
- Front-matter `date:` disagreeing with the filename date → prefer the filename date (Jekyll routes by filename date).

## Workflow

### 1. Read the post

Read the full markdown file. Pull out the title, the main accomplishments or results demonstrated, the key learnings or insights, the recurring technical entities (frameworks, models, hardware, key concepts), and the existing `excerpt:` value if it has been filled in.

### 2. Identify SEO entities

Pick **5–8 dominant entities** of the post — concrete proper nouns real readers Google for. Prefer "vLLM", "ROCm", "Ryzen AI 9 HX 470" over abstractions like "the inference server" or "the AMD stack".

These entities drive the hashtag set in step 5.

### 3. Build the post — five numbered sections

Use this exact five-section structure. One blank line between every section.

```
🚀 My Blog: <post title — exact title from front-matter>
<URL — bare URL, no markdown link syntax>

<One or two sentences explaining why this post is valuable to read — the core problem it solves or the outcome it delivers. End with a colon.>
✅ <concrete result or accomplishment #1>
✅ <concrete result or accomplishment #2>
✅ <concrete result or accomplishment #3>
✅ <concrete result or accomplishment #4 — add more if the post warrants>

Key things I learned along the way:
→ <key insight or technique #1>
→ <key insight or technique #2>
→ <key insight or technique #3>
→ <key insight or technique #4>
→ <key insight or technique #5 — add more if the post warrants>

<all relevant hashtags on a single line, single-spaced>
```

**Section guidance:**

- **Section ① — Title + URL block:** `🚀 My Blog:` followed by the exact front-matter title on line one. The bare canonical URL on the very next line (no blank line between them). LinkedIn turns the URL into a preview card linked to the post title above it.
- **Section ② — Why valuable:** 1–2 sentences addressing what the reader will gain or what problem is solved. Follow immediately with `✅` bullet lines (no blank line between the intro sentence and the bullets). Each bullet names one concrete, verifiable result — include numbers, versions, or benchmark figures wherever the post provides them.
- **Section ③ — Key topics:** Lead with the fixed phrase `Key things I learned along the way:` (no blank line before the arrows). Each `→` line captures one transferable insight, technique, or gotcha from the post — not restatements of the ✅ accomplishments. Prefer specifics: kernel versions, flag names, configuration values.
- **Section ④ — Hashtags:** All hashtags on a single final line, single-spaced.

### 4. Writing rules for the prose

- **Plain text only.** LinkedIn does not render markdown — no `**bold**`, no `# headers`, no `[label](url)`. Bare URLs become clickable on their own.
- **No emojis beyond the fixed ones** (`🚀`, `✅`, `→`, `📖`) unless the source blog post explicitly uses others.
- **No clickbait.**
- **Name entities directly** in the ✅ and → lines — exact names as written in the post (e.g. "ROCm 7.2", "PyTorch 2.9.1", "gfx1150").

### 5. Hashtag selection — include all relevant tags

Hashtags are the primary SEO surface area. Include every relevant tag, mixing scope:

- **Broad category tags (1–3):** `#MachineLearning`, `#GenerativeAI`, `#DataEngineering`, `#Scala`, `#AWS`, `#Kubernetes`, `#Python`, `#FunctionalProgramming`, `#CloudComputing`, `#DevOps`, `#BigData`.
- **Entity-specific tags (3–7):** one per major SEO entity from step 2 — `#Gemma4`, `#vLLM`, `#ROCm`, `#RyzenAI`, `#NPU`, `#Docker`, `#PyTorch`, `#ApacheSpark`, `#PySpark`, `#Terraform`, `#ElasticSearch`, `#LangGraph`, `#AWSCDK`, `#Hadoop`, `#HDFS`.
- **Audience tags (1–3):** Always include `#AI`. Add others when relevant — `#OpenSource`, `#LLM`, `#EdgeAI`, `#MLOps`, `#DataScience`, `#LocalAI`.

Format rules:

- **PascalCase** for multi-word tags (`#MachineLearning`, not `#machinelearning`).
- For single-word tools, **retain the canonical spelling** (`#vLLM` keeps the lowercase v; `#ROCm` keeps the lowercase m).
- All hashtags on a **single final line**, single-spaced.
- **No duplicates**, no punctuation, no internal spaces.
- Aim for **8–12 hashtags total**.

### 6. Output

Print the post **directly in the response** inside a fenced code block so whitespace, emoji, arrow characters, and the URL all survive copy-paste cleanly:

````
```
🚀 My Blog: <title>
<URL>

<why valuable sentences>
✅ ...
✅ ...

Key things I learned along the way:
→ ...
→ ...

#Tag1 #Tag2 #Tag3 ...
```
````

After the code block, briefly state:
- The derived URL.
- The chosen hashtags.

**Do not save anything to a file. Do not create any directory. Do not invoke any write tool.**

## Verification (always run mentally before reporting done)

1. Section ① has `🚀 My Blog:` + exact front-matter title on line one, and the correctly derived canonical URL on line two (no blank line between them).
2. Section ② has 1–2 intro sentences followed by at least 3 `✅` bullet lines with concrete results.
3. Section ③ starts with `Key things I learned along the way:` and has at least 3 `→` lines with specific insights.
4. Section ④ contains 8–12 hashtags on a single line with no duplicates.
6. No markdown leaked into the prose — no `**`, `[...](`, `# `.
7. The output is a code block in the response. **No file was written.**

If any check fails, fix and re-verify before reporting done.

## Style notes

- This skill **does not modify the original blog post** and **does not write any file**. The only output is in-chat text.
- Re-running the skill simply produces a fresh draft in the response — no caching, no overwrites, no on-disk artefacts.
