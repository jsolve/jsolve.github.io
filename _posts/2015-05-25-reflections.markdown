---
layout: post
title:  "Sweetener - Reflections"
date:   2015-05-25 19:06:09
categories: java
tags: java sweetener reflections 
author: Łukasz Stypka
---

The main problem of working with reflection is that, you can only refer to the properties of the given class. If the property you are looking for is declared in the base class, you have a problem, and you are forced to move iteratively throughout the class hierarchy. 
This problem does not exists in any method of `Reflections` class.

## Accessing field value

### getFieldValue

{% highlight java %}
Person person = new Person("Peter", "Hunt", 41, new Company("Jsolve", new Address("street1", "city1")), prepareListOfCategories("B", "D"));
Object name = Reflections.getFieldValue(person, "name");
// name is Peter
{% endhighlight %}

It's also possible getting nested value:

{% highlight java %}
Person person = new Person("Peter", "Hunt", 41, new Company("Jsolve", new Address("street1", "city1")), prepareListOfCategories("B", "D"));
Object companyName = Reflections.getFieldValue(person, "company.name");
// company name is Jsolve
{% endhighlight %}

### setFieldValue

{% highlight java %}
private static final String NAME = "John";
...
Person person = new Person();
Reflections.setFieldValue(person, "name", NAME);
// person.getName() == "John"
{% endhighlight %}

It's also possible setting nested value, even if the nested object is null. In this case, null object is replaced by a new object.
{% highlight java %}

private static final String COMPANY_NAME = "Jsolve";
...
Person person = new Person();
Reflections.setFieldValue(person, "company.name", COMPANY_NAME);
// person.getCompany().getName() == "Jsolve"
{% endhighlight %}

Of course it is also possible to set the properties of the base class of the given class.

## Obtaining class elements

### Obtaining all class elements

The class `Reflections` also includes getters for fields, annotations, constructors, methods, classes of the given object. These methods retrieve data from the hierarchy of classes, not just from the current class.

{% highlight java %}
public static List<Class<?>> getClasses(Object object);
public static List<Field> getFields(Object object);
public static List<Annotation> getAnnotations(Object object);
public static List<Constructor<?>> getConstructors(Object object);
public static List<Method> getMethods(Object object);
{% endhighlight %}

### Obtaining annotated class elements
You can also get those elements that are annotated by certain annotation. To do so use one of the following methods:

{% highlight java %}
public static List<Field> getFieldsAnnotatedBy(Object object, final Class<? extends Annotation> annotation);
public static List<Method> getMethodsAnnotatedBy(Object object, final Class<? extends Annotation> annotation);
{% endhighlight %}

For example, if you would like to get all _deprecated_ methods of `java.util.Date` class you can write something like this:

{% highlight java %}
Date date = new Date();
List<Method> deprecatedMethods = Reflections.getMethodsAnnotatedBy(date, Deprecated.class);
{% endhighlight %}

### Obtaining certain class elements
You can specify which elements should be returned by passing a condition. The following list consists all available methods to do so:

{% highlight java %}
public static List<Class<?>> getClassesSatisfyingCondition(Object object, Condition<Class<?>> condition);
public static List<Field> getFieldsSatisfyingCondition(Object object, Condition<Field> condition);
public static List<Annotation> getAnnotationsSatisfyingCondition(Object object, Condition<Annotation> condition);
public static List<Constructor<?>> getConstructorsSatisfyingCondition(Object object, Condition<Constructor<?>> condition);
public static List<Method> getMethodsSatisfyingCondition(Object object, Condition<Method> condition);
{% endhighlight %}

They might look difficult at first but the usage is really simple. For example if you are interested in list of getter methods of `Hero` class just write:

{% highlight java %}
Hero hero = new Hero();
Condition<Method> getterMethodsCondition = new Condition<Method>() {
	@Override
	public boolean isSatisfied(Method method) {
		return method.getName().startsWith("get");
	}
};
List<Method> getters = Reflections.getMethodsSatisfyingCondition(hero, getterMethodsCondition);
{% endhighlight %}
