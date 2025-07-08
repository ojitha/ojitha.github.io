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



{% assign sorted = site.categories | sort: name  %}
{% for category in sorted %}

<h4 class="folder-category">{{ category[0] }}</h4>
<ul>
    {% for post in category[1] %}
      <li><a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endfor %}
</ul>  
{% endfor %}
