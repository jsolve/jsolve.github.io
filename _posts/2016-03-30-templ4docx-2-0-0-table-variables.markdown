---
layout: post
title:  "Templ4docx 2.0.0 - Table Variables"
date:   2016-03-30 16:26
categories: java
tags: java templ4docx docx apache-poi
author: Łukasz Stypka
---
In this post I would like to spend some time on Table Variables. The TableVariable is perfect solution when you have n-records of the same variable. Lets consider the following case: we have docx document with table which consists of four columns: Name, Age, Image and list of languages. Our goal is fill the table with students' data. For this purpose I've created the following docx template:

![Docx template]({{ site.url }}/assets/2016-03-30/template.png)

Now, I have to write some code responsible for filling the table:

Student class:
{% highlight java %}
class Student {
    private String name;
    private Integer age;
    private String logoPath;
    private List<String> languages;

    public Student(String name, Integer age, String logoPath, List<String> languages) {
        this.name = name;
        this.age = age;
        this.logoPath = logoPath;
        this.languages = languages;
    }

    public String getName() {
        return name;
    }

    public Integer getAge() {
        return age;
    }

    public String getLogoPath() {
        return logoPath;
    }

    public List<String> getLanguages() {
        return languages;
    }
}
{% endhighlight %}

Algorithm method:
{% highlight java %}
 public fillTable() {
    Docx docx = new Docx("E:\\tmp\\tmp.docx");
    Variables var = new Variables();

    TableVariable tableVariable = new TableVariable();

    List<Variable> nameColumnVariables = new ArrayList<Variable>();
    List<Variable> ageColumnVariables = new ArrayList<Variable>();
    List<Variable> logoColumnVariables = new ArrayList<Variable>();
    List<Variable> languagesColumnVariables = new ArrayList<Variable>();

    for(Student student : getStudents()) {
       nameColumnVariables.add(new TextVariable("${name}", student.getName()));
       ageColumnVariables.add(new TextVariable("${age}", student.getAge().toString()));
       logoColumnVariables.add(new ImageVariable("${logo}", student.getLogoPath(), 40, 40));

       List<Variable> languages = new ArrayList<Variable>();
       for(String language : student.getLanguages()) {
           languages.add(new TextVariable("${languages}", language));
       }
       languagesColumnVariables.add(new BulletListVariable("${languages}", languages));
    }

    tableVariable.addVariable(nameColumnVariables);
    tableVariable.addVariable(ageColumnVariables);
    tableVariable.addVariable(logoColumnVariables);
    tableVariable.addVariable(languagesColumnVariables);

    var.addTableVariable(tableVariable);
    docx.fillTemplate(var);
    docx.save("E:\\tmp\\filledTable.docx");
}

    private static List<Student> getStudents() {
        List<Student> students = new ArrayList<Student>();
        students.add(new Student("Lukasz", 28, "E:\\tmp\\smile.gif", Collections.newArrayList("Polish", "English")));
        students.add(new Student("Tomek", 24, "E:\\tmp\\crying.gif", Collections.newArrayList("Polish", "English", "French")));
        return students;
    }

{% endhighlight %}
As you can notice, I've created one table variable consists of four lists of variables. The first one contains two rows with student's name, the second one contains age, third one contains image and the last one list of languages. Of course BulletListVariable can contains both TextVariable and ImageVariable. The completed document is as follows:

![Docx template]({{ site.url }}/assets/2016-03-30/filled.png)