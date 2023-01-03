# SQL data exploration - Weatherline
Weatherline Lake District is an organization run by the Lake District National Park Authority which employs Fell top assessors to record the weather conditions each day throughout the winter season. The fell top assessors climb Helvellyn in the centre of the Lake District and take weather readings, photographs and record the ground conditions to offer advice to visitors to the Lake District national park. Helvellyn is the third largest mountain in England at 950m and is a popular mountain for walkers throughout the year. For archival purposes the data that the Weatherline Fell top assessors record is hosted on the Weatherline Lake District website and this has allowed me to explore the data in detail as shown below.

Credit for this data goes to the Lake District National Park Authority.

https://www.lakedistrict.gov.uk/

https://www.lakedistrictweatherline.co.uk/about/readings


## Data collection

The data provided is hosted either in .xls format or within tables hosted on the web page. There are 18 seperate spreadsheets and 10 separate web pages. These provide data from Season 1997-1998 through to 2021-2022 (23 seasons) with overlapping data from Season 2012-2013 through to 2015-2016 (4 seasons) and one missing season (2004 - 2005).

In the data available the amount of data points published varies, with for example, snow levels and cloud levels being reported for only certain years. Since Season 2012-2013 there has been a move towards text based reports of the weather and conditions reporting the specifics of routes, ground conditions and equipment required for tackling the ascent of Helvellyn.

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
* What **locations** are used to take readings?
* What is the average summit **temperature** in each month?
    * How does the average temperature compare to the wind chill temperature?
	* How does the average temperature at the summit compare to the temperature at the base of the mountain?
	* What was the lowest temperature recorded?
    * What were the biggest swings in temperature from one day to the next?
* What is the average **wind speed** in each month?
    * How does the average speed compare to the max speed?
	* Categorizing of average wind speeds based on the Beaufort scale*
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
The Weatherline team aim to summit Helvellyn each day during the winter season, however due to weather, ground conditions, rescue operations and team availability they will sometimes summit other fells in the Lake District, make it partially up Helvellyn or be unavailable. 

### A count of locations where measurements were taken
```sql
SELECT
	COUNT(DISTINCT location) AS measurement_locations
FROM weatherline;
```
|measurement_locations|
|---------------------|
|35                   |

### Top 10 locations by count of measurements
```sql
SELECT TOP 10
	location,
	COUNT(date) AS count
FROM weatherline
WHERE location IS NOT NULL
GROUP BY location 
ORDER BY COUNT(date) DESC;
```
|location|count|
|--------|-----|
|Helvellyn summit|2499 |
|Swirral Edge|28   |
|Catstycam summit|20   |
|Blencathra summit|15   |
|Scafell Pike summit|11   |
|Helvellyn Lower Man summit|10   |
|Brown Cove Crags summit|10   |
|Red Tarn|8    |
|Nethermost Pike summit|7    |
|Birkhouse Moor summit|7    |

## Temperature queries
### The average temperatures (Celcius) for each month throughout the seasons
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
|season|avg_november_air_temp|avg_december_air_temp|avg_january_air_temp|avg_february_air_temp|avg_march_air_temp|avg_april_air_temp|
|------|---------------------|---------------------|--------------------|---------------------|------------------|------------------|
|1997 - 1998|2.740000             |1.060000             |-.030000            |2.280000             |2.410000          |1.250000          |
|1998 - 1999|1.740000             |.560000              |.310000             |-.010000             |2.810000          |5.820000          |
|1999 - 2000|                     |-.190000             |1.430000            |.700000              |2.850000          |2.670000          |
|2000 - 2001|2.140000             |.550000              |-1.010000           |.490000              |                  |                  |
|2001 - 2002|                     |.200000              |1.280000            |-.270000             |2.450000          |4.460000          |
|2002 - 2003|                     |.620000              |.220000             |.580000              |5.220000          |8.810000          |
|2003 - 2004|                     |.870000              |.100000             |.020000              |.420000           |                  |
|2005 - 2006|                     |.310000              |.050000             |.150000              |-1.070000         |                  |
|2006 - 2007|                     |2.440000             |1.400000            |1.620000             |1.850000          |6.260000          |
|2007 - 2008|                     |1.210000             |.740000             |2.860000             |-.690000          |-1.360000         |
|2008 - 2009|-1.650000            |-.010000             |-.880000            |                     |-1.600000         |                  |
|2009 - 2010|-2.100000            |-1.140000            |-3.330000           |-2.640000            |.730000           |.600000           |
|2010 - 2011|                     |-3.940000            |-1.110000           |.110000              |1.720000          |5.300000          |
|2011 - 2012|                     |-.300000             |-.540000            |-.120000             |3.960000          |2.040000          |
|2012 - 2013|                     |-.790000             |-1.990000           |-2.050000            |-3.060000         |-3.270000         |
|2013 - 2014|                     |.750000              |-.180000            |-.250000             |2.390000          |5.000000          |
|2014 - 2015|                     |-.010000             |-2.170000           |-1.030000            |-.530000          |3.840000          |
|2015 - 2016|                     |2.980000             |.000000             |-1.920000            |.730000           |1.600000          |
|2016 - 2017|                     |2.050000             |-.060000            |.080000              |1.720000          |1.200000          |
|2017 - 2018|                     |-.320000             |-1.160000           |-2.670000            |-.970000          |.320000           |
|2018 - 2019|-3.300000            |.650000              |.640000             |-.910000             |-.900000          |                  |
|2019 - 2020|                     |.540000              |.600000             |-.910000             |-.900000          |                  |
|2020 - 2021|                     |-.310000             |-2.080000           |-.650000             |2.020000          |.040000           |

