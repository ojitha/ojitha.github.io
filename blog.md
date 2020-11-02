---
layout: page
title: Blog
permalink: /blog/
---

My official tech [blog](https://ojitha.blogspot.com.au):

- [Mac keyboard shortcut to copy file path as markdown](https://ojitha.blogspot.com/2020/06/macos-quick-action-to-copy-markdown.html)
- [How to create step guides](https://ojitha.blogspot.com/2020/05/annotated-screenshot-in-mac-preview.html)
- [Toolbox for bloggers](https://ojitha.blogspot.com/2020/05/animated-gif-for-blogger.html)
- [Python my workflow](https://ojitha.blogspot.com/2020/05/python-my-workflow.html)
- [MAC shortcuts](https://ojitha.blogspot.com/2020/04/mac-shortcuts.html)

are the recent blogs.

## Algorithms
- [Binary search in Python]({% link _posts/2020-10-29-binary-search-in-python.md %})
- [Selection sort in Python]({% link _posts/2020-10-31-selection-sort-in-python.md %})

<!-- This loops through the paginated posts -->
{% for post in paginator.posts %}
<h1><a href="{{ post.url }}">{{ post.title }}</a></h1>
<p class="author">
    <span class="date">{{ post.date }}</span>
</p>
<div class="content">
    {{ post.content }}
</div>
{% endfor %}

<!-- Pagination links -->
<div class="pagination">
    {% if paginator.previous_page %}
    <a href="{{ paginator.previous_page_path }}" class="previous">
      Previous
    </a> {% else %}
    <span class="previous">Previous</span> {% endif %}
    <span class="page_number ">
    Page: {{ paginator.page }} of {{ paginator.total_pages }}
  </span> {% if paginator.next_page %}
    <a href="{{ paginator.next_page_path }}" class="next">Next</a> {% else %}
    <span class="next ">Next</span> {% endif %}
</div>