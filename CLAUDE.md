# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Jekyll blog (https://ojitha.github.io) hosted on GitHub Pages and built with the `github-pages` gem. It uses the remote theme `jekyll/minima` (v3, pinned to a commit in `_config.yml`), with local overrides. There is no test suite or linter; to verify a change, build the site and look at it in a browser.

## Commands

Always run Jekyll inside Docker, not with a host `bundle exec`. The `Dockerfile` uses a `ruby:3.1` image with bundler 2.4.22 and gems in the `bundle_cache` volume at `/usr/local/bundle`. Its entrypoint runs `bundle install` if gems are missing. The default `CMD` serves the site on port 4000 with `--config _config.yml,_config_dev.yml --livereload --force_polling --drafts` (livereload port 35729). `docker-compose.yml` mounts the repo at `/app` and sets `JEKYLL_ENV=development`. Use the Compose v2 CLI (`docker compose`), not the legacy `docker-compose` binary.

```bash
./dev.sh start      # docker compose up --build → http://localhost:4000
./dev.sh stop | restart | rebuild | logs | shell
./dev.sh clean      # full rebuild: removes image, bundle volume, Gemfile.lock
```

One-off commands in the container (for example a production-config build to check for errors):

```bash
docker compose run --rm jekyll bundle exec jekyll build
docker compose run --rm jekyll bundle exec jekyll build --config _config.yml,_config_dev.yml
```

`_config_dev.yml` overrides production settings. It turns on incremental builds and profiling, sets `paginate: 2`, disables GA, and drops `jekyll-algolia`/`jemoji`. Keep `jekyll-remote-theme` in its plugin list; without it the theme is silently skipped and pages render with no `<html>`/`<head>`/CSS. `_config.yml` isn't reloaded while the server runs, so restart after editing it.

Syncing posts from sibling repos:

```bash
make                  # all sections
make SECTION=bedrock  # one section: makefiles/<SECTION>.mk
```

## Architecture

### Post sourcing via Makefile
Many posts in `_posts/` are **not written here**. They're authored as Jupyter notebooks in sibling repos (for example `../learn-bedrock/blogs`, `../learn-scala2/blogs`, `../spark-algorithms/blogs`, `../learn-k8s/blogs`, `../LLMTuning/blogs`). Each `makefiles/<section>.mk` lists a source dir and post stems and calls `register-section`. That call:
1. builds `<stem>.md` from `<stem>.ipynb` by running the sibling repo's own Makefile (using the venv at `../notebooks/jupyter/.venv`),
2. copies the `.md` into `_posts/`,
3. copies `<src>/assets/images/<stem>/` into `assets/images/<stem>/`.

If a post belongs to one of those sections, edit the source in the sibling repo, not the copy in `_posts/`, because `make` will overwrite the copy. To add a new synced post, append its stem to the matching `.mk` file.

### Front matter flags control optional includes
`_includes/header.html` (which overrides minima's header) only loads these includes when the page's front matter asks for them:
- `mermaid: true` → `_includes/mermaid.html`: Mermaid 12 ESM from CDN, custom render and error box, zoom/pan wrapper with a control pad, and a re-render when the theme changes
- `maths: true` → `_includes/maths.html` (MathJax 4, kramdown `math_engine: mathjax`)
- `linkedinbagage: true` → LinkedIn badge

`_layouts/post.html` includes the floating `_includes/toc.html` unless `toc: false`. Posts usually also have a kramdown `* TOC\n{:toc}` block. Use `<!--more-->` as the excerpt separator. Many posts start with `{% include video-summary.html id="" content="" %}`.

### Dark mode
The theme toggle lives in `header.html`. It sets `data-theme="light|dark"` on `<html>` and saves the choice in `localStorage['minima-theme']`. `_includes/custom-head.html` applies the saved theme before first paint. Any new component styles need a `[data-theme="dark"] …` variant, and JS that renders theme-dependent output should watch `data-theme` with a MutationObserver (as `mermaid.html` does).

### Styles
`assets/css/style.scss` imports the minima skin (`skin: auto`) plus local overrides in `_sass/minima/` (`custom-styles.scss`, `custom-variables.scss`). Nav pages come from `minima.nav_pages` in `_config.yml`.

### Notes section
`notes.md` uses `_layouts/notes.html`, which renders topic buttons from `_data/noteslist.yml`. Topic pages are `notes/*.md` with `layout: notes`. `_data/notes_metadata.yml` holds per-topic titles and tags.

### Deploy and search
When you push to `master`, `.github/workflows/algolia-search.yml` builds the site with `actions/jekyll-build-pages` and deploys it to Pages. It then runs the repo's own composite action (`action.yml`, `uses: ojitha/ojitha.github.io@master`), which calls `bundle exec jekyll algolia` to update the Algolia index. `.travis.yml` is legacy.

### Repo skills
`.claude/skills/` contains `blog-post-excerpt` and `blog-post-linkedin`, for writing post excerpts and LinkedIn promo text.
