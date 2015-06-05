---
layout: post
title:  "Sweetener - Collection Restrictions - Part I"
date:   2015-05-18 19:59:12
categories: java
tags: java sweetener restrictions collections criteria
author: Łukasz Stypka
---
Search through the collection has always been a problem for developers and simple search enforced on the programmer writing many lines of code (Countless foreach, if-else constructions). Fortunately, class `Collections` solves this problem. The integral part of this class is `Criteria` and `Restriction` mechanism, which allows for complex query conditions. The restrictions can be joined in chain by *add* method. Example criteria is shown below:
{% highlight java %}
Criteria.newCriteria().add(Restrictions.isNotNull("company.name"))
        .add(Restrictions.contains("categoriesOfDrivingLicense", "B","D"))
        .add(Restrictions.greaterOrEquals("age", 24))
        .add(Restrictions.equals("name", "marry", true));
{% endhighlight %}
<br />
Criteria object created in this way can be used in `filter` method on `Collections`

{% highlight java %}
 public static <T> Collection<T> filter(Collection<T> collection, Criteria criteria) {
{% endhighlight %}

<br />
Many ``Restriction`` classes have been prepared in order to allow a smooth search through the collection. Some of them are intended for numbers, some of them are intended for Collections / Arrays and there are restrictions intended for any objects:

* **Restrictions for any objects**
	+ ``equals(String field, Object value)`` Checks whether object is equals to object passed as second parameter
	+ ``notEquals(String field, Object value)`` Checks whether object is not equals to object passed as second parameter
	+ ``isNull(String field)`` Checks whether object is null
	+ ``isNotNull(String field)`` Checks whether object is not null

* **Restrictions for String**
	+ ``equals(String field, Object value, boolean ignoreCase)`` Checks whether object is equals to object passed as second parameter ignoring case sensitivity
	+ ``notEquals(String field, Object value, boolean ignoreCase)`` Checks whether object is not equals to object from second parameter ignoring case sensitivity
	+ ``like(String field, String value)`` Checks whether object contains substring passed as second parameter
	+ ``notLike(String field, String value)`` Checks whether object does not contains substring passed as second parameter

* **Restrictions for Number**
	+ ``greater(String field, Number value)`` Check whether object is greater than the number passed as second parameter
	+ ``less(String field, Number value)`` Check whether object is less than the number passed as second parameter
	+ ``greaterOrEquals(String field, Number value)`` Check whether object is greater or equals to the number passed as second parameter
	+ ``lessOrEquals(String field, Number value)`` Check whether object is less or equals to the number passed as second parameter
	+ ``between(String field, Number minValue, Number maxValue)`` Check whether value is between the numbers passed as second and third parameter
	+ ``notBetween(String field, Number minValue, Number maxValue)`` Check whether value is not between the numbers passed as second and third parameter
	+ ``between(String field, Number minValue, Number maxValue, boolean leftInclusive, boolean rightInclusive)`` Check whether value is between the numbers passed as second and third parameter. leftInclusive/rightInclusive indicates whether point in left range/ right range should or shouldn't be taken into account 
	+ ``notBetween(String field, Number minValue, Number maxValue, boolean leftInclusive, boolean rightInclusive)`` Check whether value is not between the numbers passed as second and third parameter. leftInclusive/rightInclusive indicates whether point in left range/ right range should or shouldn't be taken into account
	
* **Restrictions for Collections / Arrays**
	+ ``contains(String field, Object... values)`` Checks whether object contains all objects passed as second parameter
	+ ``containsAny(String field, Object... values)`` Checks whether object contains any of objects passed as second parameter
	+ ``notContains(String field, Object... values)`` Checks whether object does not contain all objects passed as second parameter
	+ ``notContainsAny(String field, Object... values)`` Checks whether object does not contain any objects passed as second parameter
	+ ``in(String field, Object... values)`` Checks whether value is equals to one of objects passed as second, third ... parameter
	+ ``notIn(String field, Object... values)`` Checks whether value is not equals to any of objects passed as second, third ... parameter

	
<br />
<br />

### A bit of practice
Assume that we have ``Person`` object with the following properties

{% highlight java %}
public class Person {

    private String name;
    private String lastName;
    private int age;
    private Company company;
    private List<String> categoriesOfDrivingLicense = Collections.newArrayList();

	// contructor, getters and setters
}
{% endhighlight %}
Let's create lists of Person objects

{% highlight java %}
private List<Person> prepareListOfPeople() {
  List<Person> people = new ArrayList<Person>();
  people.add(new Person("John", "Wolf", 27, null, null));
  people.add(new Person("John", "Sky", 31, new Company("Jsolve", new Address("street1", "city1")),   prepareListOfCategories("B")));
  people.add(new Person("Marry", "Duke", 45, new Company("Sweetener", new Address("street2", null)),  prepareListOfCategories("A", "B")));
  people.add(new Person("Peter", "Hunt", 41, null, prepareListOfCategories("B", "D")));
  return people;
}
{% endhighlight %}

Now, we can perform some searches by using filter methods on Collections object:

{% highlight java %}
Collection<Person> filteredList = Collections.filter(people, Criteria.newCriteria()
  .add(Restrictions.isNotNull("company"))
  .add(Restrictions.containsAny("categoriesOfDrivingLicense", "A", "D")));

// As a result will be returned collection containing: Marry Duke
{% endhighlight %}

{% highlight java %}
Collection<Person> filteredList = Collections.filter(people, Criteria.newCriteria()
  .add(Restrictions.greaterOrEquals("age", 31)));

// As a result will be returned collection containing: John Sky, Peter Hunt, Marry Duke
{% endhighlight %}

{% highlight java %}
Collection<Person> filteredList = Collections.filter(people, Criteria.newCriteria()
  .add(Restrictions.like("company.address.street", "street")));

// As a result will be returned collection containing: John Sky, Marry Duke
{% endhighlight %}
