# SQL data cleaning - Vehicle licensing statistics UK

## Data background
This data is taken from GOV.UK Department for Transport and Driver and Vehicle Licensing Agency webpage and it is titled as:

* VEH1153: Vehicles registered for the first time by body type and fuel type: Great Britain and United Kingdom (ODS, 3.48 MB)

The table being used from this document lists quantities of newly registered road using vehicles in the UK broken down by geography (country), body type (vehicle type), fuel type (diesel/petrol/electric/hybrid/gas variants) across month, quarter and year.

My aim is to clean and streamline this data using SQL to allow me to query the data in SQL and visualization tools to gain an understanding of trends relating to the volumes of newly registered road using vehicles over time within the UK.

## Investigate schema
```sql
SELECT column_name, data_type, character_maximum_length
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'newly_registered_vehicles';
```

I imported every column field as NVARCHAR(50) due to mixed data types* displaying in the original file. This will be corrected later.

<sub>* The value "[low]" is appearing in columns relating to the volumes of newly registered vehicles by fuel type. It is explained by Department for Transport and Driver and Vehicle Licensing Agency that this means while the number is low, it is not zero. For the purposes of this exercise I will however round down to zero as the actual number is not available.</sub>

## Investigate data
```sql
SELECT
*
FROM newly_registered_vehicles;
```

There are a few things that stand out from the data returned:
* The Geography column states the country. The United Kingdom is split up in to their individual nations as well as the United Kingdom and separately Great Britain. **I am only interested in the United Kingdom**.
* The Date interval column has annual data, quarterly data and monthly data. **I am only interested in the monthly data** (currently formatted as MMMM-YYYY).
	* I would also like to split out the Date column to show **Year**, **Month_name** and **Month_number**.
* The Units column breaks down the volumes of newly registered vehicles by Units - Thousands and Units - Percentage of total. **I am only interested in the Units - Thousands**.

Filtering to the data I require, along with creating new columns and defining the data types for each column can be done by creating a virtual table using a **CREATE VIEW** statement. However, first I will need to replace string values within columns I wish to define as **DECIMAL**.

## Replacing "[low]" values within numerical columns to display as 0 values
```sql
UPDATE newly_registered_vehicles
SET	Petrol = REPLACE(Petrol, '[low]', 0),
	Diesel = REPLACE(Diesel, '[low]', 0),
	Hybrid_electric_petrol = REPLACE(Hybrid_electric_petrol, '[low]', 0),
	Hybrid_electric_diesel = REPLACE(Hybrid_electric_diesel, '[low]', 0),
	Plug_in_hybrid_electric_petrol = REPLACE(Plug_in_hybrid_electric_petrol, '[low]', 0),
	Plug_in_hybrid_electric_diesel = REPLACE(Plug_in_hybrid_electric_diesel, '[low]', 0),
	Battery_electric = REPLACE(Battery_electric, '[low]', 0),
	Range_extended_electric = REPLACE(Range_extended_electric, '[low]', 0),
	Fuel_cell_electric = REPLACE(Fuel_cell_electric, '[low]', 0),
	Gas = REPLACE(Gas, '[low]', 0),
	Other_fuel_types = REPLACE(Other_fuel_types, '[low]', 0),
	Total = REPLACE(Total, '[low]', 0),
	Plug_in = REPLACE(Plug_in, '[low]', 0),
	Zero_emission = REPLACE(Zero_emission, '[low]', 0);
```

