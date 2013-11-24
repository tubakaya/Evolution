# Series 1- Design (functional / technical)
*Software Evolution Series 1 Assignment*


## Goals
Some relevant questions are:

- Which metrics are used?
- How are these metrics computed?
- How well do these metrics indicate what we really want to know about these systems and how can we judge that?
- How can we improve any of the above?

In other words, you have to worry about *motivation* and *interpretation* of metrics, as well as correct *implementation*.

The second question above (“How are these metrics computed?”) is your assignment for series 1. The third and fourth questions are proper topics to talk about in your essay project.

## Assignment

- Build a Rascal program to design and implement a tool that implements the SIG maintainability model for Java.
- Unit test coverage is an optional bonus.

## Design

### Which metrics to implement?
In Java we consider a unit to be a (class) method.

### Volume
Calculate (K)LOC, optionally corrected using man-years

### Complexity per unit
Calculate Cyclomatic complexity per unit

### Duplication
Calculate the percentage of all code that occurs more than once in equal code blocks of at least 6 lines.

### Unit size
Calculate LOC for each unit.

### Unit testing
> Is this the bonus of series 1?
Calculate number of assert statements

## Program structure

1. Read the Java project using `myModel = createM3FromEclipseProject(…)`
-  Call
  `extractVolume(…)`
  `extractComplexity(…)`
  `extractDuplication(…)` 
  `extractUnitSize(…)`
  `extractUnitTesting(…)`
- Calculate ranking per metric
- Display the metrics

## Questions
1. Why is using `import lang::java::\syntax::Java15;` making Rascal go NUTS (performance wise)!! Because it is generating a parser every time this import unit is used?
-  Is passing large amounts of data in and out a function a runtime performance bottleneck? Eg. `DataType func(DataType myData) {...}`. Is it passed by value and copied?


