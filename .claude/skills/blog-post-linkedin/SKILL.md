---
name: blog-post-linkedin
description: Use this skill whenever the user wants to draft a LinkedIn post promoting a Jekyll blog post from `/Users/ojitha/GitHub/ojitha.github.io/_posts/`. Triggers include phrases like "create a LinkedIn post for X.md", "write LinkedIn copy", "make a LinkedIn announcement", "share this post on LinkedIn", "promote on LinkedIn", or any request to write SEO-friendly social copy for a `_posts/*.md` file. Make sure to use this skill any time a `_posts/*.md` filename is mentioned together with LinkedIn or social sharing — even if the user does not say "skill" or "SEO".
---

# Blog Post → LinkedIn (ojitha.github.io)

Generate a Google-SEO-friendly LinkedIn post that promotes a single blog post under `/Users/ojitha/GitHub/ojitha.github.io/_posts/`. The output is **plain text printed in the response** — the user copies it directly into LinkedIn. **Do not create any file. Do not write to disk.**

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

Read the full markdown file. Pull out the title, the first 2–3 substantive paragraphs, the recurring technical entities (frameworks, models, hardware, key concepts), and the existing `excerpt:` value if it has been filled in.

### 2. Identify SEO entities

Pick **5–8 dominant entities** of the post — concrete proper nouns real readers Google for. Prefer "vLLM", "ROCm", "Ryzen AI 9 HX 470" over abstractions like "the inference server" or "the AMD stack".

These entities serve two purposes:

- A few are named in the prose so Google indexes the post for those terms.
- All of them drive the hashtag set in step 5 — that is where the SEO breadth comes from now that the prose is short.

### 3. Build the post — strict 50-word prose budget

The **prose portion** of the post is capped at **50 words total**. Count every word in the hook + body. Hyphenated compounds like "decoder-only" count as one word; numbers like "128K" or "4.5B" count as one word; model names like "Gemma 4 E4B" count as the obvious word count ("Gemma 4 E4B" = 3 words).

The URL line and the hashtag line **do not count** toward the 50 words.

Use this exact structure, with one blank line between sections:

```
<HOOK + body, ≤ 50 words total. Lead with the most concrete claim or number. Name 2–3 SEO entities directly. Prefer numbers over adjectives.>

Read more:
<URL from step 2 — bare URL, no markdown link syntax>

<all relevant hashtags on the final line, single-spaced>
```

The whole post ends up short on purpose — typically 350–500 characters of prose plus the URL plus the hashtag line. That suits LinkedIn's "see more" cutoff (~210 chars in the feed): most of the prose is visible without expansion, and the hashtags carry the discovery weight.

### 4. Writing rules for the prose

- **Plain text only.** LinkedIn does not render markdown — no `**bold**`, no `# headers`, no `[label](url)`. Bare URLs become clickable on their own.
- **Name entities directly** — 2–3 of the SEO entities, exactly as they are written in the post. This is what Google indexes.
- **Numbers over adjectives** — "128K context" beats "huge context".
- **No emojis** unless the source blog post uses them.
- **No clickbait.**
- **Count every word** before locking the draft. If you are over 50, cut adjectives and connector words first; preserve the entity names and the numbers.

### 5. Hashtag selection — include all relevant tags

Because the prose is so short, **hashtags are the primary SEO surface area**. Include every relevant tag, mixing scope:

- **Broad category tags (1–3):** match the post's overall domain — `#MachineLearning`, `#GenerativeAI`, `#DataEngineering`, `#Scala`, `#AWS`, `#Kubernetes`, `#Python`, `#FunctionalProgramming`, `#CloudComputing`, `#DevOps`, `#BigData`.
- **Entity-specific tags (3–7):** one per major SEO entity from step 2 — `#Gemma4`, `#vLLM`, `#ROCm`, `#RyzenAI`, `#NPU`, `#Docker`, `#PyTorch`, `#ApacheSpark`, `#PySpark`, `#Terraform`, `#ElasticSearch`, `#LangGraph`, `#AWSCDK`, `#Hadoop`, `#HDFS`.
- **Audience tags (0–2, optional):** when the post targets a specific community — `#OpenSource`, `#LLM`, `#EdgeAI`, `#MLOps`, `#DataScience`.

Format rules:

- **PascalCase** for multi-word tags (`#MachineLearning`, not `#machinelearning`).
- For single-word tools, **retain the canonical spelling** (`#vLLM` keeps the lowercase v that the project itself uses; `#ROCm` keeps the lowercase m AMD itself uses).
- All hashtags on a **single final line**, single-spaced.
- **No duplicates**, no punctuation, no internal spaces.
- Aim for **6–10 hashtags total** — enough for comprehensive discoverability, not so many that LinkedIn's algorithm penalises over-tagging.

### 6. Output

Print the post **directly in the response** inside a fenced code block so whitespace, arrow characters, and the URL all survive copy-paste cleanly:

````
```
<HOOK + body, ≤ 50 words>

Read more:
<URL>

#Tag1 #Tag2 #Tag3 ...
```
````

After the code block, briefly state:
- The prose word count (e.g. "47/50 words").
- The derived URL.
- The chosen hashtags.

**Do not save anything to a file. Do not create the `linkedin/` directory. Do not invoke any write tool.**

## Verification (always run mentally before reporting done)

1. **Prose word count is ≤ 50** — count every word, not characters. If over, cut adjectives and connector words first; keep the entity names and numbers intact.
2. The published URL is correct — re-derive it from the filename and string-compare.
3. **All relevant hashtags are present** — at least one broad tag and 3+ entity-specific tags. Total 6–10.
4. No markdown leaked into the prose — no `**`, `[...](`, `# `.
5. The output is a code block in the response. **No file was written.**

If any check fails, fix and re-verify before reporting done.

## Style notes

- This skill **does not modify the original blog post** and **does not write any file**. The only output is in-chat text.
- Re-running the skill simply produces a fresh draft in the response — no caching, no overwrites, no on-disk artefacts.
- The 50-word prose cap is intentional. Short LinkedIn posts surface better in the feed, and the hashtag set carries the SEO breadth that long prose used to. Treat the cap as a hard constraint, not a target.
