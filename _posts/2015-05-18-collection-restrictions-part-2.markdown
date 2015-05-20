---
layout: post
title:  "Sweetener - Collection Restrictions - Part II - Filtering by date"
date:   2015-05-20 17:54:00
categories: java
comments: true
tags: java, sweetener, restrictions, collection, criteria
author: Łukasz Stypka
---
Filtering objects by using `Date` class is a very common problem. There are times when we want find objects, for which one of the field is in some time range. Such an example may be find all people who were born before the year 1988. However, there is problem with dates in Java, namely the lack of a uniform approach. There are still applications which use `java.util.Date` or `java.util.Calendar`. In addition to the `java.util.Date` there is also `java.sql.Date`. Modern applications written in Java < SE 8 use JodaTime library to represent date. It has introduced several new classes of date: `DateTime`, `LocalDate`, `LocalTime`, `LocalDateTime`. All of these classes are located in `org.joda.time` package. In the SE8 these classes have been integrated into the standard SE8 and have been placed in `java.time`. As you can see there is a very large number representation of a date in Java. For this reason, it is hard to create a generic restriction which could operate on all of these date types. To solve this problem, we have prepared a special mechanism that allows comparison of the dates of any type, we've create `DateExtractor` interface. For each type of date used during filtering you should register appropriate extractor:

{% highlight java %}
Restrictions.registerDateExtractor(LocalDate.class, dateExtractor);
{% endhighlight %}

Below there are examples implementations of `DateExtractor`:

**LocalDate**
{% highlight java %}
Restrictions.registerDateExtractor(LocalDate.class, new DateExtractor<LocalDate>() {

	@Override
	public Date extract(LocalDate d) {
		return d.toDate();
	}
});
{% endhighlight %}

**LocalTime**
{% highlight java %}
Restrictions.registerDateExtractor(LocalTime.class, new DateExtractor<LocalTime>() {

	@Override
	public Date extract(LocalTime d) {
		return d.toDateTimeToday().toDate();
	}
});
{% endhighlight %}

**LocalDateTime**
{% highlight java %}
Restrictions.registerDateExtractor(LocalDateTime.class, new DateExtractor<LocalDateTime>() {

	@Override
	public Date extract(LocalDateTime d) {
		return d.toDate();
	}
});
{% endhighlight %}
<br /><br />
For `Date` class have been created two methods in `Restrictions` class:

* ``after(String field, Object value)`` Checks whether date is after date passed as second parameter
* ``before(String field, Object value)`` Checks whether date is before date passed as second parameter

<br />
**Example usage**

{% highlight java %}
LocalDateTime threshold = LocalDateTime.parse("1988-01-01T00:00:00");
     
Collection<ObjectWithLocalDateTime> filteredList = 
	Collections.filter(people, Criteria.newCriteria().add(Restrictions.before("birthday", threshold)));

// As a result will be returned collection containing people born before 1988
{% endhighlight %}