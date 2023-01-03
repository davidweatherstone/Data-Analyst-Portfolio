# SQL data exploration - Weatherline
Weatherline Lake District is an organization run by the Lake District National Park Authority which employs Fell top assessors to record the weather conditions each day throughout the winter season. The fell top assessors climb Helvellyn in the centre of the Lake District and take weather readings, photographs and record the ground conditions to offer advice to visitors to the Lake District national park. Helvellyn is the third largest mountain in England at 950m and is a popular mountain for walkers throughout the year. For archival purposes the data that the Weatherline Fell top assessors record is hosted on the Weatherline Lake District website and this has allowed me to explore the data in detail as shown below.

Credit for this data goes to the Lake District National Park Authority.

https://www.lakedistrict.gov.uk/

https://www.lakedistrictweatherline.co.uk/about/readings


## Data collection

The data provided is hosted either in .xls format or within tables hosted on the web page. There are 18 seperate spreadsheets and 10 separate web pages. These provide data from Season 1997-1998 through to 2021-2022 (23 seasons) with overlapping data from Season 2012-2013 through to 2015-2016 (4 seasons) and one missing season (2004 - 2005).

Througout the years, the amount of weather data types published for each day has varied, with for example, snow levels and cloud levels being collected in only certain years. Since Season 2012-2013 there has been a move towards text based reports of the weather and conditions reporting the specifics of routes, ground conditions and equipment required for tackling the ascent of Helvellyn.

Consistent data points published for all seasons are below, and these will form the basis of my exploratory analysis.

* Date
* Location of readings
* Temperature (C)
* Wind chill (C)
* Max wind speed (MPH)
* Average wind speed (MPH)
* Wind direction

## Queries
Using SQL I am hoping to find the answers to the following questions:
* When does a typical season start and end?
* What is the average summit temperature in each month?
    * How does the average temperature compare to the wind chill temperature?
	* How does the average temperature at the summit compare to the temperature in town?
* What is the average wind speed in each month?
    * How does the average speed compare to the max speed?
	* Categorizing of average wind speeds based on the Beaufort scale*
* What was the lowest temperature recorded?
* What was the highest wind speed recorded?
* What direction does the wind generally travel?

*The Beaufort Scale is an empirical measure that relates wind speed to observed conditions at sea or on land. 

https://www.rmets.org/metmatters/beaufort-wind-scale

## Methods
1. Collect the data by downloading it from the Lake District Weatherline website
2. Use Excel to standardize the tables by renaming and rearranging the columns
3. Use Power Query to append the tables together
4. Use Excel to clean the data
    * Renaming locations to standard names
    * Correcting the date format for each year
    * Standardizing readings, e.g. removing text from number fields
5. Import the .CSV flat file in to MS SQL Server to query the data

## Season length
According to the met office, the metreoroligical definition of winter starts on 1 December each year and ends on 28 (or 29 during a Leap Year) February. While astronomical winter starts on or around 21 December and ends on 20 March. 

https://www.metoffice.gov.uk/weather/learn-about/weather/seasons/winter/when-does-winter-start

The purpose of the Weatherline Fell top assessors is to check conditions, take photos and supply a report. The start and end of their work varies each year according to the conditions.

### Season length
```sql
SELECT
	season,
	MIN(date) AS earliest_date,
	MAX(date) AS latest_date,
	DATEDIFF(DAY, MIN(date), MAX(date)) AS season_length
FROM weatherline
GROUP BY season
ORDER BY 1;
```

### Count of weather readings taken across the seasons on each day
```sql
SELECT
	FORMAT(date, 'dd-MM') AS date,
	MONTH(DATEADD(m, 2, date)) AS season_month,
	FORMAT(date, 'dd') AS day_of_month,
	COUNT(FORMAT(date, 'dd-MM')) AS records
FROM weatherline
GROUP BY FORMAT(date, 'dd-MM'), MONTH(DATEADD(m, 2, date)), FORMAT(date, 'dd')
ORDER BY 2,3;
```

## Location queries
While the Weatherline team aim to summit Helvellyn each day during the winter season due to weather, ground conditions, rescue operations and team availability they will sometimes summit other fells in the Lake District, make it partially up Helvellyn or be unavailable on any single day.

### A list of locations where measurements were taken
```sql
SELECT
	COUNT(DISTINCT location) AS measurement_locations
FROM weatherline;
```

### A list of locations with a count of measurements
```sql
SELECT
	location,
	COUNT(date) AS count
FROM weatherline
GROUP BY location 
ORDER BY 2 DESC;
```

## Wind speeds

