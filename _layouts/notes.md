--- 
layout: default 
---

<h2>{{ site.data.noteslist.docs_list_title }}</h2>

   {% for item in site.data.noteslist.docs %}
      <a href="{{ item.url }}">{{ item.title }}</a>,
   {% endfor %}



{{ content }}