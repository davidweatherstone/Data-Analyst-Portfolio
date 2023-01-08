# Power Bi - Procurement dashboard

## Sample data - [Spend data.xlsx](Spend%20data.xlsx)
* Created fictitious company names using an online generator
* Created unique vendors, employees, department budgets, transactions (contracted and non-contracted).
* Used RANDNUMBER() function within Excel to create transaction amounts and transaction dates (e.g. RANDNUMBER(DATE(2022,1,1),DATE(2022,12,31))

## Import and data modeling
* Imported the spreadsheet into Power BI
* Within Power Query, check that the data types have imported correctly (date/numerical/text)
* Power BI recognized most of the relationships (primary keys to foreign)
* Reorganized the model to more easily recognize the relationships.
    * Two fact tables are the transaction tables for Contracted spend and OTV spend (One-time vendor, i.e. non-contracted spend).
    * The remaining tables are all dimension tables

## Visualizations - [Procurement dashboard.pbix](Procurement%20dashboard.pbix) / [Procurement_dashboard.pdf](https://drive.google.com/file/d/1wqWB2MlV0036dCzYLsSd91TxyCoXMSWj/view?usp=sharing)
* Visualize spend against budget using **gauge charts**
* Visualize spend per month using a **bar chart**
* Display vendor names along with their spend, contracted and non-contracted (maverick spend) in a **table**
* Visualize proportional spend by department using **treemaps**
* Allow filtering against department with the placement of a **slicer** 
