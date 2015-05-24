---
layout: post
title:  "Sweetener - Collections - New methods"
date:   2015-05-24 18:03:13
categories: java
tags: java, sweetener, Collections, 
author: Łukasz Stypka
---
Today, I would like to introduce you new methods of `pl.jsolve.sweetener.collection.Collections` class.  Classes included in the package 'collection' provides a set of methods to facilitate the work of well-known classes from the core Java: List, Set, Map, array as well. 

#### Filter method

{% highlight java %}
public static <T> Collection<T> filter(Collection<T> collection, Criteria criteria)
{% endhighlight %}

This method allows user to filter collection passed as first argument by specified criteria.
Assume that we have prepared list of objects:

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

For this list we can prepare some filtering conditions:

<br />

**WHERE (company IS NOT NULL) AND (categoriesOfDrivingLicense CONTAINS ANY ['A', 'D'])**

{% highlight java %}
Collection<Person> filteredList = Collections.filter(people, Criteria.newCriteria()
  .add(Restrictions.isNotNull("company"))
  .add(Restrictions.containsAny("categoriesOfDrivingLicense", "A", "D")));

// As a result will be returned collection containing: Marry Duke
{% endhighlight %}
<br />

**WHERE age >= 31**

{% highlight java %}
Collection<Person> filteredList = Collections.filter(people, Criteria.newCriteria()
  .add(Restrictions.greaterOrEquals("age", 31)));

// As a result will be returned collection containing: John Sky, Peter Hunt, Marry Duke
{% endhighlight %}

<br />

**WHERE company.address.street like 'street'**

{% highlight java %}
Collection<Person> filteredList = Collections.filter(people, Criteria.newCriteria()
  .add(Restrictions.like("company.address.street", "street")));

// As a result will be returned collection containing: John Sky, Marry Duke
{% endhighlight %}

<br /><br /> 

#### Truncate
`truncate` allows developer to getting piece of the collection. This method is available in two versions:

{% highlight java %}
public static <T extends Collection<?>> T truncate(T collection, int to);
public static <T extends Collection<?>> T truncate(T collection, int to, int from);
{% endhighlight %}

**Parameters**

* from - the beginning index, inclusive.
* to - the ending index, exclusive.

<br />

#### Pagination
Every developer knows that the pagination should be done on the database side. Unfortunately, there are situations when we get the whole list, and manually have to split it into pages. 
To speed up work on pagination, the `paginate` method has been created.
Lets say we have a list of the letters of the alphabet:

{% highlight java %}
List<String> alphabet = new ArrayList<>();
alphabet.add("A");
alphabet.add("B");
alphabet.add("C");
alphabet.add("D");
alphabet.add("E");
alphabet.add("F");
alphabet.add("G");
alphabet.add("H");
alphabet.add("I");
...
{% endhighlight %}

If you want to display only the four elements, you should use:

{% highlight java %}
Pagination<String> firstPage= Collections.paginate(alphabet, 0, 4);
List<String> lettersOfTheFirstPage = firstPage.getgetElementsOfPage(); 
// As the result will be returned: A, B, C, D
Pagination<String> secondPage= Collections.paginate(alphabet, 1, 4);
List<String> lettersOfTheSecondPage = secondPage.getgetElementsOfPage(); 
// As the result will be returned: E, F, G, H
{% endhighlight %}

Pagination object has the following construction:

{% highlight java %}
public class Pagination<T> {

	private final int page;
	private final int resultsPerPage;
	private final int totalElements;
	private final int numberOfPages;
	private final Collection<T> elementsOfPage;
	
	// getters and setters
}
{% endhighlight %}
One important thing. `paginate` method never thrown IndexOutOfBoundsException, instead of exception, method returns object with empty collection : elementsOfPage.  
Easy and enjoyable, right?
<br />

#### Chop elements
Method `chop` is very similar to `paginate`, but you don't have to invoke it for each page. The signature of this method is the following:

{% highlight java %}
public static <T> ChoppedElements<T> chopElements(Collection<T> collection, int resultsPerPage);
{% endhighlight %}

