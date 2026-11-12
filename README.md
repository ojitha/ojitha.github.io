# ojitha.github.io

Source for the personal blog at <https://ojitha.github.io>, built with Jekyll (`github-pages` gem) and the `jekyll/minima` remote theme.

## Post series

Posts that belong to a series show a series card near the top. The card has the series title, "Part N of M", a progress bar and the list of posts, with the current post highlighted.

| Layer | File | Responsibility |
|---|---|---|
| Data | `_data/series.yml` | Each series' title and its posts in reading order |
| Markup | `_includes/series.html` | Finds the post's series and renders the card |
| Placement | `_layouts/post.html` | Injects the card right after `<!--more-->` |
| Style | `_sass/minima/custom-styles.scss` (section *Series box*) | Card styles, including dark mode |

### Adding a post to a series

Add the post's source path to its series in `_data/series.yml`. For a new series, add a new key:

```yaml
k8s-on-pi5:
  title: Kubernetes on Raspberry Pi 5
  posts:
    - _posts/2026-01-03-K8sIntro.md
    - _posts/2026-11-03-K8sObjectModel.md
    - _posts/2026-11-08-K8sAIML.md
```

That's all. Nothing needs to go into the post itself.

- The post layout runs `_includes/series.html`. It looks up `page.path` in every series, and the part number is the post's position in that list. Reordering the list renumbers the posts.
- If the post is in a series, the card is inserted immediately after the `<!--more-->` excerpt separator, so it never appears in excerpts. If a series post has no separator, the card goes at the top of the post body.
- If the post isn't in any series, no card is shown. A post listed in more than one series gets a card for each.
- If a listed post doesn't exist yet (for example, it's future-dated or still a draft), its entry shows as "Coming soon".
- Don't add `{% include series.html %}` to a post manually, because the card would then appear twice.

### Changing the look

Edit only the *Series box* section of `_sass/minima/custom-styles.scss`. Colours are CSS custom properties (`--series-accent`, `--series-bg`, …) at the top of `.series-box`. Their dark-mode values are in the `series-box-dark` mixin, which applies to both `[data-theme="dark"]` and an OS dark preference.
