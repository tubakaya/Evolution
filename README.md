# Series 1- Design (functional / technical)
*Software Evolution Series 1 Assignment*

**Authors:** Sander Leer (Sander.Leer@gmail.com), Tuba Kaya Chomette (admin@tubakaya.com)

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

## Results
When running the program on the `SmallSql` Java project, these are the findings:

- Duplication ranking: *this is ranking is not calculated due to performance issues*
- Complexity ranking: Very Low *(ranking: low = 62%, moderate = 7%, high = 10%, very high = 21%)*
- Unit size ranking: Very Low *(ranking: low = 31%, moderate = 45%, high = 5%, very high = 19%)*
- Volume ranking: Very High *(24 KLOC)*
- Assertion ranking: Very Low *(ranking: low = 83%, moderate = 0%, high = 0%, very high = 17%)*

**Program output**

    == AnalyzeComplexity: risks = riskLevels(riskLevel(15021,62),riskLevel(1579,7),riskLevel(2420,10),riskLevel(1255,21))
    == AnalyzeUnitSize: risks = riskLevels(riskLevel(7497,31),riskLevel(10788,45),riskLevel(1122,5),riskLevel(868,19))
    == AnalyzeAssertion: risks = riskLevels(riskLevel(20169,83),riskLevel(84,0),riskLevel(22,0),riskLevel(0,17))
    == total time: 58.286 seconds
    
    map[str, Rank]: (
      "Duplication":Low(0),
      "Complexity":VeryLow(0),
      "Unit size":VeryLow(0),
      "Volume":VeryHigh(24),
      "Assertion":VeryLow(0)
    )

----------

When running the program on the `hsqldb-2.3.1` project, these are the findings:

- Duplication ranking: *this is ranking is not calculated due to performance issues*
- Complexity ranking: Very Low *(ranking: low = 53%, moderate = 12%, high = 9%, very high = 26%)*
- Unit size ranking: Very Low *(ranking: low = 19%, moderate = 48%, high = 8%, very high = 25%)*
- Volume ranking: High *(142 KLOC)*
- Assertion ranking: Very Low *(ranking: low = 80%, moderate = 1%, high = 1%, very high = 18%)*

**Program output**

    == AnalyzeComplexity: risks = riskLevels(riskLevel(75485,53),riskLevel(17167,12),riskLevel(13362,9),riskLevel(10796,26))
    == AnalyzeUnitSize: risks = riskLevels(riskLevel(27216,19),riskLevel(67957,48),riskLevel(10960,8),riskLevel(10677,25))
    == AnalyzeAssertion: risks = riskLevels(riskLevel(114602,80),riskLevel(1149,1),riskLevel(1059,1),riskLevel(0,18))
    == total time: 451.009 seconds
    
    map[str, Rank]: (
      "Duplication":VeryHigh(0),
      "Complexity":VeryLow(0),
      "Unit size":VeryLow(0),
      "Volume":High(142),
      "Assertion":VeryLow(0)
    )

