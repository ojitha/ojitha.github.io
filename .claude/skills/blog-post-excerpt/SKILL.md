---
name: blog-post-excerpt
description: Use this skill whenever the user wants to add or update an excerpt with an inline SVG illustration in a Jekyll blog post under `/Users/ojitha/GitHub/ojitha.github.io/_posts/`. Triggers include phrases like "create an excerpt for post X", "add a TLDR", "add SVG illustration", "draw a thumbnail", "generate excerpt", or any request that pairs a markdown file from `_posts/` with a drawing style such as "pencil sketch", "oil", "impressionist", "watercolor", "charcoal", or "pop art" — even if the user does not say the word "skill" or "excerpt". Make sure to use this skill any time both a `_posts/*.md` filename and a drawing style are mentioned together.
---

# Blog Post Excerpt (ojitha.github.io)

Generate an inline SVG illustration in a chosen drawing style plus a short HTML summary, and inject both into the Jekyll front matter `excerpt:` field of a post under `/Users/ojitha/GitHub/ojitha.github.io/_posts/`.

## Required inputs

Confirm both before doing any work:

1. **Markdown filename** — a file in `/Users/ojitha/GitHub/ojitha.github.io/_posts/`. Accept either a bare name (`2026-05-05-Gemma4.md`) or a full path; resolve to the absolute path.
2. **Drawing style** — e.g. *pencil sketch*, *oil*, *impressionist*, *watercolor*, *charcoal*, *pop art*. If the user names another style, follow the spirit of the Style Guide below.

If either is missing, ask once and then proceed.

## Workflow

### 1. Read the post

Read the entire markdown file. You need the title, the leading paragraphs, and a sense of which technical terms recur — that is what the SVG and excerpt should reflect.

### 2. Identify the technical jargon

Pick **3 to 6** terms that genuinely characterise the post. Good picks are concrete: framework names, algorithm names, tool names, hardware names, key concepts (e.g. *vLLM*, *MIGraphX*, *Functor*, *Monad*, *KV cache*). Skip generic words like "data", "guide", "system".

These same words must appear, legible, inside the SVG.

### 3. Build the SVG (150 × 150 px, inline)

Produce a **single self-contained SVG** that:

- Has `width="150" height="150"` and `viewBox="0 0 150 150"`.
- Reflects the requested drawing style — colour is required even for pencil sketch (use muted washes).
- Contains the technical jargon words as readable `<text>` elements (`font-family="sans-serif"`, size 9–13 px, contrasting fill).
- Is fully self-contained: no `<image href=...>` to remote files, no web fonts, no external CSS.
- Stays small (aim under ~3 KB) so it embeds cleanly in YAML front matter.
- **Uses double quotes for all attributes**, so the outer YAML single-quoted string is not broken.

The SVG should *look* like a thumbnail for the post — choose 1–2 simple visual motifs that reflect the topic, and place the jargon words on or near them. Don't try to draw anything photo-realistic; abstract is fine and usually better.

See `references/style-guide.md` for concrete per-style rendering tips and a worked example for each style.

### 4. Write the excerpt (~100 words of HTML)

Write a single `<p>...</p>` block that summarises the post in roughly **90–110 words**. Use `<b>...</b>` to highlight 2–4 of the same jargon terms used in the SVG. Prose only — no `<ul>`, no `<br>`. This is what shows on the blog index page next to the thumbnail, so it should read naturally to a human skim-reader.

### 5. Inject into the front matter

Locate the existing `excerpt:` line in the YAML front matter (between the two `---` lines at the top of the file). The placeholder pattern looks like one of:

```yaml
excerpt: '<div class="image-text-container"><div class="image-column"><image></div><div class="text-column">TLDR</div></div>'
```

Replace, in this exact line:

- `<image>`  → the full SVG markup from step 3.
- `TLDR` → the HTML excerpt from step 4.

If the file has **no** `excerpt:` line, insert a new one immediately before the closing `---` of the front matter, using the full template above and then doing the two replacements.

### 6. YAML safety check

The whole `excerpt:` value is a single-quoted YAML string. That means:

- All attributes inside the SVG and HTML **must use double quotes** (`fill="#abc"`, not `fill='#abc'`).
- If any single quote (`'`) sneaks into your content (e.g. an apostrophe in the prose), escape it by doubling it: `it''s`. This is YAML's single-quote escape, not a typo.
- Do **not** switch the outer quoting to double quotes — other tooling in the repo expects single-quoted excerpts.
- Keep the entire value on **one physical line**. No literal newlines inside the value.

## Verification (always run before reporting done)

After editing, re-read the first ~20 lines of the file and check, in order:

1. The front matter still opens and closes with `---`.
2. The `excerpt:` line starts with `'<div class="image-text-container">` and ends with `</div></div>'`.
3. No unescaped single quotes inside the value.
4. The SVG block contains `<svg` … `</svg>` and the chosen jargon words appear as `<text>` content.
5. The text-column prose is roughly 100 words (count, don't guess).

If any check fails, fix it before reporting. Then tell the user the path to the updated post and which jargon words you chose.

## Style notes

- This skill **only modifies the front matter**. Do not touch the body of the post.
- Do not save the SVG as a separate file — it lives inline in the YAML.
- If the user later asks for a different style, rerun the skill on the same file; it should overwrite the previous SVG cleanly because the placeholder structure is identical.
