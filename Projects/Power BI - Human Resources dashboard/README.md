# Power BI - Human Resources dashboard

[Dashoard link hosted on NovyPro](https://www.novypro.com/project/pimhrdashboard)

## Overview
The aim of this porject was to create a sample dashboard for ficitious company's Human Resources department while displaying my knowledge of Power BI. I wanted to use DAX where necessary to display the HR metrics I had in mind and then focus extensively on using the bookmarks and buttons features within Power BI.

### Sample data
This dashboard was created as part of a Data In Motion LLC data viz challenge and the sample data was taken from [Steven Shoemaker's newsletter](https://www.stevenshoemaker.me/datahub).

The sample data was all within a single table, therefore data modelling was simple. I created multiple calendar tables as required due to multiple date fields within the data (hire date and termination date) and requirements within the data visualizations.

#### Visualizations - [People_analytics.pbix](People%20analytics.pbix) / [Dashboard link hosted on NovyPro](https://www.novypro.com/project/pimhrdashboard)

Visually I wanted to use quite a simple layout with a clean group of visualizations for using within a professional environment and so that visualizations can be snipped for use within a slide deck. Given that I was also working to display and practice my use of bookmarks and buttons, I also made the entire report within a single tab. 

### Sample of DAX used

Age group calculated column:
```DAX
Age group = 
    SWITCH(true(),
        people[Age] < 25, "<25",
        people[Age] < 35, "25-34",
        people[Age] < 45, "35-44",
        people[Age] < 55, "45-54",
        "55+"
        )
```

Tenure group for terminated staff calculcated column:
```DAX
Tenure group for term = 
    IF(people[Active status] = 0, 
        SWITCH(TRUE(),
        people[Tenure] < 12, "Less than 1 year",
        people[Tenure] < 24, "Less than 2 years",
        "Over 2 years"), "")
```

Average tenure measure:
```DAX
Avg tenure = 
CONCATENATE (
    ROUND (
        DIVIDE ( DIVIDE ( SUM ( people[Tenure] ), COUNTROWS ( people ) ), 12 ),
        1
    ),
    " yrs"
)
```

Current staff measure:
```DAX
Current Staff = 
    CALCULATE ( COUNTROWS ( people ),
        FILTER ( VALUES ( people[Hire date] ), people[Hire date] <= MAX ( 'calendar'[Date] ) ),
        FILTER ( VALUES ( people[Termination date] ), OR ( people[Termination date] >= MAX ( 'calendar'[Date] ), ISBLANK ( people[Termination date] ) ) ) )
```

Staff turnover measure:
```
Staff Turnover = 
    CALCULATE ( COUNTROWS ( people ), 
        FILTER ( VALUES ( people[Termination date] ), people[Termination date] <= MIN ( 'calendar'[Date] ) ),
        people[Termination date] <> BLANK () )
```

Leavers measure to allow for a turnover calculation:
```DAX
Leavers = 

VAR MaxDate = Max ( termcalendar[Date] )
VAR MinDate = Min ( termcalendar[Date] )

RETURN
0 +
CALCULATE (
COUNTROWS(people),
people[Termination date] <= MaxDate,
people[Termination date] >= MinDate,
All(termcalendar)
)
```

### Appendix

![Dashboard preview](People%20analytics.gif)

![Dashboard model](data%20model.png)
