---
layout: default
title: Tags
---

<section class="posts">
  <h1>{{ page.title }}</h1>
  {% assign tags = site.tags | sort %}
  <ul>
    {% for tag in tags %}
      <li>
        <a href="/tag/{{ tag | first | slugify }}/">
          {{ tag[0] | replace:'-', ' ' }} ({{ tag | last | size }})
        </a>
      </li>
    {% endfor %}
  </ul>
</section>