### The difference between average air temperature and average wind chill temperature by month (in Celcius)
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
ORDER BY MONTH(DATEADD(m, 2, DATE));
```
|month_name|season_month|avg_air_temp_c|avg_wind_chill_temp_c|avg_vs_wind_chill_diff|
|----------|------------|--------------|---------------------|----------------------|
|November  |1           |-2.150000     |-8.080000            |5.930000              |
|December  |2           |.310000       |-8.230000            |8.540000              |
|January   |3           |-.530000      |-9.890000            |9.350000              |
|February  |4           |-.420000      |-9.190000            |8.760000              |
|March     |5           |1.000000      |-6.990000            |7.990000              |
|April     |6           |3.280000      |-4.490000            |7.770000              |

### The difference in temperature between the summit of Helvellyn and the base (Glenridding) temperature (in Celcius)
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
ORDER BY MONTH(DATEADD(m, 2, DATE));
```
|month_name|season_month|avg_air_temp_c|avg_temp_c_town|difference|
|----------|------------|--------------|---------------|----------|
|November  |1           |2.140000      |7.600000       |5.460000  |
|December  |2           |.590000       |6.190000       |5.600000  |
|January   |3           |.320000       |6.130000       |5.800000  |
|February  |4           |.600000       |7.180000       |6.580000  |
|March     |5           |2.890000      |9.550000       |6.660000  |
|April     |6           |4.860000      |11.790000      |6.930000  |

### The lowest temperatures (Celcius) each season
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
|season|lowest_temperature_c|lowest_wind_chill_temperature_c|
|------|--------------------|-------------------------------|
|1997 - 1998|-5.60               |                               |
|1998 - 1999|-6.10               |                               |
|1999 - 2000|-6.00               |                               |
|2000 - 2001|-5.70               |                               |
|2001 - 2002|-6.00               |                               |
|2002 - 2003|-11.50              |-31.80                         |
|2003 - 2004|-9.10               |-33.40                         |
|2005 - 2006|-6.80               |-17.50                         |
|2006 - 2007|-6.00               |-25.00                         |
|2007 - 2008|-6.40               |-19.00                         |
|2008 - 2009|-5.60               |-17.40                         |
|2009 - 2010|-8.40               |-21.20                         |
|2010 - 2011|-8.50               |-20.20                         |
|2011 - 2012|-6.60               |-16.90                         |
|2012 - 2013|-8.70               |-23.20                         |
|2013 - 2014|-4.70               |-14.00                         |
|2014 - 2015|-6.30               |-18.70                         |
|2015 - 2016|-5.50               |-17.30                         |
|2016 - 2017|-5.90               |-19.10                         |
|2017 - 2018|-8.40               |-23.50                         |
|2018 - 2019|-4.30               |-18.30                         |
|2019 - 2020|-4.30               |-18.30                         |
|2020 - 2021|-7.40               |-23.00                         |

