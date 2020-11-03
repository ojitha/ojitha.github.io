---
layout: page
title: Blog
permalink: /blog/
---

## Tech
My official tech [blog](https://ojitha.blogspot.com.au):

- [Mac keyboard shortcut to copy file path as markdown](https://ojitha.blogspot.com/2020/06/macos-quick-action-to-copy-markdown.html)
- [How to create step guides](https://ojitha.blogspot.com/2020/05/annotated-screenshot-in-mac-preview.html)
- [Toolbox for bloggers](https://ojitha.blogspot.com/2020/05/animated-gif-for-blogger.html)
- [Python my workflow](https://ojitha.blogspot.com/2020/05/python-my-workflow.html)
- [MAC shortcuts](https://ojitha.blogspot.com/2020/04/mac-shortcuts.html)

are the recent blogs.

## GitHub
My [GitHub](https://github.com/ojitha) blogs:
{% assign sorted = site.categories | sort: name  %}
{% for category in sorted %}
<h3>{{ category[0] }}</h3>
<ul>
    {% for post in category[1] %}
      <li><a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endfor %}
</ul>  
{% endfor %}
