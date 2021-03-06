---
layout: post
title:  "Jsolve - Projects in Maven Central"
date:   2015-05-23 09:16:03
categories: java
tags: java sweetener oven type-converter maven
author: Łukasz Stypka
---
Jsolve - Projects in Maven Central! From now Sweetener, Oven and Type-converter are in Maven Cetral.  
Current versions of our libraries are: sweetener: 1.0.0, oven: 1.0.1, type-converter: 1.0.1. In order to use it in maven project just add the below dependency to your pom file.

#### Sweetener
{% highlight xml %}
<dependency>
    <groupId>pl.jsolve</groupId>
    <artifactId>sweetener</artifactId>
    <version>1.0.0</version>
</dependency>
{% endhighlight %}
<br />

#### Oven
{% highlight xml %}
<dependency>
    <groupId>pl.jsolve</groupId>
    <artifactId>oven</artifactId>
    <version>1.0.1</version>
</dependency>
{% endhighlight %}
<br />

#### Type-Converter
{% highlight xml %}
<dependency>
    <groupId>pl.jsolve</groupId>
    <artifactId>typeconverter</artifactId>
    <version>1.0.1</version>
</dependency>
{% endhighlight %}

<br />
<br />

## Snapshot repository

In order to use snapshot repository add the following repository to your repositories section:
{% highlight xml %}
<repositories>
    <repository>
        <id>sonatype-snapshots</id>
        <url>https://oss.sonatype.org/content/repositories/snapshots</url>
    </repository>
</repositories>
{% endhighlight %}

and add snapshot dependency:

#### Sweetener
{% highlight xml %}
<dependency>
    <groupId>pl.jsolve</groupId>
    <artifactId>sweetener</artifactId>
    <version>1.0.1-SNAPSHOT</version>
</dependency>
{% endhighlight %}
<br />

#### Oven
{% highlight xml %}
<dependency>
    <groupId>pl.jsolve</groupId>
    <artifactId>oven</artifactId>
    <version>1.0.2-SNAPSHOT</version>
</dependency>
{% endhighlight %}
<br />

#### Type-Converter
{% highlight xml %}
<dependency>
    <groupId>pl.jsolve</groupId>
    <artifactId>typeconverter</artifactId>
    <version>1.0.2-SNAPSHOT</version>
</dependency>
{% endhighlight %}

If you don't use maven in your project, just download jar file directly from : <a href="https://search.maven.org/#browse%7C825784231">here</a>
