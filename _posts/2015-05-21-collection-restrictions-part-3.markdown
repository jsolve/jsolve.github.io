---
layout: post
title:  "Sweetener - Collection Restrictions - Part III - Custom restrictions"
date:   2015-05-21 19:09:53
categories: java
tags: java, sweetener, restrictions, collections, criteria
author: Łukasz Stypka
---
Sweetener contains many pre-defined restrictions, but we cannot predict all use-cases of our mechanism. For this reason we have prepared `CustomRestriction`. If none of the restrictions prepared by us is what you are looking for, you can create your own restriction. Preparing `CustomRestriction` is simple and intuitive. To create your own `Restriction` you need to create new class which extends `CustomRestriction` class. 
Let's assume that we want to create restriction which checks whether string starts with some substring. The example restriction might look as follows:

{% highlight java %}
public class StartsWithRestriction extends CustomRestriction {

    private String prefix;

    public StartsWithRestriction(String fieldName, String prefix) {
        super(fieldName);
        this.prefix = prefix;
    }

    @Override
    public boolean satisfies(Object fieldValue) {

        if (!(fieldValue instanceof String)) {
            throw new AccessToFieldException("Type mismatch. Expected String but was "
                    + fieldValue.getClass().getCanonicalName());
        }

        return ((String) fieldValue).startsWith(prefix);
    }

}
{% endhighlight %}
As you can see, `StartsWithRestriction` extends `CustomRestriction`. CustomRestriction expects `fieldName` as a constructor parameter. As other constructor parameters you can pass values that will be necessary in your restrictions. In our example, this is the prefix. CustomRestriction requires implementation of one method: `satisfies(Object fieldValue)`. As the parameter of this method you can expect fieldValue which is indicate by first parameter in the constructor (String fieldName). In body of `public boolean satisfies(Object fieldValue)` method you can check whether value has correct format, correct type. As result of this method you should return one simple boolean information: whether the restriction is satisfied. In our example we check whether fieldValue starts with prefix.

To use such restriction just invoke `add` method on `Criteria` object. 

{% highlight java %}
Collection<Person> filteredList = Collections.filter(people,
                Criteria.newCriteria().add(new StartsWithRestriction("name", "J")));
{% endhighlight %}

Thanks to this mechanism, you can easily extend the functionality of criteria / restrictions.  
**Simple, fast and extensible mechanism**