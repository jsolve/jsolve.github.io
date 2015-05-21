---
layout: post
title:  "Unit testing exceptions in Java"
date:   2015-05-18 19:59:12
categories: java
tags: java, unit testing, sweetener, exceptions, ExceptionCatcher
author: Tomasz Kuryłek
---
Testing exceptions is crucial when you are into defensive programming. Ensuring your code behaves correctly under unforeseen circumstances. Though JUnit's `@Test(expected = ...)` seems to 
be good enough, there are cases where you might find your tests green when they shouldn't. The bad thing is it verifies whether an exception was thrown in whole test method:

{% highlight java %}
@Test(expected = ExpectedException.class)
public void testException() {
	// given
	preparingToTest();

	// when
	testIfThisMethodThrowsException();

	// then an exception is thrown
}
{% endhighlight %}
   
At first this test looks ok but what if `preparingToTest()` would throw `ExpectedException`? The test would still be green even though the `testIfThisMethodThrowsException()` was never executed.
Because of that some people try to stick with JUnit3-style exception catching. Take a look at the same test written using JUnit3:
   
{% highlight java %}
@Test 
public void testException() {
	// given
	preparingToTest();
	
	// when
	ExpectedException caughtException = null;
	try {
		testIfThisMethodThrowsException();
		fail("Expected exception to be thrown");
	} catch (ExpectedException e) {
		caughtException = e;
	}
	
	// then
	assertThat(caughtException).isNotNull();
}
{% endhighlight %}
   
There are several problems with this test. We have a rule of thumb - code inside 'when' statement should not contain more than one operation. But as you can see it does a lot. 
You need to initialize caughtException with null (which is easy to forget), perform the exceptional operation, catch and assign thrown exception. Because of that it's not very 
clear what we are doing here.
   
That's why we came up with `ExceptionCatcher`. It does the same logic, but in a lot cleaner way. Take a look at the test:
   
{% highlight java %}
@Test
public void shouldThrowAnExpectedException() {
	// when
	ExpectedException caughtException = ExceptionCatcher.tryToCatch(ExpectedException.class, new ExceptionalOperation() {
		@Override
		public void operate() throws Exception {
			operationThatWillThrowException();
		}
	});
	// then
	assertThat(caughtException).isNotNull();
}
{% endhighlight %}
   
If you are lucky to work with java 8 it goes even better with lambda expression:
   
{% highlight java %}
@Test
public void shouldThrowAnExpectedException() {
	// when
	ExpectedException caughtException = tryToCatch(ExpectedException.class, () -> {
		operationThatWillThrowException();
	});
	// then
	assertThat(caughtException).isNotNull();
}
{% endhighlight %}
   
And better with method reference:
   
{% highlight java %}
@Test
public void shouldThrowAnExpectedException() {
	// when
	ExpectedException caughtException = tryToCatch(ExpectedException.class, this::operationThatWillThrowException);

	// then
	assertThat(caughtException).isNotNull();
}
{% endhighlight %}
   
As you can see we're trying to catch ExceptedException which operationThatWillThrowException() throws and we're verifying that caughtException is not null. 
   
**Simple and clean**.
   
