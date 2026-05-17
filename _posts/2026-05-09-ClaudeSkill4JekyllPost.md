---
layout: post
title:  "A Learning Guide to the blog-post-excerpt Claude Skill"
date:   2026-05-09
categories: [Claude, Skills]
toc: true
mermaid: false
maths: false
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
excerpt: '<div class="image-text-container"><div class="image-column"><svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 150 150"><defs><pattern id="d" x="0" y="0" width="6" height="6" patternUnits="userSpaceOnUse"><circle cx="3" cy="3" r="1" fill="#000"/></pattern></defs><rect width="150" height="150" fill="#ffd900"/><rect x="0" y="85" width="150" height="65" fill="#ff3355" stroke="#000" stroke-width="2.5"/><circle cx="115" cy="35" r="20" fill="#3a8eff" stroke="#000" stroke-width="2.5"/><rect x="0" y="85" width="150" height="65" fill="url(#d)" opacity="0.35"/><text x="60" y="42" font-family="sans-serif" font-weight="bold" font-size="13" fill="#000" text-anchor="middle">SKILL.md</text><text x="115" y="40" font-family="sans-serif" font-weight="bold" font-size="11" fill="#fff" text-anchor="middle">SVG</text><text x="75" y="72" font-family="sans-serif" font-weight="bold" font-size="13" fill="#000" text-anchor="middle">Jekyll</text><text x="75" y="115" font-family="sans-serif" font-weight="bold" font-size="14" fill="#fff" text-anchor="middle">YAML</text><text x="75" y="135" font-family="sans-serif" font-weight="bold" font-size="10" fill="#fff" text-anchor="middle">TLDR · excerpt</text></svg></div><div class="text-column"><p>A practical, end-to-end walkthrough of the project-scoped blog-post-excerpt Claude skill that lives in this repository under .claude/skills/. The guide follows the chapter structure of Anthropic''s Complete Guide to Building Skills for Claude and applies each principle to the working skill that automates <b>Jekyll</b> front-matter excerpt generation. Learn how progressive disclosure splits across <b>SKILL.md</b>, its body, and the references folder; how to craft a triggering description; how to inject an inline <b>SVG</b> illustration plus a TLDR into a single line of <b>YAML</b>; and how a final verification step keeps the front matter from breaking on every run.</p></div></div>'
---

A practical, end-to-end walkthrough of the project-scoped `blog-post-excerpt` Claude skill that lives in this repository under `.claude/skills/blog-post-excerpt/`. The guide follows the chapter structure of Anthropic's *Complete Guide to Building Skills for Claude*[^complete-guide] and applies each principle to the real, working skill that automates Jekyll front-matter excerpt generation for `ojitha.github.io`.

* TOC
{:toc}

## 1. Why this guide exists

Anthropic's *Complete Guide to Building Skills for Claude*[^complete-guide] explains, in general terms, how a Claude skill is structured, how progressive disclosure works, what the YAML frontmatter must contain, how to test triggering, and how to distribute a skill once it works. Those rules are abstract until you see them applied to a real skill that you actually use day-to-day.

This document takes the working `blog-post-excerpt` skill in this repository and walks through every chapter of the guide using that skill as the worked example. By the end you should be able to read the source files of `blog-post-excerpt`, understand every design choice, explain how each of Anthropic's recommended patterns shows up in it, and use the same pattern to build your own project-scoped skill — for example, a sibling skill for a different repository or a different style of post.

The skill itself does one job: given a Jekyll markdown post under `_posts/` and a drawing style (e.g. *oil*, *watercolor*, *pop art*), it generates a 150 × 150 px inline SVG illustration plus a roughly 100-word HTML summary, and injects both directly into the `excerpt:` field of the post's YAML front matter. No file output other than the rewritten post; no body changes; no separate image asset. Every part of that one-sentence description is a deliberate design decision, and the rest of this guide explains why.

## 2. Fundamentals — anatomy of a real skill

Anthropic defines a skill as a folder containing one required file (`SKILL.md`) and three optional sub-folders (`scripts/`, `references/`, `assets/`). The `blog-post-excerpt` folder follows that exact shape with the smallest possible footprint:

```
.claude/skills/blog-post-excerpt/
├── SKILL.md
└── references/
    └── style-guide.md
```