### The difference between average wind speeds and max wind speeds by month (in mph)
```sql
SELECT 
	DATENAME(MONTH, DATEADD(MONTH, 0, date)) AS 'month_name',
	MONTH(DATEADD(m, 2, date)) AS season_month,
	ROUND(AVG(avg_wind_mph),2) AS avg_wind_mph,
	ROUND(AVG(max_wind_mph),2) AS max_wind_mph,
	ROUND(AVG(max_wind_mph) - AVG(avg_wind_mph),2) AS avg_max_wind_diff
FROM weatherline
WHERE	avg_wind_mph IS NOT NULL AND
		max_wind_mph IS NOT NULL AND
		location = 'Helvellyn summit'
GROUP BY DATENAME(MONTH, DATEADD(MONTH, 0, date)), MONTH(DATEADD(m, 2, DATE))
ORDER BY 2;
```

### The average wind speeds (mph) for each month throughout the seasons
```sql
WITH cte AS(
	SELECT
		season,
		date,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'November' 
			THEN avg_wind_mph END AS november_wind,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'December' 
			THEN avg_wind_mph END AS december_wind,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'January' 
			THEN avg_wind_mph END AS january_wind,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'February' 
			THEN avg_wind_mph END AS february_wind,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'March' 
			THEN avg_wind_mph END AS march_wind,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'April' 
			THEN avg_wind_mph END AS april_wind
	FROM weatherline
	WHERE	avg_wind_mph IS NOT NULL AND
			location = 'Helvellyn summit'
)

SELECT
	season,
	ROUND(AVG(november_wind),2) AS avg_november_wind,
	ROUND(AVG(december_wind),2) AS avg_december_wind,
	ROUND(AVG(january_wind),2) AS avg_january_wind,
	ROUND(AVG(february_wind),2) AS avg_february_wind,
	ROUND(AVG(march_wind),2) AS avg_march_wind,
	ROUND(AVG(april_wind),2) AS avg_april_wind
FROM cte
GROUP BY season
ORDER BY season;
```
### The highest wind speeds each season
```sql
SELECT
	season,
	MAX(avg_wind_mph) AS highest_avg_wind_mph,
	MAX(max_wind_mph) AS highest_max_wind_mph
FROM weatherline
WHERE location = 'Helvellyn summit'
GROUP BY season
ORDER BY season;
```

### The occurances of wind speeds experienced, matched against the Beaufort Scale - total
```sql
SELECT
	bs.wind_force,
	bs.wind_speed,
	bs.description,
	COUNT(wl.avg_wind_mph) AS count,
	COUNT(wl.avg_wind_mph) * 100 / SUM(COUNT(wl.avg_wind_mph)) over() AS percentage
FROM weatherline AS wl
LEFT JOIN beaufort_scale AS bs
	ON wl.avg_wind_mph BETWEEN bs.low_end_speed AND bs.high_end_speed
WHERE	wl.avg_wind_mph IS NOT NULL AND
		wl.location = 'Helvellyn summit'
GROUP BY bs.wind_force, bs.wind_speed, bs.description
ORDER BY bs.wind_force ASC;
```

### The occurances of wind speeds experienced, matched against the Beaufort Scale - totals by month
```sql
WITH cte AS(
SELECT
	bs.wind_force,
	bs.wind_speed,
	bs.description,
	CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'November' 
		THEN wl.avg_wind_mph END AS november_wind,
	CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'December' 
		THEN wl.avg_wind_mph END AS december_wind,
	CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'January' 
		THEN wl.avg_wind_mph END AS january_wind,
	CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'February' 
		THEN wl.avg_wind_mph END AS february_wind,
	CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'March' 
		THEN wl.avg_wind_mph END AS march_wind,
	CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'April' 
		THEN wl.avg_wind_mph END AS april_wind
FROM weatherline AS wl
LEFT JOIN beaufort_scale AS bs
	ON wl.avg_wind_mph BETWEEN bs.low_end_speed AND bs.high_end_speed
WHERE	wl.avg_wind_mph IS NOT NULL AND
		wl.location = 'Helvellyn summit'
)

SELECT
wind_force,
wind_speed,
description,
ROUND(COUNT(november_wind),2) AS Nov_count,
ROUND(COUNT(december_wind),2) AS Dec_count,
ROUND(COUNT(january_wind),2) AS Jan_count,
ROUND(COUNT(february_wind),2) AS Feb_count,
ROUND(COUNT(march_wind),2) AS Mar_count,
ROUND(COUNT(april_wind),2) AS Apr_count
FROM cte
GROUP BY wind_force, wind_speed, description
ORDER BY wind_force ASC;
```

