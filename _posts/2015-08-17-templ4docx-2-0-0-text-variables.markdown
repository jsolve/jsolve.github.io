---
layout: post
title:  "Templ4docx 2.0.0 - Text Variables"
date:   2015-08-17 19:31
categories: java
tags: java templ4docx docx apache-poi
author: Łukasz Stypka
---
The most common situation is when we want to replace simple text variable. Imagine that you have an invitation template and you want to prepare filled invitation with firstname and lastname. So the only thing you need is to find variables in the template and then replace them with the correct values. Suppose that the variables in the template are as follows: ${firstname} and ${lastname}. This pattern of variables is the default one for templ4docx and does not require to define it. However, if the variables in the template have a different form, for example: #{firstname}, you must tell to templ4docx how they look like. In this case you must define the object `VariablePattern` in the following way `new VariablePattern("#{", "}")` and then set it to Docx object:

{% highlight java %}
Docx docx = new Docx("template.docx");
docx.setVariablePattern(new VariablePattern("#{", "}"));
{% endhighlight %}

At this point you are ready to play with template. 

{% highlight java %}
Docx docx = new Docx("template.docx");
docx.setVariablePattern(new VariablePattern("#{", "}"));
    
// preparing variables
Variables variables = new Variables();
variables.addTextVariable(new TextVariable("#{firstname}", "Lukasz"));
variables.addTextVariable(new TextVariable("#{lastname}", "Stypka"));
        
// fill template
docx.fillTemplate(variables);
        
// save filled .docx file
docx.save("lstypka.docx");
{% endhighlight %}

Text variables may be placed anywhere: in a paragraph, table cell, numbered \ bullet list ...
The important thing is that style of text is preserved. So if you want to create, for example bolded lastname, just create bolded variable #{lastname}.