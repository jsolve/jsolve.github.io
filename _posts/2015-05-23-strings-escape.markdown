---
layout: post
title:  "Sweetener - Escapes"
date:   2015-05-23 16:03:03
categories: java
tags: java, sweetener, Strings, Escapes
author: Łukasz Stypka
---
Everyone, sooner or later, must face with escaping characters problem. For this reason we have created a special class `Escapes` as part of `sweetener` project, which goal is solve this problem. `Escapes` class contains five special methods to escape special characters for: 

* regular expression - `public static String escapeRegexp(String value)`
* html - `public static String escapeHtml(String value)`
* url - `public static String escapeUrl(String value)`
* xml - `public static String escapeXml(String value)`
* json - `public static String escapeJson(String value)`

<br />
Below are five examples, one for each method:

{% highlight java %}
String value = "Ala has a cat.";
String escapedValue = Escapes.escapeRegexp(value); // Ala has a cat\.

String value = "First line<br />";
String escapedValue = Escapes.escapeHtml(value); // First line&lt;br &#047;&gt;

String value = "http://www.jsolve.pl/about us";
String escapedValue = Escapes.escapeUrl(value); // http://www.jsolve.pl/about%20us

String value = "<root><element id='1' /></root>";
String escapedValue = Escapes.escapeXml(value); // &lt;root&gt;&lt;element id=&#039;1&#039; /&gt;&lt;/root&gt;

String value = "{"id" : 1, "name" : "jsolve"}";
String escapedValue = Escapes.escapeJson(value); // {\\"id\\" : 1, \\"name\\" : \\"jsolve\\"}
{% endhighlight %}

We have predicted situations in which you would like to define mapping by yourself. So, you can define special characters and use it! It is extremely easy:

{% highlight java %}
Map<Character, String> characters= Maps.newHashMap();
characters.put('\n', "<br />");

String value = "First line\nSecond line\nThird line\n";
String escapedValue = Escapes.escape(value, characters); // First line<br />Second line<br />Third line<br />
{% endhighlight %}

But what if to the existing characters you'd like to add your own, or remove superfluous? If you would like to use symbols already defined, you can get it:

{% highlight java %}
Map<Character, String> urlspecials = Escapes.getUrlspecials();
urlspecials.put(',', ".");
Escapes.escape(value, urlspecials);
{% endhighlight %}

Note that always when you get existing characters (for example `Escapes.getUrlspecials()`), method returns a new map. Original map is not modified.