## Temperatures
### The difference between average air temperature and average wind chill temperature by month (in celcius)
```sql
SELECT 
	DATENAME(MONTH, DATEADD(MONTH, 0, date)) AS 'month_name',
	MONTH(DATEADD(m, 2, DATE)) AS season_month,
	ROUND(AVG(air_temp_c),2) AS avg_air_temp_c,
	ROUND(AVG(wind_chill_temp_c),2) AS avg_wind_chill_temp_c,
	ROUND(AVG(air_temp_c) - AVG(wind_chill_temp_c),2) AS avg_vs_wind_chill_diff
FROM weatherline
WHERE	air_temp_c IS NOT NULL AND
		wind_chill_temp_c IS NOT NULL AND
		location = 'Helvellyn summit'
GROUP BY DATENAME(MONTH, DATEADD(MONTH, 0, date)), MONTH(DATEADD(m, 2, DATE))
ORDER BY 2;
```

### The average temperatures (c) for each month throughout the seasons
```sql
WITH cte AS(
	SELECT
		season,
		date,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'November' 
			THEN air_temp_c END AS november_air_temp,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'December' 
			THEN air_temp_c END AS december_air_temp,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'January' 
			THEN air_temp_c END AS january_air_temp,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'February' 
			THEN air_temp_c END AS february_air_temp,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'March' 
			THEN air_temp_c END AS march_air_temp,
		CASE WHEN DATENAME(MONTH, DATEADD(MONTH, 0, date)) = 'April' 
			THEN air_temp_c END AS april_air_temp
	FROM weatherline
	WHERE	air_temp_c IS NOT NULL AND
			location = 'Helvellyn summit'
)

SELECT
	season,
	ROUND(AVG(november_air_temp),2) AS avg_november_air_temp,
	ROUND(AVG(december_air_temp),2) AS avg_december_air_temp,
	ROUND(AVG(january_air_temp),2) AS avg_january_air_temp,
	ROUND(AVG(february_air_temp),2) AS avg_february_air_temp,
	ROUND(AVG(march_air_temp),2) AS avg_march_air_temp,
	ROUND(AVG(april_air_temp),2) AS avg_april_air_temp
FROM cte
GROUP BY season
ORDER BY season;
```

### The lowest temperatures (c) each season
```sql
SELECT
	season,
	MIN(air_temp_c) AS lowest_temperature_c,
	MIN(wind_chill_temp_c) AS lowest_wind_chill_temperature_c
FROM weatherline
WHERE location = 'Helvellyn summit'
GROUP BY season
ORDER BY season;
```

### The summit temperature difference versus town (Glenridding) temperature (in c)

```sql
SELECT 
	DATENAME(MONTH, DATEADD(MONTH, 0, date)) AS 'month_name',
	MONTH(DATEADD(m, 2, DATE)) AS season_month,
	ROUND(AVG(air_temp_c),2) AS avg_air_temp_c,
	ROUND(AVG(air_temp_c_town),2) AS avg_temp_c_town,
	ROUND(AVG(air_temp_c_town) - AVG(air_temp_c),2) AS difference
FROM weatherline
WHERE	location = 'Helvellyn summit' AND 
		town = 'Glenridding' AND
		air_temp_c_town IS NOT NULL AND
		air_temp_c IS NOT NULL
GROUP BY DATENAME(MONTH, DATEADD(MONTH, 0, date)), MONTH(DATEADD(m, 2, DATE))
ORDER BY 2;
```

### The largest swings in temperature (c) from one day to the next

```sql
WITH cte AS(
SELECT
date,
air_temp_c,
LAG(air_temp_c, 1) over(ORDER BY date) AS air_temp_lag,
LAG(air_temp_c, 1) over(ORDER BY date) - air_temp_c AS diff_to_prev_day
FROM weatherline
)

SELECT
date,
diff_to_prev_day
FROM cte
WHERE	diff_to_prev_day IS NOT NULL AND
		diff_to_prev_day = (SELECT MAX(diff_to_prev_day) FROM cte) OR 
		diff_to_prev_day = (SELECT MIN(diff_to_prev_day) FROM cte)
GROUP BY date, diff_to_prev_day
```

## Wind direction
```sql
SELECT
	wind_direction,
	COUNT(wind_direction) AS count,
	COUNT(wind_direction) * 100 / SUM(COUNT(wind_direction)) over() AS percentage
FROM weatherline
WHERE location = 'Helvellyn summit'
GROUP BY wind_direction
ORDER BY 2 DESC;
```