### The largest single day temperature (Celcius) change
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
GROUP BY date, diff_to_prev_day;
```
|date|diff_to_prev_day|
|----|----------------|
|2003-03-12|13.80           |
|2006-01-30|-11.80          |

## Wind speeds
### The average wind speeds (MPH) for each month throughout the seasons
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
|season|avg_november_wind|avg_december_wind|avg_january_wind|avg_february_wind|avg_march_wind|avg_april_wind|
|------|-----------------|-----------------|----------------|-----------------|--------------|--------------|
|1997 - 1998|17.430000        |21.370000        |22.870000       |28.520000        |20.500000     |18.360000     |
|1998 - 1999|15.860000        |23.100000        |23.830000       |24.330000        |21.520000     |17.060000     |
|1999 - 2000|                 |25.120000        |23.620000       |28.590000        |17.710000     |14.470000     |
|2000 - 2001|33.910000        |20.230000        |18.700000       |18.650000        |              |              |
|2001 - 2002|                 |13.500000        |26.860000       |26.600000        |19.650000     |7.510000      |
|2002 - 2003|                 |10.240000        |20.000000       |13.780000        |15.640000     |9.690000      |
|2003 - 2004|                 |14.740000        |20.130000       |14.230000        |18.760000     |              |
|2005 - 2006|                 |16.620000        |14.680000       |16.620000        |14.020000     |              |
|2006 - 2007|                 |22.620000        |26.850000       |11.520000        |20.970000     |7.040000      |
|2007 - 2008|                 |20.050000        |22.270000       |22.030000        |22.110000     |13.800000     |
|2008 - 2009|5.500000         |16.750000        |19.770000       |                 |20.900000     |              |
|2009 - 2010|23.430000        |17.090000        |16.730000       |10.410000        |15.650000     |15.750000     |
|2010 - 2011|                 |15.300000        |18.560000       |17.740000        |14.470000     |45.000000     |
|2011 - 2012|                 |22.700000        |18.920000       |20.880000        |15.090000     |19.780000     |
|2012 - 2013|                 |17.790000        |19.220000       |17.210000        |18.100000     |19.630000     |
|2013 - 2014|                 |30.220000        |22.780000       |21.390000        |18.070000     |6.000000      |
|2014 - 2015|                 |25.450000        |25.910000       |19.890000        |25.480000     |12.600000     |
|2015 - 2016|                 |28.990000        |20.560000       |19.870000        |15.890000     |13.100000     |
|2016 - 2017|                 |20.510000        |21.050000       |27.370000        |17.510000     |26.700000     |
|2017 - 2018|                 |20.260000        |21.120000       |15.760000        |16.390000     |20.150000     |
|2018 - 2019|11.300000        |22.730000        |26.210000       |29.670000        |14.400000     |              |
|2019 - 2020|                 |22.510000        |25.890000       |29.670000        |14.400000     |              |
|2020 - 2021|                 |19.580000        |20.950000       |25.840000        |15.890000     |15.860000     |

### The difference between average wind speeds and max wind speeds by month (in MPH)
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
ORDER BY MONTH(DATEADD(m, 2, date));
```
|month_name|season_month|avg_wind_mph   |max_wind_mph|avg_max_wind_diff|
|----------|------------|---------------|------------|-----------------|
|November  |1           |23.470000      |30.790000   |7.320000         |
|December  |2           |20.190000      |29.370000   |9.180000         |
|January   |3           |21.640000      |31.360000   |9.720000         |
|February  |4           |20.890000      |30.070000   |9.180000         |
|March     |5           |18.150000      |25.890000   |7.740000         |
|April     |6           |14.060000      |21.230000   |7.170000         |

### The occurances of wind speeds experienced, matched against the Beaufort Scale - Total
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
ORDER BY bs.wind_force;
```
|wind_force|wind_speed|description    |count|percentage|
|----------|----------|---------------|-----|----------|
|0         |<1        |Calm           |27   |1         |
|1         |1-3       |Light Air      |121  |4         |
|2         |4-7       |Light Breeze   |285  |11        |
|3         |8-12      |Gentle Breeze  |395  |15        |
|4         |13-18     |Moderate Breeze|488  |19        |
|5         |19-24     |Fresh Breeze   |391  |15        |
|6         |25-31     |Strong Breeze  |334  |13        |
|7         |32-38     |Near Gale      |220  |8         |
|8         |39-46     |Gale           |145  |5         |
|9         |47-54     |Strong Gale    |46   |1         |
|10        |55-63     |Storm          |21   |0         |
|11        |64-72     |Violent Storm  |5    |0         |

### The occurances of wind speeds experienced, matched against the Beaufort Scale - Total by Month
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
ORDER BY wind_force;
```
|wind_force|wind_speed|description    |Nov_count|Dec_count|Jan_count|Feb_count|Mar_count|Apr_count|
|----------|----------|---------------|---------|---------|---------|---------|---------|---------|
|0         |<1        |Calm           |1        |4        |7        |5        |6        |4        |
|1         |1-3       |Light Air      |2        |22       |22       |22       |37       |16       |
|2         |4-7       |Light Breeze   |4        |58       |60       |57       |71       |35       |
|3         |8-12      |Gentle Breeze  |4        |102      |88       |83       |91       |27       |
|4         |13-18     |Moderate Breeze|6        |132      |134      |98       |103      |15       |
|5         |19-24     |Fresh Breeze   |4        |88       |108      |97       |79       |15       |
|6         |25-31     |Strong Breeze  |0        |83       |93       |81       |64       |13       |
|7         |32-38     |Near Gale      |3        |53       |63       |56       |40       |5        |
|8         |39-46     |Gale           |3        |33       |50       |32       |21       |6        |
|9         |47-54     |Strong Gale    |1        |9        |17       |10       |9        |0        |
|10        |55-63     |Storm          |2        |6        |7        |4        |1        |1        |
|11        |64-72     |Violent Storm  |1        |1        |1        |2        |0        |0        |

