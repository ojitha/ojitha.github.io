# ojitha.github.io

Source for the personal blog at <https://ojitha.github.io>, built with Jekyll (`github-pages` gem) and the `jekyll/minima` remote theme.

## Post series

Posts that belong to a series show a series card near the top. The card has the series title, "Part N of M", a progress bar and the list of posts, with the current post highlighted.

| Layer | File | Responsibility |
|---|---|---|
| Data | `_data/series.yml` | Each series' title and its posts in reading order |
| Markup | `_includes/series.html` | Finds the post's series and renders the card |
| Style | `_sass/minima/custom-styles.scss` (section *Series box*) | Card styles, including dark mode |

### Adding a post to a series

1. Add the post's source path to the series in `_data/series.yml`. For a new series, add a new key:

   ```yaml
   k8s-on-pi5:
     title: Kubernetes on Raspberry Pi 5
     posts:
       - _posts/2026-01-03-K8sIntro.md
       - _posts/2026-11-03-K8sObjectModel.md
       - _posts/2026-11-08-K8sAIML.md
   ```

2. Put the same line in the post, after the `<!--more-->` excerpt separator so it doesn't appear in excerpts:

   ```liquid
   <!--more-->
   {% include series.html %}
   ```

That's it: there are no per-series include files and no part numbers to maintain.

- The include looks up `page.path` in every series in `_data/series.yml`, and the part number is the post's position in that list. Reordering the list renumbers the posts.
- A post listed in more than one series gets a card for each. A post not listed in any series renders nothing, so the line is harmless.
- If a listed post doesn't exist yet (for example, it's future-dated or still a draft), its entry shows as "Coming soon".
- `{% include series.html id="<series-id>" %}` forces a specific series. On a page that isn't part of it, it shows the list without a current part.

> Posts synced from sibling repos (see `makefiles/*.mk`) must have the include line added in the source notebook, not in the copy in `_posts/`.

### Changing the look

Edit only the *Series box* section of `_sass/minima/custom-styles.scss`. Colours are CSS custom properties (`--series-accent`, `--series-bg`, …) at the top of `.series-box`. Their dark-mode values are in the `series-box-dark` mixin, which applies to both `[data-theme="dark"]` and an OS dark preference.
