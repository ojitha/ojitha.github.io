# ojitha.github.io

Source for the personal blog at <https://ojitha.github.io>, built with Jekyll (`github-pages` gem) and the `jekyll/minima` remote theme.

## Post series

Posts that belong to a series show a series card near the top. The card has the series title, "Part N of M", a progress bar and the list of posts, with the current post highlighted.

Each part of the feature lives in its own file:

| Layer | File | Responsibility |
|---|---|---|
| Data | `_data/series.yml` | Each series' title and its posts in reading order |
| Markup | `_includes/series-box.html` | Renders the card for a series `id` |
| Style | `_sass/minima/custom-styles.scss` (section *Series box*) | Card styles, including dark mode |
| Stubs | `_includes/series/<id>.md` | One-line wrappers so posts can keep including `series/<id>.md` |

### Defining a series

Add an entry to `_data/series.yml`. The key is the series id, and posts are listed by their source path:

```yaml
k8s-on-pi5:
  title: Kubernetes on Raspberry Pi 5
  posts:
    - _posts/2026-01-03-K8sIntro.md
    - _posts/2026-11-03-K8sObjectModel.md
    - _posts/2026-11-08-K8sAIML.md
```

For a **new** series, also create the stub `_includes/series/<id>.md`:

```liquid
{% include series-box.html id="<id>" current=include.current %}
```

### Using it in a post

Place the include after the `<!--more-->` excerpt separator so it doesn't appear in excerpts:

```liquid
<!--more-->
{% include series/k8s-on-pi5.md current="2" %}
```

- `current` is optional. The template works out the current part by matching the post's path against the list in `_data/series.yml`.
- If a listed post doesn't exist yet (for example, it's future-dated or still a draft), its entry shows as "Coming soon".
- `series-box.html` can also be included directly with `id="<id>"`. With no `id`, it falls back to the page's `series:` front-matter value.

> Posts synced from sibling repos (see `makefiles/*.mk`) must have the include line added in the source notebook, not in the copy in `_posts/`.

### Changing the look

Edit only the *Series box* section of `_sass/minima/custom-styles.scss`. Colours are CSS custom properties (`--series-accent`, `--series-bg`, …) at the top of `.series-box`. Their dark-mode values are in the `series-box-dark` mixin, which applies to both `[data-theme="dark"]` and an OS dark preference.