## The highest wind speeds (MPH) recorded each season
```sql
SELECT
	season,
	MAX(avg_wind_mph) AS highest_avg_wind_speed_mph,
	MAX(max_wind_mph) AS highest_max_wind_speed_mph
FROM weatherline
WHERE location = 'Helvellyn summit'
GROUP BY season
ORDER BY season;
```
|season|highest_avg_wind_speed_mph|highest_max_wind_speed_mph|
|------|--------------------------|--------------------------|
|1997 - 1998|69.00                     |78.00                     |
|1998 - 1999|55.00                     |64.00                     |
|1999 - 2000|65.00                     |87.00                     |
|2000 - 2001|72.00                     |85.00                     |
|2001 - 2002|59.00                     |90.80                     |
|2002 - 2003|47.10                     |68.40                     |
|2003 - 2004|45.60                     |82.00                     |
|2005 - 2006|47.10                     |60.70                     |
|2006 - 2007|52.10                     |76.80                     |
|2007 - 2008|48.10                     |68.00                     |
|2008 - 2009|41.70                     |53.40                     |
|2009 - 2010|50.10                     |64.30                     |
|2010 - 2011|54.30                     |82.10                     |
|2011 - 2012|56.80                     |78.70                     |
|2012 - 2013|54.30                     |69.90                     |
|2013 - 2014|56.00                     |72.00                     |
|2014 - 2015|56.80                     |84.90                     |
|2015 - 2016|63.40                     |77.80                     |
|2016 - 2017|48.00                     |200.00                    |
|2017 - 2018|49.60                     |81.70                     |
|2018 - 2019|50.30                     |63.40                     |
|2019 - 2020|50.30                     |63.40                     |
|2020 - 2021|55.70                     |80.20                     |

## Wind direction occurences counted
```sql
SELECT
	wind_direction,
	COUNT(wind_direction) AS count,
	COUNT(wind_direction) * 100 / SUM(COUNT(wind_direction)) over() AS percentage
FROM weatherline
WHERE location = 'Helvellyn summit'
GROUP BY wind_direction
ORDER BY COUNT(wind_direction) DESC;
```
|wind_force|wind_speed|description    |Nov_count|Dec_count|Jan_count|Feb_count|Mar_count|Apr_count|
|----------|----------|---------------|---------|---------|---------|---------|---------|---------|
|0         |<1        |Calm           |1        |4        |7        |5        |6        |4        |
|1         |1-3       |Light Air      |2        |22       |22       |22       |37       |16       |
|2         |4-7       |Light Breeze   |4        |58       |60       |57       |71       |35       |
|3         |8-12      |Gentle Breeze  |4        |102      |88       |83       |91       |27       |
|4         |13-18     |Moderate Breeze|6        |132      |134      |98       |103      |15       |
|5         |19-24     |Fresh Breeze   |4        |88       |108      |97       |79       |15       |
|6         |25-31     |Strong Breeze  |0        |83       |93       |81       |64       |13       |
|7         |32-38     |Near Gale      |3        |53       |63       |56       |40       |5        |
|8         |39-46     |Gale           |3        |33       |50       |32       |21       |6        |
|9         |47-54     |Strong Gale    |1        |9        |17       |10       |9        |0        |
|10        |55-63     |Storm          |2        |6        |7        |4        |1        |1        |
|11        |64-72     |Violent Storm  |1        |1        |1        |2        |0        |0        |
