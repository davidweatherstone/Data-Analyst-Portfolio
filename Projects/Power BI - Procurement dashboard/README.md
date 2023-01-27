# Power BI - Procurement dashboard

## Process overview
### Sample data - [Procurement data collated.xlsx](Procurement%20data%20collated.xlsx)
* Created fictitious company names for suppliers using an online generator - [randommer.io](https://randommer.io/random-business-names)
* Created unique vendor ID, department budgets and transactions (contracted and non-contracted).
    * Used RANDNUMBER() function within Excel to create transaction amounts and transaction dates (e.g. RANDNUMBER(DATE(2022,1,1),DATE(2022,12,31)).

### Import and data modeling
* Imported the tables into Power BI Desktop.
* Within Power Query, checked that the data types have imported correctly (date/numerical/text).
* Power BI recognized many of the relationships between the tables.
* Reorganized the model to more easily recognize the relationships.
    * Two fact tables are the transaction tables for Contracted spend and OTV spend (One-time vendor, i.e. non-contracted spend).
    * The remaining tables are all dimension tables.
* Created a Calendar table using the CALENDAR() DAX function and modelled the tables to this calendar.

#### Visualizations - [Procurement dashboard.pbix](Procurement%20dashboard.pbix) / [Procurement_dashboard.pdf](https://drive.google.com/file/d/1rbF_0xmT34H7F5cI4WVjZtjp-Us_iRmF/view?usp=sharing)

The plan was to create two dashboards with this data:
1. An operational view - for a procurement team to monitor monthly spend by category and other metrics relating supplier management.
    * The central features of this dashboard is a **table** showing vendor details and a **bar graph** showing spend by month.
    * **Slicers** allow the procurement team to filter by year, department, line of business.
    * Other metrics surround the dashboard, metrics specific to supplier management that also act as clickable buttons (made possible with **bookmarks**):
        * Live vendor count
        * Awaiting ethical trading statement sign off count
        * Awaiting credit check count
        * Accounts going dormant
2. An executive view -  for the exec team to view showing an overview of spend they own against the budget.
    * Here the focus is on spend against budget, so the main features are:
        *  **Gauge charts** showing spend against budget
        *  A **bar chart** showing spend by month
        *  **Treemaps** showing the share of spend by department.

## Appendix

To analyse the data and gain the insights required to display the visualizations necessary for this report I worked to create **calculated tables**, **calculated columns** and **measures** using DAX queries.

**Calculated table**: Calendar:
```DAX
Calendar =
ADDCOLUMNS (
    CALENDARAUTO(),
    "DateASInteger", FORMAT ([Date], "YYYMMDD"),
    "Year", YEAR ([Date]),
    "Monthnumber", FORMAT ([Date], "MM"),
    "YearMonthNumber", FORMAT ([Date], "YYYY/MM"),
    "YearMonthShort", FORMAT ([Date], "YYYY/mmm"),
    "MonthNameShort", FORMAT ([Date], "mmm"),
    "MonthNameLong", FORMAT ([Date], "mmmm"),
    "DayOfWeekNumber", WEEKDAY([Date]),
    "DayOfWceek", FORMAT ([Date],"dddd"),
    "DayOfWeekShort", FORMAT ([Date], "ddd"),
    "Quarter", "Q" & FORMAT ([Date], "Q"),
    "YearQuarter", FORMAT ([Date], "YYYY") & "/Q" & FORMAT([Date], "Q")
)
```
**Measure**: Creating a live vendor count:
```DAX
Live vendor count =
    CALCULATE (
        COUNTA ( 'Contracted vendor list'[Account status] ),
            'Contracted vendor list'[Account status] = "LIVE"
        )
```

**Measure**: Creating a count of vendors "Awaiting ethical trading statement":
```DAX
Awaiting ethical statement =
    CALCULATE(
        COUNTA ( 'Contracted vendor list'[Ethical trading statement]
        ),
    'Contracted vendor list'[Ethical trading statement] = "N"
    )
```

**Measure**: Creating a count of vendors "Awaiting credit check":
```DAX
Awaiting credit check =
    CALCULATE (
        COUNTA ( 'Contracted vendor list'[Credit score checked?]
        ),
    'Contracted vendor list'[Credit score checked?] = "N"
    )
```

**Measure**: Creating a count of vendors "Going dormant":
```DAX
Going dormant =
CALCULATE (
    COUNTX (
        FILTER (
            SUMMARIZE (
                'Contracted spend',
                'Contracted spend'[Vendor],
                'Contracted vendor list'[Account status],
                "Going dormant", IF (DATEDIFF(MAX('Contracted spend'[Date]), today(), MONTH) > 3, "Y", "N")),
            'Contracted vendor list'[Account status] = "LIVE" && [Going dormant] = "Y"
            ),
    [Going dormant]
    )
)
```

**Calculated table**: Creating the "Going dormant" filter:
```DAX
Going dormant = FILTER (
            SUMMARIZE (
                'Contracted spend',
                'Contracted spend'[Vendor],
                'Contracted vendor list'[Account status],
                "Going dormant", IF (DATEDIFF(MAX('Contracted spend'[Date]), today(), MONTH) > 3, "Y", "N")),
            'Contracted vendor list'[Account status] = "LIVE" )
```

**Calculated column**: Categorizing vendor contract renewal dates
```DAX
Months until renewal =
VAR RenewalMonths =
    ROUND (
        DIVIDE ( DATEDIFF ( TODAY (), 'Contracted vendor list'[Contract Renewal date], DAY ), 30, 0 ),
        1
    )
RETURN
    IF (
        'Contracted vendor list'[Account status] = "DORMANT",
        "",
        IF (
            RenewalMonths < 0,
            "1. Overdue",
            IF (
                RenewalMonths < 3,
                "2. Less than 3 months",
                IF ( RenewalMonths < 6, "3. Between 3 and 6 months", "4. More than 6 months" )
            )
        )
    )
```

**Calculated table**: Showing recently opened vendor accounts (<1 month old):
```DAX
New vendors =
FILTER(
    SUMMARIZE(
        'Contracted vendor list',
        'Contracted vendor list'[Company name],
        'Contracted vendor list'[Contract Start date],
        "New vendor", DATEDIFF('Contracted vendor list'[Contract Start date],TODAY(), MONTH) ),
        [New vendor] = 1 )
```

**Calculated table**: Showing recently closed vendor accounts (<1 month closed):
```DAX
Account closures =
FILTER (
    SUMMARIZE (
        'Contracted vendor list',
        'Contracted vendor list'[Account status],
        'Contracted vendor list'[Company name],
        'Contracted vendor list'[Contract Renewal date],
        "Recently closed", DATEDIFF('Contracted vendor list'[Contract Renewal date], today(), DAY)
    ),
'Contracted vendor list'[Account status] = "DORMANT" && [Recently closed] <= 30 && [Recently closed] >= 0
)
```
