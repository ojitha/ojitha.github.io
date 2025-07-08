---
layout: default 
---

<style>
.button-link {
  display: inline-block;
  padding: 2px 4px;
  margin: 4px;
  border: 2px solid #007bff;
  color: #007bff;
  text-decoration: none;
  border-radius: 8px;
  transition: border-color 0.3s, color 0.3s;
}
.button-link:hover {
  border-color: #0056b3;
  color: #0056b3;
}
</style>

<h2>{{ site.data.noteslist.docs_list_title }}</h2>

   {% for item in site.data.noteslist.docs %}
      <a href="{{ item.url }}" class="button-link">{{ item.title }}</a>
   {% endfor %}



{{ content }}