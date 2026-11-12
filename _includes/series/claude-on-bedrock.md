This post is part of a series on **Claude on AWS Bedrock**

{% assign series_paths = "_posts/2026-09-13-BedrocClaude_1.md,_posts/2026-09-16-BedrockClaude_2.md,_posts/2026-09-18-BedrockClaude_3.md,_posts/2026-09-19-BedrockClaude_4.md,_posts/2026-09-20-BedrockClaude_5.md,_posts/2026-09-21-BedrockClaude_6.md" | split: "," %}
{% assign current = include.current | plus: 0 %}
{% for path in series_paths -%}
{% assign post = site.posts | where: "path", path | first -%}
{% capture item %}[{{ post.title }}]({{ post.url | relative_url }}){:target="_blank" rel="noopener noreferrer"}{% endcapture -%}
{{ forloop.index }}. {% if forloop.index == current or path == page.path %}**{{ item }}**{% else %}{{ item }}{% endif %}
{% endfor %}
