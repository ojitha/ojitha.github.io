This post is part of a series on **Kubernetes on Raspberry Pi 5:**

{% assign series_paths = "_posts/2026-01-03-K8sIntro.md,_posts/2026-11-03-K8sObjectModel.md,_posts/2026-11-08-K8sAIML.md" | split: "," %}
{% assign current = include.current | plus: 0 %}
{% for path in series_paths -%}
{% assign post = site.posts | where: "path", path | first -%}
{% capture item %}[{{ post.title }}]({{ post.url | relative_url }}){:target="_blank" rel="noopener noreferrer"}{% endcapture -%}
{{ forloop.index }}. {% if forloop.index == current or path == page.path %}**{{ item }}**{% else %}{{ item }}{% endif %}
{% endfor %}