There is no `scripts/` folder because no executable code is needed: SVG generation is something Claude can do directly with its built-in markdown and code-writing capabilities. There is no `assets/` folder because the SVG is generated fresh per post — there are no fixed templates, fonts, or icons to ship. What remains is the mandatory `SKILL.md` and a single reference file that holds per-style rendering tips.

This is a textbook example of **progressive disclosure**, the first core design principle in the Anthropic guide. The skill uses the three-level system exactly as recommended:

The first level is the YAML frontmatter at the top of `SKILL.md`. It is always loaded into Claude's system prompt and is what Claude uses to decide whether the skill is even relevant to the current request. Look at the description and you can see that it lists every phrase that should trigger loading — "create an excerpt for post X", "add a TLDR", "add SVG illustration", "draw a thumbnail", "generate excerpt" — plus every supported style word and an explicit cue that the presence of *both* a `_posts/*.md` filename *and* a drawing style is enough on its own. This is the single most important field in the entire skill, because it determines whether the body of `SKILL.md` ever gets loaded.

The second level is the body of `SKILL.md` itself. It is loaded only when Claude has decided the skill is relevant. It contains the workflow steps, the inputs to confirm, the YAML safety rules, and the verification checklist — everything Claude needs to actually run the workflow correctly.

The third level is `references/style-guide.md`. It is bundled inside the skill folder but is not loaded by default. Claude reads it on demand, only when it has to actually draw an SVG in a particular style. The reference file contains a complete, valid worked SVG for each of the six supported styles, plus rendering tips. None of that detail belongs in `SKILL.md` because it would consume context tokens for every invocation, even ones where Claude is just picking jargon and re-using a known visual vocabulary.

The other two core principles named in the Anthropic guide — **composability** and **portability** — also show up here. The skill makes no assumption that it is the only capability available; it sits alongside `blog-post-linkedin` in the same `.claude/skills/` directory and never trips over it because the trigger language is disjoint (LinkedIn vs. excerpt + drawing style). And the skill is portable in the sense that it would work identically on Claude.ai, in Claude Code, or via the API, because it depends on nothing more than the ability to read and edit a markdown file at a known path.

## 3. Planning and design — what problem does this skill solve?

Anthropic recommends starting with two or three concrete use cases before writing any code. The use case for `blog-post-excerpt` is a single, very sharp one, which is part of why the skill is so reliable.

**Use case: Generate a thumbnail and TLDR for a freshly-written Jekyll post.**

> *Trigger:* User says some variation of "create an excerpt for `<filename>` in `<style>` style."
>
> *Steps:* (1) Read the post end-to-end. (2) Pick 3–6 technical jargon terms that genuinely characterise it. (3) Build a 150 × 150 inline SVG in the requested drawing style with the jargon as readable `<text>`. (4) Write a roughly 100-word HTML summary that highlights the same jargon in `<b>`. (5) Inject both into the `excerpt:` front-matter line by replacing the `<image>` and `TLDR` placeholders. (6) Verify the YAML still parses.
>
> *Result:* The post's index-page card now has a coloured thumbnail and a one-paragraph summary, with no body changes and no separate image asset on disk.

That fits cleanly into Anthropic's **Category 1: Document & Asset Creation** — the skill produces a consistent, high-quality artefact (the SVG + excerpt) using only Claude's built-in capabilities, with no external tools and no MCP server. There is a small flavour of **Category 2: Workflow Automation** as well because the skill enforces a five-step pipeline with a verification gate at the end, but the dominant character is asset creation.

The success criteria for the skill, mapped onto the Anthropic guide's quantitative and qualitative metrics, look like this in practice. On the quantitative side, the skill should trigger automatically whenever a post filename and a style word both appear in a request — that is the description's explicit promise. It should complete the full workflow in roughly a single Read followed by a single Edit on the target file, which is the minimum tool-call count possible. And the rewritten YAML should always parse, which is what the verification step at the end of the workflow guarantees. On the qualitative side, a re-run with a different style should cleanly overwrite the previous SVG with no manual cleanup, and the chosen jargon should be specific enough that a reader who has never seen the post can glance at the thumbnail and the highlighted bold terms and form an accurate first impression of what the post is about.

