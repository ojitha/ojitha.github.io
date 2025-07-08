---
layout: page
title: Tags
permalink: /blog/
---

<style>
.folder-category {
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 12px 16px;
  margin: 8px 0;
  position: relative;
}
.folder-category::before {
  content: "📁";
  margin-right: 8px;
}
</style>

## Quick Navigation
{% assign sorted = site.categories | sort: name  %}
{% for category in sorted %}<a href="#{{ category[0] | slugify }}" style="display: inline; padding: 4px 8px; margin: 2px; background-color: #e9ecef; border-radius: 4px; text-decoration: none; color: #495057;">#{{ category[0] }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}

{% assign sorted = site.categories | sort: name  %}
{% for category in sorted %}

<h4 class="folder-category" id="{{ category[0] | slugify }}">{{ category[0] }}</h4>
<ul>
    {% for post in category[1] %}
      <li><a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endfor %}
</ul>  
{% endfor %}
