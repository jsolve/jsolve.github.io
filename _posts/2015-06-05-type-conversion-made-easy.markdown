---
layout: post
title:  "Type conversion made easy"
date:   2015-06-05 18:02
categories: java
tags: java, type-converter
author: Tomasz Kuryłek
---
In strongly typed languages, like Java, conversion between multiple types can be really painful. How many times did you forget how to convert `Date` to `Calendar`? How about conversion between collections? The operation is often performed in multiple lines of code and in no time you find yourself focusing on the type juggling instead of problem solving.
   
That's why we came up with [TypeConverter](https://github.com/jsolve/type-converter). It's a utility class that makes type conversion very easy. It's very fast and extendable.

### Overview
To use `TypeConverter` execute `convert()` method with object and expected type as parameters.
{% highlight java %}
Target convertedObject = TypeConverter.convert(objectThatWillBeConverted, Target.class)
{% endhighlight %}

so for example to convert `String` to `Double`

{% highlight java %}
Double result = TypeConverter.convert("12", Double.class);
{% endhighlight %}

or `Date` to `Calendar`:

{% highlight java %}
Date now = new Date();
Calendar calendar = TypeConverter.convert(now, Calendar.class);
{% endhighlight %}

or even `List<Integer>` to `Integer[]`:

{% highlight java %}
List<Integer> integersList = Arrays.asList(1, 2, 3);
Integer[] integersArray = TypeConverter.convert(integersList, Integer[].class);
{% endhighlight %}

It's always short and easy.

### What conversions are supported
Multiple conversions are supported out of the box. Take a look at the following list:
   
 - `Boolean` <-> `Integer`
 - `String` <-> `Number`
 - `Number` <-> `Number`
 - `Long` <-> `java.util.Date`,
 - `Long` <-> `java.util.Calendar`,
 - `java.util.Date` <-> `java.util.Calendar`.
 - `Array` <-> `Collection`
 - `Collection` <-> `Collection`
 - `Object` -> `String`

**All primitives** are also supported so you don't have to worry about boxing. 
   
Your type is not on the list? You can easily "teach" `TypeConverter` new conversion.

### Custom converters
To create new converter just create a class that implements `Converter` interface, i.e.:

{% highlight java %}
class ObjectToStringConverter implements Converter<Object, String> {

   @Override
   public String convert(Object source) {
      return source.toString();
   }
}
{% endhighlight %}

And pass it to the `TypeConverter`:

{% highlight java %}
TypeConverter.registerConverter(Object.class, String.class, new ObjectToStringConverter());
{% endhighlight %}

To make it more readable you can use anonymous class:

{% highlight java %}
TypeConverter.registerConverter(Object.class, String.class, new Converter<Object, String>() {
	@Override
	public String convert(Object source) {
		return source.toString();
	}
});
{% endhighlight %}

TypeConverter is also lambda friendly so if you are using java 8 in your project it gets as simple as:

{% highlight java %}
// lambda
TypeConverter.registerConverter(Object.class, String.class, source -> source.toString());

// method reference
TypeConverter.registerConverter(Object.class, String.class, Object::toString);
{% endhighlight %}
   
It's worth to note that our newly registered converter from Object.class to String.class **will override any already registered converter that supports the same conversion**.

As registering converters is very easy, unregistering them is even easier:

{% highlight java %}
TypeConverter.unregisterConverter(Source.class, Target.class);
{% endhighlight %}


### How do I get this?

We're on Maven Central so just add this to your `pom.xml`:
{% highlight xml %}
<dependency>
    <groupId>pl.jsolve</groupId>
    <artifactId>typeconverter</artifactId>
</dependency>
{% endhighlight %}

or [use any other maven like tool](http://mvnrepository.com/artifact/pl.jsolve/typeconverter). Or even if you are into old school and coding without any project manager just [download the jar](http://central.maven.org/maven2/pl/jsolve/typeconverter/1.0.1/typeconverter-1.0.1.jar)

**Happy type-converting!**