ChoppedElement object has the following construction:

{% highlight java %}
public class ChoppedElements<T> {

private int page;
private final int resultsPerPage;
private final int totalElements;
private final int numberOfPages;
private final List<Collection<T>> listOfPages;

public boolean hasNextPage();
public void nextPage();
public boolean hasPreviousPage();
public void previousPage();
public Collection<T> getElementsOfPage();
public int getPage();
public void setPage(int page);
public int getResultsPerPage();
public int getTotalElements();
public int getNumberOfPages();
public List<Collection<T>> getListOfPages();
{% endhighlight %}

The usage of this method is as simple as using the `paginate` method. All what you have to do is specify the collection and the number of items per page:

{% highlight java %}
ChoppedElements<String> choppedElements = Collections.chopElements(alphabet, 4);
List<String> firstPage = choppedElements.getElementsOfPage(); // A, B, C, D
choppedElements.hasNextPage(); // true
choppedElements.nextPage();
choppedElements.getPage(); // 1
List<String> secondPage = choppedElements.getElementsOfPage(); // E, F, G, H
choppedElements.setPage(0);
List<String> onceAgainFirstPage = choppedElements.getElementsOfPage(); // A, B, C, D

etc...
{% endhighlight %}

#### Group
Imagine that you have a huge list of students. In your application you don't want to display all at once, but instead, you want to group them according to the department, field of study, and the semester. Assuming that the list contains the following objects:

{% highlight java %}
public class Student extends Person {

	private int semester;
	private FieldOfStudy fieldOfStudy;
	private Department department;
	// getters and setters
}

public class Person {

	private String firstName;
	private String lastName;
	private int age;
	private Address address;
	// getters and setters
}
{% endhighlight %}

you can do it in an extremely simple way! 

{% highlight java %}
// Example list of students
List<Student> students = new ArrayList<>();
students.add(new Student("John", "Deep", 3, FieldOfStudy.MATHS, Department.AEI));
students.add(new Student("Marry", "Duke", 3, FieldOfStudy.BIOINFORMATICS, Department.AEI));
students.add(new Student("John", "Knee", 3, FieldOfStudy.BIOINFORMATICS, Department.AEI));
students.add(new Student("Peter", "Hunt", 5, FieldOfStudy.BIOINFORMATICS, Department.MT));
students.add(new Student("Lucas", "Sky", 7, FieldOfStudy.COMPUTER_SCIENCE, Department.AEI));

Map<GroupKey, List<Student>> groups = Collections.group(students, "semester", "fieldOfStudy", "department");
{% endhighlight %}

In the above example the following groups were created:

*  Semester: 3, FieldOfStudy: Maths, Department: AEI  = > John Deep
*  Semester: 3, FieldOfStudy: Bioinformatics, Department: AEI => Marry Duke, John Knee
*  Semester: 5, FieldOfStudy: Maths, Department: MT => Peter Hunt
*  Semester: 7, FieldOfStudy: Computer science, Department: AEI => Lucas Sky

#### Duplicates

Not always searching for duplicates means search for items with the same references. From time to time, for example, we want to find elements with the same identifiers. How do it do fast? Probably two nested loops with 'if construction' inside. What if we distinguish duplicate items by more than one argument? For this reason we have created the `duplicates` method. The signature is the following:

{% highlight java %}
public static <E> Map<GroupKey, List<E>> duplicates(Collection<E> collection, String ... properties);
{% endhighlight %}

Suppose that we have a product object:

{% highlight java %}
public class Product {
   private String producer;
   private String productName;
   private double price;
}
{% endhighlight %}

All products must have a unique pair: producer and product name. So these two fields will help us to find duplicate products:

{% highlight java %}
Map<GroupKey, List<Product>> duplicates = Collections.duplicates(products, "producer", "productName");
{% endhighlight %}

#### Uniques
By invoking the `uniques` will be returned only unique values. So, it is the opposite method to the `duplicates`.

Example usage:

{% highlight java %}
List<Product> uniques = Collections.uniques(products, "producer", "productName");
{% endhighlight %}