# Power BI - Human Resources Dashboard

[View the dashboard hosted on NovyPro](https://www.novypro.com/project/pimhrdashboard) / [Download the .pbix file here](People%20analytics.pbix)

## Overview

The goal of this project was to showcase my Power BI skills by creating a sample dashboard for a fictional company's Human Resources department. I utilized DAX to display key HR metrics and focused on using the bookmarks and buttons features to enhance user experience.

### Sample Data

This dashboard was created as part of a Data In Motion LLC data visualization challenge, using sample data provided by [Steven Shoemaker's newsletter](https://www.stevenshoemaker.me/datahub). The data was stored in a single table, making data modeling a straightforward process. To accommodate multiple date fields and data visualization requirements, I created several calendar tables.

### Metrics Tracked

The sample data included information on both current and former employees of the fictional company. Demographic information such as age, race, gender, education, and location was included, as well as company-specific information such as salary, hire date, termination date, and job level. I created visualizations that display current employee demographics and provide insight into staff turnover within the organization.

#### Visualizations

To create a dashboard suitable for professional use, I designed a clean and simple layout with a range of visualizations that can easily be incorporated into presentations. To enhance user experience, I utilized bookmarks and buttons, creating a seamless experience for users. The entire report is contained within a single tab.

#### How to Use the Dashboard

To use the dashboard, simply click on the link above to access it on NovyPro. The dashboard contains a range of visualizations that can be interacted with to gain insight into key HR metrics. You can filter data by demographic information to gain more specific insights.

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

![Dashboard model](data%20model.jpg)
