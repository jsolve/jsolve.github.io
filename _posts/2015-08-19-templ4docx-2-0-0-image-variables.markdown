---
layout: post
title:  "Templ4docx 2.0.0 - Image Variables"
date:   2015-08-19 16:45
categories: java
tags: java templ4docx docx apache-poi
author: Łukasz Stypka
---
In the previous post, I've written about simple text variable. Now, I would like to spend some time on Image Variables. In the previous example, we created an invitation. Now I'm going to change a little our example, and we will create a business card. The standard card has information about name, last name and phone number. I would like to add image to my business card as well. So in my business card will be 4 variables: ${firstname}, ${lastname}, ${phone}, ${photo}.
The first three are simple text variables. The last one is variable of image type, so we need to create appropriate ImageVariable object. In my case, I want to insert photo 75px x 75px to business card template:
`new ImageVariable("${photo}", "E:\\photo.jpeg", ImageType. JPEG, 75, 75)`

If you want to insert image from the Internet, you can use `sweetener` (pl.jsolve.sweetener) library:

{% highlight java %}
File logo = Resources.asFile(new URL("https://media.licdn.com/mpr/mpr/shrink_100_100/p/2/000/189/0b4/11ba0d4.jpg" ), File.createTempFile("tmpPhoto", ".tmp" ));
ImageVariable imageVariable = new ImageVariable("${photo}" , logo, ImageType.JPEG, 75, 75);
{% endhighlight %}

The rest of the code is identical to the example of the previous post. 
Below is the full code example:

{% highlight java %}
Docx docx = new Docx("E:\\businessCard.docx" );

Variables var = new Variables();
var. addTextVariable(new TextVariable( "${firstname}", "Lukasz" ));
var.addTextVariable( new TextVariable("${lastname}" , "Stypka" ));
var.addTextVariable( new TextVariable("${phone}" , "123456789" ));

File logo = Resources.asFile(new URL("https://media.licdn.com/mpr/mpr/shrink_100_100/p/2/000/189/0b4/11ba0d4.jpg" ), File.createTempFile("tmpPhoto", ".tmp" ));
ImageVariable imageVariable = new ImageVariable("${photo}" , logo, ImageType.JPEG, 75, 75);
var.addImageVariable(imageVariable);
docx.fillTemplate(var);
docx.save( "E:\\businessCard2.docx");
{% endhighlight %}
