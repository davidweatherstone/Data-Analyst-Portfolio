# SQL data cleaning - Vehicle licensing statistics UK

## Data background

This data is taken from GOV.UK Driving and road transport and is titled as:

* VEH1153: Vehicles registered for the first time by body type and fuel type: Great Britain and United Kingdom (ODS, 3.48 MB)

The table being used from this document which lists quantities of newly registered road using vehicles in the UK broken down by geography, body type, fuel type across month, quarter and year.

My aim is to clean and streamline this data using SQL to allow me use this data in a visualization tool to understand any trends in the registration of road using vehicles in the UK. */

-- Investigate schema

```sql
SELECT column_name, data_type, character_maximum_length
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'newly_registered_vehicles';
```

/* I've had to import every column field as NVARCHAR(50) due to mixed data types displaying in the original file. This will be corrected later */

-- Investigate data

```sql
SELECT
*
FROM newly_registered_vehicles
```

There are a few things that stand out from the data returned:
* The Geography column states the country. The United Kingdom is split up in to their individual nations as well as the United Kingdom and separately Great Britain. I am only interested in the United Kingdom.
* The Date interval column has annual data, quarterly data and monthly data. I am only interested in the monthly data (currently formatted as MMMM-YYYY).
	* I would also like to split out the Date column to show Year, Month_name and Month_number.
* The Units column breaks down the volumes of newly registered vehicles by Units - Thousands and Units - Percentage of total. I am only interested in the Units - Thousands.

Most of these actions can be taken by creating a View but first I will need to replace some string values in a column that I wish to have cast as DECIMAL.*/

-- Amending [low] values to display as 0

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

/* When creating a view I can create columns, cast data types and include only the columns I need. */

--  Creating the view

```sql
CREATE VIEW UK_new_vehicles AS
SELECT
	CAST(Date_note_4 AS VARCHAR(20)) AS Date,
	CAST(SUBSTRING(Date, CHARINDEX(' ', Date) + 1, 4) AS INT) AS Year,
	CAST(SUBSTRING(Date, 1, CHARINDEX(' ', Date) - 1) AS VARCHAR(20)) AS Month_name,
	CAST(MONTH(SUBSTRING(Date, 1, CHARINDEX(' ', Date) - 1) + '1,1') AS INT) AS Month_number,
	CAST(Units AS VARCHAR(20)) AS Units,
	CAST(Body_type AS VARCHAR(50)) AS Body_type,
	CAST(Petrol AS DECIMAL(6,2)) AS Petrol,
	CAST(Diesel AS DECIMAL(6,2)) AS Diesel,
	CAST(Hybrid_electric_petrol AS DECIMAL(6,2)) AS Hybrid_electric_petrol,
	CAST(Hybrid_electric_diesel AS DECIMAL(6,2)) AS Hybrid_electric_diesel,
	CAST(Plug_in_hybrid_electric_petrol AS DECIMAL(6,2)) AS Plug_in_hybrid_electric_petrol,
	CAST(Plug_in_hybrid_electric_diesel AS DECIMAL(6,2)) AS Plug_in_hybrid_electric_diesel,
	CAST(Battery_electric AS DECIMAL(6,2)) AS Battery_electric,
	CAST(Range_extended_electric AS DECIMAL(6,2)) AS Range_extended_electric,
	CAST(Fuel_cell_electric AS DECIMAL(6,2)) AS Fuel_cell_electric,
	CAST(Gas_note_5 AS DECIMAL(6,2)) AS Gas,
	CAST(Other_fuel_types_note_6 AS DECIMAL(6,2)) AS Other_fuel_types,
	CAST(Total AS DECIMAL(6,2)) AS Total,
	CAST(Plug_in_note_7 AS DECIMAL(6,2)) AS Plug_in,
	CAST(Zero_emission_note_8 AS DECIMAL(6,2)) AS Zero_emission
FROM newly_registered_vehicles
WHERE	Geography = 'United Kingdom' AND 
		Date_interval = 'Monthly' AND
		Units = 'Thousands' AND
		Body_type <> 'Total' -- Here I am filtering the table down to only the data required
```

-- Testing that the view displays correctly

```sql
SELECT 
* 
FROM UK_new_vehicles
```

-- Testing to view the data types
```sql
SELECT column_name, data_type, character_maximum_length
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'UK_new_vehicles';
```

### This file is now cleaned for the required purposes

### Example SQL queryShow Car registrations by year, and a comparison

```sql
SELECT
Year,
Body_type,
SUM(Total) AS Total_car_registrations,
SUM(Total) - LAG(SUM(Total), 1) OVER(ORDER BY Year) AS Diff_versus_prior_year
FROM UK_new_vehicles
WHERE	Body_type = 'Cars' AND
		Year <> 2014 AND Year <> 2022
GROUP BY Year, Body_type
```

| Year | Body_type | Total_car_registrations | Diff_versus_prior_year |
|------|-----------|-------------------------|------------------------|
| 2015 | Cars      | 2661.00                 |                        |
| 2016 | Cars      | 2723.80                 | 62.80                  |
| 2017 | Cars      | 2564.30                 | -159.50                |
| 2018 | Cars      | 2394.00                 | -170.30                |
| 2019 | Cars      | 2346.60                 | -47.40                 |
| 2020 | Cars      | 1656.40                 | -690.20                |
| 2021 | Cars      | 1677.30                 | 20.90                  |
