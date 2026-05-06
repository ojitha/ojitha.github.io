# Claude Skills — ojitha.github.io

Project-scoped Claude skills for this repo. Each skill lives under `.claude/skills/<skill-name>/` and is auto-discovered by Claude Code when run from inside the repo. They are **not** active in any other project.

## Index

- [`blog-post-excerpt`](#blog-post-excerpt) — generate an inline SVG thumbnail and ~100-word excerpt for a Jekyll post and inject both into the front matter.
- [`blog-post-linkedin`](#blog-post-linkedin) — generate a Google-SEO-friendly LinkedIn post (≤ 50-word prose, canonical URL, comprehensive hashtag set) for a Jekyll post — printed in chat, no file output.

---

## `blog-post-excerpt`

Generate an embedded SVG illustration in a chosen drawing style plus a short HTML summary, and inject both into the Jekyll front matter `excerpt:` field of a post under `_posts/`.

### Location

```
.claude/skills/blog-post-excerpt/
├── SKILL.md
└── references/
    └── style-guide.md
```

### What it does

For a single blog post in `_posts/`, the skill:

1. Reads the markdown file end-to-end.
2. Picks **3–6 technical jargon terms** that genuinely characterise the post (framework names, algorithms, hardware, concepts — not generic words).
3. Builds a **150 × 150 px coloured SVG** in the requested drawing style, with the chosen jargon rendered as readable `<text>` inside the artwork.
4. Writes a **~100-word HTML excerpt** (a single `<p>` block, with 2–4 of the same jargon terms wrapped in `<b>`).
5. Replaces `<image>` (or the older typo `<imgage>`) with the SVG and `TLDR` with the excerpt — directly inside the existing one-line `excerpt:` value in the YAML front matter.
6. Re-reads the front matter to verify the YAML still parses cleanly.

The body of the post is **never touched**.

### Jekyll front-matter prerequisite

Before the skill runs, the target post must already have an `excerpt:` placeholder line in its YAML front matter. The standard placeholder shape used in this repo is:

```yaml
---
layout: post
title:  <Your post title>
date:   YYYY-MM-DD
categories: [<category>]
toc: true
mermaid: true
maths: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
excerpt: '<div class="image-text-container"><div class="image-column"><imgage></div><div class="text-column">TLDR</div></div>'
---
```

The skill looks for either spelling — `<imgage>` (the historical typo found in older posts) or the corrected `<image>` — and treats them identically. After the skill runs, that one line is rewritten in place: the `<imgage>`/`<image>` token is swapped for the inline SVG, and `TLDR` is swapped for the ~100-word HTML excerpt. Every other field in the front matter is preserved exactly as it was.

If a post has **no** `excerpt:` line at all, the skill inserts the line above (with the `<imgage>` placeholder) immediately before the closing `---`, then performs the two replacements. So you can use the skill on a brand-new post that was never set up with a placeholder, but adding the placeholder yourself in your post template is cleaner — that way every new post is "skill-ready" from the moment you create it.

### Required inputs

| Parameter | Example | Notes |
|---|---|---|
| Markdown filename | `2026-05-05-Gemma4.md` | Bare name or full path. The skill resolves to `/Users/ojitha/GitHub/ojitha.github.io/_posts/<filename>`. |
| Drawing style | `oil` | One of `pencil sketch`, `oil`, `impressionist`, `watercolor`, `charcoal`, `pop art`, or any other style — the skill will improvise within its principles. |

If either is missing, the skill asks once and then proceeds.

### How to invoke

In Claude Code, just describe what you want — supply both inputs in one message. Any of these phrasings will trigger the skill:

- `Run blog-post-excerpt on 2026-05-05-Gemma4.md in oil style.`
- `Add a TLDR to 2026-04-08-ObsidianMethod.md as a watercolor.`
- `Create an excerpt for 2025-10-31-Functional-Programming-Abstractions-in-Scala.md, pencil sketch.`
- `Generate the front-matter excerpt for 2026-03-07-ContainerRocm.md in pop art style.`
- `Draw a thumbnail for 2025-11-07-SparkDataset.md, impressionist.`

You don't have to say "skill" or use the exact name — pairing a `_posts/*.md` filename with a drawing style is enough.

### Drawing styles

Each style has a complete worked SVG example in `references/style-guide.md`. Summary:

| Style | Visual feel | Palette |
|---|---|---|
| **pencil sketch** | Thin grey strokes, light cross-hatching, muted pastel washes | Cream background, soft pastels |
| **oil** | Thick saturated strokes, no fine detail, no outlines, bright highlight | Deep umber/indigo background, rich reds/ochres/viridian, cream text |
| **impressionist** | Many small coloured dabs, no outlines, suggestion over definition | Light pastel-bright |
| **watercolor** | Translucent pools with `feGaussianBlur` bleeding edges | Soft blues, peaches, greens on off-white paper |
| **charcoal** | Dark rough strokes with smudged shading, one faint colour accent | Sketchpad cream + near-black + single warm accent |
| **pop art** | Bold flat colours, thick black outlines, optional benday dots | Bright primaries + black + cream |

Any unlisted style works too — the skill leans on the closest listed one and adjusts palette and stroke weight.

### What changes in the post

Only line 11-ish of the front matter — the existing `excerpt:` line — is rewritten. Everything else (layout, title, date, categories, mermaid/maths/toc flags, typora roots, the entire body) is left exactly as it was. Re-running the skill on the same file with a different style cleanly overwrites the previous SVG and excerpt because the placeholder structure is identical.

If a post has no `excerpt:` line at all, the skill inserts one immediately before the closing `---` of the front matter using the standard template.

### Verification (the skill always runs this before reporting done)

After editing, the skill re-reads the first ~20 lines of the file and confirms:

1. Front matter still opens and closes with `---`.
2. The `excerpt:` line starts with `'<div class="image-text-container">` and ends with `</div></div>'`.
3. No unescaped single quotes inside the YAML value (apostrophes are escaped as `''`, or rephrased out).
4. The SVG block contains `<svg` … `</svg>` and the chosen jargon words appear as `<text>` content.
5. The text-column prose is roughly 100 words (counted, not estimated).

Then it reports the path to the updated post and the jargon words it chose.

### YAML safety, in case you edit by hand

The full excerpt value lives inside YAML single quotes on one physical line. Anything you add inside it must obey:

- All HTML/SVG attributes use **double quotes** (`fill="#abc"`, never `fill='#abc'`).
- Any literal single quote in the prose must be doubled (`it''s`, not `it's`).
- Don't switch the outer quoting to double quotes — other tooling in the repo expects single-quoted excerpts.
- No literal newlines inside the value.

### Example output

A worked example lives in `_posts/2026-05-05-Gemma4.md` (oil style, jargon: Gemma 4, vLLM, ROCm, Ryzen AI, NPU). Re-read line 11 of that file to see the exact YAML shape.

---

## `blog-post-linkedin`

Generate a Google-SEO-friendly LinkedIn post that promotes a single Jekyll blog post under `_posts/`. The output is **plain text printed in the chat response** — copy-paste it directly into LinkedIn. The prose is **capped at 50 words**, and the hashtag set is comprehensive (typically 6–10 tags) so it carries the SEO breadth that the short prose cannot.

### Location

```
.claude/skills/blog-post-linkedin/
└── SKILL.md
```

### What it does

For a single blog post in `_posts/`, the skill:

1. Reads the markdown file end-to-end and extracts the title, category, lede, and recurring technical entities.
2. **Derives the canonical published URL** from the filename and front matter (formula below).
3. Picks **5–8 SEO entities** — the proper nouns real readers Google for (framework names, model names, hardware, tools).
4. Drafts a tight LinkedIn post:
   - **Prose capped at 50 words total** (hook + body combined). Numbers like `128K`, hyphenated tokens like `decoder-only`, and proper-noun model names are each counted as one word. The URL line and the hashtag line do **not** count toward the 50.
   - The published URL on its own line.
   - **All relevant hashtags** (typically 6–10) on the final line — a mix of broad-category, entity-specific, and optional audience tags for maximum discoverability.
5. **Prints the post directly in the chat response** inside a fenced code block, so the user can copy-paste straight into LinkedIn.

The original blog post is **never modified**, and **no file is written to disk**.

### Required input

| Parameter | Example | Notes |
|---|---|---|
| Markdown filename | `2026-05-05-Gemma4.md` | Bare name or full path. The skill resolves to `/Users/ojitha/GitHub/ojitha.github.io/_posts/<filename>`. |

### URL derivation rule

The published URL is built deterministically from three pieces of the source post:

- **Category** — lowercase the **first** entry in the front-matter `categories:` list.
- **Date** — split the `YYYY-MM-DD` from the filename (or front-matter `date:`) into `YYYY/MM/DD`.
- **Slug** — the filename with the leading `YYYY-MM-DD-` prefix and trailing `.md` removed.

Combined as:

```
https://ojitha.github.io/<category>/<YYYY>/<MM>/<DD>/<slug>.html
```

**Worked example.** `2026-05-05-Gemma4.md` with `categories: [AI]` →
`https://ojitha.github.io/ai/2026/05/05/Gemma4.html`

Edge cases handled by the skill:

- Multiple categories → uses the first.
- Spaces in the slug (older posts) → URL-encodes them as `%20`.
- Front-matter `date:` disagreeing with the filename date → prefers the filename date (that is what Jekyll uses).

### How to invoke

In Claude Code, describe what you want and supply the filename:

- `Run blog-post-linkedin on 2026-05-05-Gemma4.md.`
- `Write LinkedIn copy for 2026-04-08-ObsidianMethod.md.`
- `Make a LinkedIn announcement for 2025-10-31-Functional-Programming-Abstractions-in-Scala.md.`
- `Promote 2026-03-07-ContainerRocm.md on LinkedIn.`
- `Share 2025-11-07-SparkDataset.md on LinkedIn — SEO-friendly.`

You don't need to say "skill" — pairing a `_posts/*.md` filename with "LinkedIn" is enough to trigger.

### Output — in-chat text only

The skill prints the post **directly in the chat response** inside a fenced code block, like:

````
```
<HOOK + body, ≤ 50 words>

Read more:
https://ojitha.github.io/<category>/<YYYY>/<MM>/<DD>/<slug>.html

#Tag1 #Tag2 #Tag3 #Tag4 #Tag5 #Tag6 ...
```
````

After the code block, the skill summarises the prose word count, the derived URL, and the hashtag list, so you can sanity-check before pasting.

**No file is created. No directory is written.** Re-running the skill simply produces a fresh draft in the next response — there is nothing to clean up on disk.

### Writing rules the skill follows

- **Plain text only.** LinkedIn's main feed does not render markdown — no `**bold**`, no `# headers`, no `[label](url)`. Bare URLs become clickable on their own.
- **Short paragraphs** with blank lines between them — the LinkedIn idiom, easier to scan on mobile.
- **Concrete entities, repeated naturally** — 2–3 mentions across the post is what Google indexes.
- **Numbers over adjectives** — "128K context window" beats "huge context window".
- **No emojis** unless the source blog post uses them — match the blog's serious technical voice.
- **No clickbait** — undermines technical credibility.
- **First-person is fine** because you own the blog.

### Hashtag selection — comprehensive coverage

Because the prose is capped at 50 words, **hashtags are the primary SEO surface area**. The skill includes every relevant tag, mixing three scopes:

- **Broad category tags (1–3)** — match the post's overall domain: `#MachineLearning`, `#GenerativeAI`, `#DataEngineering`, `#Scala`, `#AWS`, `#Kubernetes`, `#Python`, `#FunctionalProgramming`, `#CloudComputing`, `#DevOps`, `#BigData`.
- **Entity-specific tags (3–7)** — one per major SEO entity from the post: `#Gemma4`, `#vLLM`, `#ROCm`, `#RyzenAI`, `#NPU`, `#Docker`, `#PyTorch`, `#ApacheSpark`, `#PySpark`, `#Terraform`, `#ElasticSearch`, `#LangGraph`, `#AWSCDK`, `#Hadoop`, `#HDFS`.
- **Audience tags (0–2, optional)** — when the post targets a specific community: `#OpenSource`, `#LLM`, `#EdgeAI`, `#MLOps`, `#DataScience`.

Format rules:

- **PascalCase** for multi-word tags (`#MachineLearning`, not `#machinelearning`).
- For single-word tools, **retain the canonical spelling** (`#vLLM` keeps the lowercase v that the project itself uses; `#ROCm` keeps the lowercase m AMD itself uses).
- All hashtags on a **single final line**, single-spaced, no duplicates, no punctuation.
- Aim for **6–10 hashtags total** — enough for comprehensive discoverability without triggering LinkedIn's over-tagging penalty.

### Verification (the skill always runs this before reporting done)

1. **Prose word count is ≤ 50** — counted, not estimated.
2. The published URL is correct — re-derived from the filename and string-compared.
3. **All relevant hashtags are present** — at least one broad tag and 3+ entity-specific tags. Total 6–10.
4. No markdown leaked through (no `**`, `[`, `](`, `# `).
5. The output is a code block in the chat response. **No file was written.**

Then it reports the prose word count (e.g. "47/50 words"), the derived URL, and the hashtags chosen.

---

## Adding a new skill to this project

1. Create `.claude/skills/<your-skill-name>/SKILL.md` with the standard YAML frontmatter (`name`, `description`).
2. Optionally add `references/`, `scripts/`, or `assets/` subfolders — Claude reads them on demand.
3. Add a section to this file describing the skill's purpose, inputs, invocation phrases, and any verification it runs.
4. Project-scoped skills only activate when Claude Code is launched from inside this repo.
