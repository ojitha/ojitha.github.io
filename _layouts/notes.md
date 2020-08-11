--- 
layout: default 
---

<h2>{{ site.data.noteslist.docs_list_title }}</h2>
<ul>
   {% for item in site.data.noteslist.docs %}
      <li><a href="{{ item.url }}">{{ item.title }}</a></li>
   {% endfor %}
</ul>

{{ content }}