## Creating the view
```sql
CREATE VIEW UK_new_vehicles AS
SELECT
	CAST(Date_note_4 AS VARCHAR(20)) AS Date, -- casting data to an appropriate data type and changing the column name
	CAST(SUBSTRING(Date, CHARINDEX(' ', Date) + 1, 4) AS INT) AS Year, -- new column
	CAST(SUBSTRING(Date, 1, CHARINDEX(' ', Date) - 1) AS VARCHAR(20)) AS Month_name, -- new column
	CAST(MONTH(SUBSTRING(Date, 1, CHARINDEX(' ', Date) - 1) + '1,1') AS INT) AS Month_number, -- new column
	CAST(Units AS VARCHAR(20)) AS Units,
	CAST(Body_type AS VARCHAR(50)) AS Body_type,
	CAST(Petrol AS DECIMAL(6,1)) AS Petrol,
	CAST(Diesel AS DECIMAL(6,1)) AS Diesel,
	CAST(Hybrid_electric_petrol AS DECIMAL(6,1)) AS Hybrid_electric_petrol,
	CAST(Hybrid_electric_diesel AS DECIMAL(6,1)) AS Hybrid_electric_diesel,
	CAST(Plug_in_hybrid_electric_petrol AS DECIMAL(6,1)) AS Plug_in_hybrid_electric_petrol,
	CAST(Plug_in_hybrid_electric_diesel AS DECIMAL(6,1)) AS Plug_in_hybrid_electric_diesel,
	CAST(Battery_electric AS DECIMAL(6,1)) AS Battery_electric,
	CAST(Range_extended_electric AS DECIMAL(6,1)) AS Range_extended_electric,
	CAST(Fuel_cell_electric AS DECIMAL(6,1)) AS Fuel_cell_electric,
	CAST(Gas_note_5 AS DECIMAL(6,1)) AS Gas,
	CAST(Other_fuel_types_note_6 AS DECIMAL(6,1)) AS Other_fuel_types,
	CAST(Total AS DECIMAL(6,1)) AS Total,
	CAST(Plug_in_note_7 AS DECIMAL(6,1)) AS Plug_in,
	CAST(Zero_emission_note_8 AS DECIMAL(6,1)) AS Zero_emission
FROM newly_registered_vehicles
WHERE	Geography = 'United Kingdom' AND 
		Date_interval = 'Monthly' AND
		Units = 'Thousands' AND
		Body_type <> 'Total'; -- Using the WHERE clause to filter the data to reduce rows
```

Creating a view for the purporses of this exercise makes sense, taken from [Wikipedia](https://en.wikipedia.org/wiki/View_(SQL)) the following bullet points describe the main advantages of using the CREATE VIEW function:

> * Views can represent a subset of the data contained in a table. Consequently, a view can limit the degree of exposure of the underlying tables to the outer world: a given user may have permission to query the view, while denied access to the rest of the base table.
> * Views can join and simplify multiple tables into a single virtual table.
> * Views can act as aggregated tables, where the database engine aggregates data (sum, average, etc.) and presents the calculated results as part of the data.
> * Views can hide the complexity of data. For example, a view could appear as Sales2000 or Sales2001, transparently partitioning the actual underlying table.
> * Views take very little space to store; the database contains only the definition of a view, not a copy of all the data that it presents.
> * Depending on the SQL engine used, views can provide extra security.

## Testing that the view displays correctly
```sql
SELECT 
* 
FROM UK_new_vehicles;
```

## Testing to view the data types
```sql
SELECT column_name, data_type, character_maximum_length
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'UK_new_vehicles';
```

This file is now cleaned for the purpose of data exploration.

## Example SQL query - Show Car registrations by year, comparing the difference year on year
```sql
SELECT
Year,
Body_type,
SUM(Total) AS Total_car_registrations,
SUM(Total) - LAG(SUM(Total), 1) OVER(ORDER BY Year) AS Diff_versus_prior_year
FROM UK_new_vehicles
WHERE	Body_type = 'Cars' AND
		Year <> 2014 AND Year <> 2022
GROUP BY Year, Body_type;
```

| Year | Body_type | Total_car_registrations | Diff_versus_prior_year |
|------|-----------|-------------------------|------------------------|
| 2015 | Cars      | 2661.0                 |                        |
| 2016 | Cars      | 2723.8                 | 62.8                  |
| 2017 | Cars      | 2564.3                 | -159.5                |
| 2018 | Cars      | 2394.0                 | -170.3                |
| 2019 | Cars      | 2346.6                 | -47.4                 |
| 2020 | Cars      | 1656.4                 | -690.2                |
| 2021 | Cars      | 1677.3                 | 20.9                  |
