---
title: Home
nav_order: 00
layout: home
---
# The Linebreakers songbook
{% assign all_pages = site.pages %}
{% assign songs = all_pages | where: "layout", "song" %}
{% assign total_duration = 0 %}
{% for song in songs %}
{% assign total_duration = total_duration | plus: song.duration %}
{% endfor %}
<h4>Total duration:
	{{total_duration | divided_by: 3600 | floor }}hr
	{{total_duration | modulo: 3600 | divided_by: 60 | floor }}m
	{{total_duration | modulo: 60 | floor | plus: 100 | slice: 1, 2 }}s
</h4>
<ol>
{% for song in songs %}<li>
<a href="{{ song.url }}">{{ song.title }}</a>
	({{song.duration | divided_by: 60 | floor }}:{{song.duration | modulo: 60 | floor | plus: 100 | slice: 1, 2 }})
</li>
{% endfor %}
</ol>