The design choice to embed the SVG *inline in the YAML*, rather than as a separate file referenced by URL, is worth dwelling on because it explains many of the constraints downstream. By keeping the SVG inline, the skill avoids polluting the `assets/` directory with a thumbnail per post, avoids any path-juggling or image-pipeline integration, and ensures the entire visual contract of a post is contained in a single line of YAML that travels with the post wherever it goes. The cost is that the SVG must be small (under ~3 KB), self-contained (no external references), and YAML-safe (double quotes only, no embedded newlines, single quotes escaped as `''`). Those costs are modest, and they are spelled out as explicit rules inside `SKILL.md`.

## 4. The YAML frontmatter — first level of progressive disclosure

The frontmatter at the top of `SKILL.md` is the most important text in the skill. Here is the relevant portion:

```yaml
---
name: blog-post-excerpt
description: Use this skill whenever the user wants to add or update an excerpt with an inline SVG illustration in a Jekyll blog post under `/Users/ojitha/GitHub/ojitha.github.io/_posts/`. Triggers include phrases like "create an excerpt for post X", "add a TLDR", "add SVG illustration", "draw a thumbnail", "generate excerpt", or any request that pairs a markdown file from `_posts/` with a drawing style such as "pencil sketch", "oil", "impressionist", "watercolor", "charcoal", or "pop art" — even if the user does not say the word "skill" or "excerpt". Make sure to use this skill any time both a `_posts/*.md` filename and a drawing style are mentioned together.
---
```

Measured against the Anthropic field requirements, this passes every check. The name is in kebab-case, has no spaces or capitals, and matches the folder name. The description includes both *what the skill does* (add or update an excerpt with an inline SVG illustration in a Jekyll blog post) and *when to use it* (the long list of trigger phrases plus the rule about pairing a `_posts/*.md` filename with a style word). It mentions the relevant file pattern (`_posts/*.md`) so Claude can pattern-match against any incoming request that names such a file. It contains no XML angle brackets, which is the security restriction the guide calls out. And it stays well under the 1024-character limit while still being specific enough to avoid both undertriggering and overtriggering.

The most subtle design move in the description is the closing sentence: *"Make sure to use this skill any time both a `_posts/*.md` filename and a drawing style are mentioned together."* That sentence is doing the work of a conjunctive trigger rule. It tells Claude that the *combination* of two cues — a Jekyll post path and a style word — is sufficient on its own, even if no other trigger phrase is present and even if the user never says the word "skill". This is exactly the "include trigger phrases users would actually say" recommendation from the Anthropic guide, with an extra piece of decision logic baked in.

The skill omits all the optional frontmatter fields — `license`, `compatibility`, `metadata` — because none of them would change Claude's behaviour. That is fine. Optional fields are optional. Adding `metadata` with `version` and `author` would be reasonable if the skill ever gets shared outside the repo, but for a project-scoped skill that lives next to the code it supports, the minimal frontmatter is enough.

## 5. Walking through the workflow

The body of `SKILL.md` is structured as a numbered, six-step workflow. Each step is a small, verifiable action, and most of them have explicit acceptance criteria. This is the *be specific and actionable* recommendation from the Anthropic guide taken seriously.

### Step 1 — Read the post

The instruction is "Read the entire markdown file. You need the title, the leading paragraphs, and a sense of which technical terms recur — that is what the SVG and excerpt should reflect." Note the explicit *why*. Claude is not just told to read; it is told what it is reading *for*. That makes the next step possible.

### Step 2 — Identify the technical jargon

The skill says: pick 3–6 terms that genuinely characterise the post. Good picks are concrete — framework names, algorithm names, tool names, hardware names, key concepts. The example terms given are *vLLM*, *MIGraphX*, *Functor*, *Monad*, *KV cache*. The skill explicitly rules out generic words like *data*, *guide*, *system*. This rules-out list is what stops the skill from picking lazy terms that would make every post's thumbnail look generic.

The crucial constraint is in the next sentence: *"These same words must appear, legible, inside the SVG."* That single sentence couples Step 2 to Step 3 and Step 4, and it is what gives the post's thumbnail and TLDR a visual through-line. Without that constraint, the SVG might say "vLLM" while the bolded words in the excerpt are "ROCm" and "NPU" and the actual post is about something else entirely.

### Step 3 — Build the SVG

The constraints on the SVG are spelled out as a checklist: 150 × 150 viewBox, the requested drawing style (with colour required even for pencil sketch), the jargon words as readable `<text>` in sans-serif at 9–13 px, fully self-contained with no `<image href=...>` and no web fonts, under ~3 KB, and double quotes for all attributes so the outer YAML single-quoted string does not break.

Most of those constraints exist because the SVG is going to live inside a single-quoted YAML scalar. The double-quote rule is the most important one — if any attribute used `'` instead of `"`, the YAML parser would terminate the scalar early and the front matter would silently break. The self-containment rule (no remote `<image href>`, no web fonts) makes the post portable: a reader behind a corporate proxy that blocks third-party assets still sees the thumbnail correctly, because there is no third-party asset to fetch.

The aesthetic guidance — "choose 1–2 simple visual motifs that reflect the topic" and "abstract is fine and usually better" — is a deliberate brake on Claude's tendency to over-engineer. Photo-realism is unattainable in a 3 KB SVG anyway, so the skill leans into the limitation and asks for abstraction instead.

### Step 4 — Write the excerpt

A single `<p>...</p>` block of roughly 90–110 words. Use `<b>...</b>` to highlight 2–4 of the same jargon terms used in the SVG. Prose only — no `<ul>`, no `<br>`. The constraints exist because the excerpt is going to render on the index page as a paragraph next to the thumbnail; lists and line breaks would fight the layout. The word count window (90–110, not "about 100") is narrow enough that Claude has to actually count, which is what the verification step at the end of the workflow checks.

### Step 5 — Inject into the front matter

The skill describes two valid placeholder shapes — the canonical `<image>` and the historical typo `<imgage>` that appears in older posts — and tells Claude to treat them identically. This is a small but instructive detail: rather than asking the user to clean up old posts before running the skill, the skill absorbs the inconsistency. That is the *be specific and actionable* principle taken to a useful extreme — acknowledging real-world messiness in the instructions rather than pretending it does not exist.

If the post has no `excerpt:` line at all, the skill inserts one immediately before the closing `---` of the front matter, using the standard template, and then performs the two replacements. So a brand-new post that was never set up with a placeholder still works.

### Step 6 — YAML safety check

Four rules: all attributes inside the SVG and HTML must use double quotes; any single quote that sneaks into the prose (e.g. `it's`) must be escaped by doubling it (`it''s`); the outer quoting must remain single-quoted; and the entire value must stay on one physical line. This step exists because YAML front matter is famously brittle, and a single stray apostrophe in the middle of a 4 KB excerpt value would break Jekyll's build of the entire site.

## 6. Verification — the always-runs guard

After the six workflow steps, the skill ends with a verification block that the Anthropic guide recommends including in any non-trivial skill. The block re-reads the first ~20 lines of the file and checks, in order:

The front matter still opens and closes with `---`. The `excerpt:` line starts with `'<div class="image-text-container">` and ends with `</div></div>'`. There are no unescaped single quotes inside the value. The SVG block contains `<svg` … `</svg>` and the chosen jargon words appear as `<text>` content. The text-column prose is roughly 100 words — *count, don't guess.*

If any check fails, the skill's instruction is to fix the problem before reporting done. This is the difference between a skill that "tries its best" and a skill that ships a working result every time. The Anthropic guide's *advanced technique* note — that for critical validations you should consider bundling a script that performs the check programmatically rather than relying on language instructions — is worth flagging here. The current `blog-post-excerpt` skill does its verification with a re-read and a manual word count. A natural next iteration would be to add a small `scripts/verify.py` that parses the YAML, validates the SVG with a real XML parser, and counts words deterministically. Until then, the language-level checklist is enough because the surface area is small (one line of YAML) and Claude is good at counting up to 110.

## 7. Drawing styles — the third level of progressive disclosure

The `references/style-guide.md` file is where the skill's progressive disclosure pays off. It contains six fully worked SVG examples, one per supported style:

| Style              | Visual feel                                                          | Palette                                          |
|--------------------|----------------------------------------------------------------------|--------------------------------------------------|
| **pencil sketch**  | Thin grey strokes, light cross-hatching, muted pastel washes         | Cream background, soft pastels                   |
| **oil**            | Thick saturated strokes, no fine detail, no outlines, bright highlight | Deep umber/indigo background, rich reds/ochres  |
| **impressionist**  | Many small coloured dabs, no outlines, suggestion over definition     | Light pastel-bright                              |
| **watercolor**     | Translucent pools with `feGaussianBlur` bleeding edges               | Soft blues, peaches, greens on off-white paper   |
| **charcoal**       | Dark rough strokes with smudged shading, one faint colour accent      | Sketchpad cream + near-black + single warm accent |
| **pop art**        | Bold flat colours, thick black outlines, optional benday dots        | Bright primaries + black + cream                 |

Each entry in the reference file gives both a complete valid SVG and a short list of *tips* — for example, for pencil sketch: stroke width between 0.4 and 0.8, add 2–4 short hatching lines near edges, pastel fills with `fill-opacity` 0.4–0.6. For oil: background a deep dark colour, three to four broad overlapping shapes, one bright highlight, text in cream `#fef3c7` for legibility on dark.

The reference file ends with a fallback section: *if the user names a style not listed here, improvise within these principles* — always include colour, always include the jargon as legible `<text>`, use only inline SVG primitives, keep under ~3 KB. This means the skill gracefully degrades for unknown styles instead of refusing to run, which keeps it useful for the long tail of style requests.

The crucial design lesson is that none of this style detail lives in `SKILL.md`. It would bloat the always-loaded body of the skill with 100+ lines of SVG examples that are only relevant when Claude is actually drawing. By moving the per-style detail to `references/`, the body of `SKILL.md` stays focused on the *workflow* and Claude only pays the token cost of loading style examples on the runs where it is going to draw something.

## 8. Patterns this skill demonstrates

Of the five patterns that Anthropic's *Patterns and troubleshooting* chapter[^complete-guide] catalogues, `blog-post-excerpt` cleanly demonstrates two and partially demonstrates a third.

**Pattern 1: Sequential workflow orchestration.** The skill is a strict six-step sequence. Each step depends on its predecessors: jargon selection (Step 2) requires the read (Step 1); SVG generation (Step 3) requires the jargon (Step 2); the excerpt prose (Step 4) reuses the same jargon; injection (Step 5) requires both Step 3 and Step 4; verification (Step 6) requires Step 5 to have happened. There is explicit step ordering, dependencies between steps, validation at the final stage, and an implied rollback (re-run the skill cleanly overwrites the previous SVG because the placeholder structure is identical).

**Pattern 3: Iterative refinement.** The verification step is, in effect, an iterative refinement loop with a single explicit acceptance check. *If any check fails, fix it before reporting.* That is the same pattern as Anthropic's report-generation example, just compressed: there is no need for multiple refinement passes because the change surface is one line of YAML, but the *quality criteria → run check → fix if needed* loop is identical.

**Pattern 5: Domain-specific intelligence (partial).** The skill embeds two pieces of project-specific domain knowledge that no generic skill could carry. First, the `excerpt:` placeholder convention used by this repository (`<div class="image-text-container">…<image>…<div class="text-column">TLDR</div>…`). Second, the historical `<imgage>` typo in older posts and the rule to treat it identically to `<image>`. Without that embedded knowledge, a user would have to re-explain the placeholder structure on every invocation. With it, the skill captures the convention once and applies it consistently.

The two patterns the skill does not use — multi-MCP coordination and context-aware tool selection — are not relevant here because the skill operates on a single file with no external services involved.

## 9. Triggering — by design, not by accident

The Anthropic guide's testing chapter lays out three areas: triggering tests, functional tests, and performance comparison. The triggering rules for `blog-post-excerpt` are explicit enough that you can write a small mental test suite and check them by hand.

**Should trigger:**

> "Run blog-post-excerpt on `2026-05-05-Gemma4.md` in oil style." — names both inputs explicitly, uses the skill name; trivial trigger.
>
> "Add a TLDR to `2026-04-08-ObsidianMethod.md` as a watercolor." — uses one of the listed trigger phrases ("add a TLDR") plus a style word; trigger.
>
> "Draw a thumbnail for `2025-11-07-SparkDataset.md`, impressionist." — uses a trigger phrase ("draw a thumbnail") plus a style; trigger.
>
> "Create an excerpt for `2025-10-31-Functional-Programming-Abstractions-in-Scala.md`, pencil sketch." — combines a `_posts/*.md` filename with a style word, which the closing sentence of the description explicitly identifies as sufficient.
{:.ok}

Here the experimantal versions:
> "Create an excerpt for `2026-05-09-ClaudeSkill4JekyllPost.md` in hand-drawn cartoon comic style — ink outlines with watercolour fills, a small character scene that personifies the topic, like a children's-book illustration"
{:.warn}

A shorter variant:

>"Add a TLDR to 2026-05-09-ClaudeSkill4JekyllPost.md as an ink-and-watercolour cartoon with a character scene."
{:.warm}

**Should not trigger:**

> "What's the weather in San Francisco?" — no filename, no style; no trigger.
>
> "Write a LinkedIn post for `2026-05-05-Gemma4.md`." — names a `_posts/*.md` filename but no style word, and explicitly mentions LinkedIn — should hand off to the sibling `blog-post-linkedin` skill instead.
>
> "Help me write Python code." — neither input present; no trigger.
{:.bad}

The `blog-post-linkedin` neighbour is interesting because it shares half a trigger condition with `blog-post-excerpt` (both react to a `_posts/*.md` filename) but the disambiguating cue is the second word — "LinkedIn" vs. a drawing style. As long as those two trigger sets stay disjoint, the two skills will not fight over the same request.

## 10. Troubleshooting — what to do when things go sideways

The Anthropic guide's troubleshooting chapter lists five failure modes; here is how each one applies to `blog-post-excerpt`.

**Skill won't upload.** Not relevant here — the skill is project-scoped and discovered automatically by Claude Code from `.claude/skills/`, not uploaded through Settings. The equivalent failure for a project-scoped skill is *the skill is not auto-discovered when Claude Code is launched from the repo root*. The fix is to verify the folder is named in kebab-case (it is: `blog-post-excerpt`), the file is named exactly `SKILL.md` (it is, case-sensitive), and the YAML frontmatter parses (delimiters, no unclosed quotes).

**Skill doesn't trigger.** If a request that should obviously trigger the skill does not — for example, "thumbnail for the Gemma post" without naming the file or style — the fix per the Anthropic guide is to revise the description to include more trigger phrases. The current description is already generous, but you could imagine adding "Gemma" or other recurring topic words if a particular phrasing kept missing.

**Skill triggers too often.** If the skill loads on irrelevant requests — for example, a generic "draw something nice" with no Jekyll context — the fix is to add a negative trigger or be more specific. The current description is already quite specific (it scopes itself to `/_posts/` and to the placeholder pattern), so this failure mode is unlikely in practice.

**MCP connection issues.** Not relevant — the skill uses no MCP server. This is one of the reasons it is so robust: the only thing that can fail is the file edit, and the file edit is verified at the end.

**Instructions not followed.** This is the most likely real-world failure: Claude reads `SKILL.md`, picks reasonable jargon, draws an SVG, but then forgets to escape an apostrophe and breaks the YAML. The skill mitigates this in three ways. First, by making the YAML safety rules explicit in Step 6 of the workflow. Second, by re-reading the front matter in the verification step to catch the mistake. Third, by being short enough overall that the critical rules are never buried — the body of `SKILL.md` is well under 5,000 words, with the per-style detail offloaded to references.

The Anthropic guide's *advanced technique* note — that for critical validations you should bundle a script — is the natural next step if instruction-following turns out to be unreliable in practice. A `scripts/verify.py` that parses the YAML and the SVG with real parsers would catch any kind of escape mistake deterministically.

**Large context issues.** Not a current problem because `SKILL.md` is concise and `references/style-guide.md` is loaded only when needed. If the skill ever grows new styles, new placeholder shapes, or new repository conventions, the right move is to keep the body of `SKILL.md` lean and let the new detail land in the references folder.

## 11. Distribution — when a project skill is the right answer

The Anthropic guide's distribution chapter focuses on sharing a skill with other people: hosting it on GitHub, writing a human-facing README at the repo root (separate from the skill folder, which must not contain a `README.md`), uploading the zipped folder through Claude.ai's Settings, or deploying it organisation-wide as an admin.

`blog-post-excerpt` does none of those things by choice. It is a **project-scoped skill** — it lives inside the same repository as the content it operates on, under `.claude/skills/blog-post-excerpt/`. It is discovered automatically by Claude Code when launched from the repo root and it is invisible from any other project. There is no upload step, no zipping, no version management, no README, and no audience beyond the maintainer of this site.

That choice has real benefits. The skill is versioned alongside the content it understands — when the repository's excerpt placeholder convention changes, the skill that uses that convention can change in the same commit. There is no risk of a stale uploaded copy of the skill drifting away from the repo it was built for. And anyone cloning the repo gets the skill for free, with no extra setup.

The trade-off is that no one outside this repository's working tree benefits from the skill. If the same excerpt-injection pattern starts appearing in other Jekyll sites, the right next step is to lift the skill out of `.claude/skills/`, generalise the placeholder pattern, and publish it as a standalone GitHub repository following the Anthropic guide's distribution recipe — public repo, root-level README, installation instructions, and a section in any related MCP documentation that links to it.

This site documents both skills in the project's `skill-usage.md` file at the repository root, which doubles as a discoverability aid and a contract — the file describes the trigger phrases, required inputs, verification rules, and YAML safety requirements for each skill, so a future maintainer (or a new collaborator running Claude Code in this repo) can read one file and understand both skills end-to-end.

## 12. How to actually invoke the skill

In Claude Code launched from the repo root, the skill triggers on any of the following — and on many obvious paraphrases beyond these:

> Run blog-post-excerpt on `2026-05-05-Gemma4.md` in oil style.
>
> Add a TLDR to `2026-04-08-ObsidianMethod.md` as a watercolor.
>
> Create an excerpt for `2025-10-31-Functional-Programming-Abstractions-in-Scala.md`, pencil sketch.
>
> Generate the front-matter excerpt for `2026-03-07-ContainerRocm.md` in pop art style.
>
> Draw a thumbnail for `2025-11-07-SparkDataset.md`, impressionist.

You do not have to say "skill" or use the exact skill name — pairing a `_posts/*.md` filename with a drawing style is enough, as the description's closing sentence promises.

A typical run takes Claude one Read on the target post, an inferred jargon list, a drafted SVG and excerpt, one Edit on the same file, and a final re-read for verification. The whole interaction is two or three tool calls, and the only side effect is that the `excerpt:` line of the post is rewritten in place.

## 13. Lessons for building your own skill

If you take away nothing else from this walkthrough, take away these five points, all of which the Anthropic guide[^complete-guide] states in general terms and `blog-post-excerpt` demonstrates in specifics.

First, **scope the skill to one job**. The skill does excerpt injection for Jekyll posts under one specific `_posts/` directory. It does not also do LinkedIn promotion, image cropping, or category management. The narrowness is what makes it reliable.

Second, **invest in the description field**. It is the only part of the skill that is always loaded. List the trigger phrases users will actually say, not the phrases you wish they would say. Add a conjunctive rule (filename plus style word, in this case) so Claude can fire on combinations even when no single explicit phrase matches.

Third, **use the three-level progressive disclosure deliberately**. Frontmatter for triggering, `SKILL.md` body for workflow, references for detail that only matters during execution. Resist the urge to put per-style examples or per-edge-case notes in the body — they belong in `references/`.

Fourth, **end with verification**. Even if it is a manual checklist re-read, give Claude an explicit *did this work?* step. For higher-stakes skills, replace the manual checklist with a bundled script. Code is deterministic; language interpretation is not.

Fifth, **document the skill outside the skill itself**. The Anthropic guide says not to put a `README.md` inside the skill folder, and it is right. But you should still write down — somewhere a human maintainer will find it — what the skill does, how to invoke it, what it verifies, and what conventions it depends on. In this repository that file is `skill-usage.md` at the repo root. In a distributed skill it would be the GitHub repo's root README.

The `blog-post-excerpt` skill is small, but it is small the way good code is small: every line earns its place. Read its source once with this guide open and the whole shape of the Anthropic guide's recommendations will fall into place.

## 14. Source files referenced in this guide

[`.claude/skills/blog-post-excerpt/SKILL.md`](computer:///Users/ojitha/GitHub/ojitha.github.io/.claude/skills/blog-post-excerpt/SKILL.md) — the skill itself.

[`.claude/skills/blog-post-excerpt/references/style-guide.md`](computer:///Users/ojitha/GitHub/ojitha.github.io/.claude/skills/blog-post-excerpt/references/style-guide.md) — per-style SVG worked examples, loaded on demand.

[`skill-usage.md`](computer:///Users/ojitha/GitHub/ojitha.github.io/skill-usage.md) — the repository-level human-facing documentation for both project-scoped skills.

[`_posts/2026-05-05-Gemma4.md`](computer:///Users/ojitha/GitHub/ojitha.github.io/_posts/2026-05-05-Gemma4.md) — a worked example of the skill's output, with the rewritten `excerpt:` line on line 11.

[^complete-guide]: [The-Complete-Guide-to-Building-Skill-for-Claude.pdf](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf){:target="_blank" rel="noopener noreferrer"}
