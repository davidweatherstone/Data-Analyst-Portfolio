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

The time of day for each summit is recorded for some seasons it is not included for all. The Fell top assessors generally begin their walk by mid morning and reach the summit between 12:00 and 14:00.

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
| season      | earliest_date | latest_date | season_length |
|-------------|---------------|-------------|---------------|
| 1997 - 1998 | 1997-11-24    | 1998-04-18  | 145           |
| 1998 - 1999 | 1998-11-23    | 1999-04-17  | 145           |
| 1999 - 2000 | 1999-12-06    | 2000-04-24  | 140           |
| 2000 - 2001 | 2000-11-20    | 2001-02-23  | 95            |
| 2001 - 2002 | 2001-12-10    | 2002-04-16  | 127           |
| 2002 - 2003 | 2002-12-02    | 2003-04-20  | 139           |
| 2003 - 2004 | 2003-12-01    | 2004-03-25  | 115           |
| 2005 - 2006 | 2005-12-08    | 2006-03-31  | 113           |
| 2006 - 2007 | 2006-12-04    | 2007-04-18  | 135           |
| 2007 - 2008 | 2007-12-01    | 2008-04-20  | 141           |
| 2008 - 2009 | 2008-11-29    | 2009-04-15  | 137           |
| 2009 - 2010 | 2009-11-28    | 2010-04-09  | 132           |
| 2010 - 2011 | 2010-12-04    | 2011-04-04  | 121           |
| 2011 - 2012 | 2011-12-03    | 2012-04-09  | 128           |
| 2012 - 2013 | 2012-12-01    | 2013-04-10  | 130           |
| 2013 - 2014 | 2013-12-06    | 2014-04-30  | 145           |
| 2014 - 2015 | 2014-12-05    | 2015-04-29  | 145           |
| 2015 - 2016 | 2015-12-04    | 2016-04-27  | 145           |
| 2016 - 2017 | 2016-12-02    | 2017-04-17  | 136           |
| 2017 - 2018 | 2017-11-30    | 2018-04-07  | 128           |
| 2018 - 2019 | 2018-11-29    | 2019-03-05  | 96            |
| 2019 - 2020 | 2019-11-29    | 2020-03-05  | 97            |
| 2020 - 2021 | 2020-11-30    | 2021-04-05  | 126           |

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
Sample of result:
| date  | season_month | day_of_month | records |
|-------|--------------|--------------|---------|
| 01-12 | 2            | 01           | 12      |
| 02-12 | 2            | 02           | 14      |
| 03-12 | 2            | 03           | 15      |
| 04-12 | 2            | 04           | 18      |
| 05-12 | 2            | 05           | 19      |
| 06-12 | 2            | 06           | 21      |
| 07-12 | 2            | 07           | 21      |
| 08-12 | 2            | 08           | 22      |
| 09-12 | 2            | 09           | 22      |
| 10-12 | 2            | 10           | 23      |

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
	CAST(AVG(november_air_temp) AS DECIMAL(10,2)) AS avg_nov_air_temp,
	CAST(AVG(december_air_temp) AS DECIMAL(10,2)) AS avg_dec_air_temp,
	CAST(AVG(january_air_temp) AS DECIMAL(10,2)) AS avg_jan_air_temp,
	CAST(AVG(february_air_temp) AS DECIMAL(10,2)) AS avg_feb_air_temp,
	CAST(AVG(march_air_temp) AS DECIMAL(10,2)) AS avg_mar_air_temp,
	CAST(AVG(april_air_temp) AS DECIMAL(10,2)) AS avg_apr_air_temp
FROM cte
GROUP BY season
ORDER BY season;
```
| season      | avg_nov_air_temp | avg_dec_air_temp | avg_jan_air_temp | avg_feb_air_temp | avg_mar_air_temp | avg_apr_air_temp |
|-------------|------------------|------------------|------------------|------------------|------------------|------------------|
| 1997 - 1998 | 2.74             | 1.06             | -.03             | 2.28             | 2.41             | 1.25             |
| 1998 - 1999 | 1.74             | .56              | .31              | -.01             | 2.81             | 5.82             |
| 1999 - 2000 |                  | -.19             | 1.43             | .70              | 2.85             | 2.67             |
| 2000 - 2001 | 2.14             | .55              | -1.01            | .49              |                  |                  |
| 2001 - 2002 |                  | .20              | 1.28             | -.27             | 2.45             | 4.46             |
| 2002 - 2003 |                  | .62              | .22              | .58              | 5.22             | 8.81             |
| 2003 - 2004 |                  | .87              | .10              | .02              | .42              |                  |
| 2005 - 2006 |                  | .31              | .05              | .15              | -1.07            |                  |
| 2006 - 2007 |                  | 2.44             | 1.40             | 1.62             | 1.85             | 6.26             |
| 2007 - 2008 |                  | 1.21             | .74              | 2.86             | -.69             | -1.36            |
| 2008 - 2009 | -1.65            | -.01             | -.88             |                  | -1.60            |                  |
| 2009 - 2010 | -2.10            | -1.14            | -3.33            | -2.64            | .73              | .60              |
| 2010 - 2011 |                  | -3.94            | -1.11            | .11              | 1.72             | 5.30             |
| 2011 - 2012 |                  | -.30             | -.54             | -.12             | 3.96             | 2.04             |
| 2012 - 2013 |                  | -.79             | -1.99            | -2.05            | -3.06            | -3.27            |
| 2013 - 2014 |                  | .75              | -.18             | -.25             | 2.39             | 5.00             |
| 2014 - 2015 |                  | -.01             | -2.17            | -1.03            | -.53             | 3.84             |
| 2015 - 2016 |                  | 2.98             | .00              | -1.92            | .73              | 1.60             |
| 2016 - 2017 |                  | 2.05             | -.06             | .08              | 1.72             | 1.20             |
| 2017 - 2018 |                  | -.32             | -1.16            | -2.67            | -.97             | .32              |
| 2018 - 2019 | -3.30            | .65              | .64              | -.91             | -.90             |                  |
| 2019 - 2020 |                  | .54              | .60              | -.91             | -.90             |                  |
| 2020 - 2021 |                  | -.31             | -2.08            | -.65             | 2.02             | .04              |

### The difference between average air temperature and average wind chill temperature by month (in Celcius)
```sql
SELECT 
	DATENAME(MONTH, DATEADD(MONTH, 0, date)) AS 'month_name',
	MONTH(DATEADD(m, 2, DATE)) AS season_month,
	CAST(AVG(air_temp_c) AS DECIMAL(10,2)) AS avg_air_temp_c,
	CAST(AVG(wind_chill_temp_c) AS DECIMAL(10,2)) AS avg_wind_chill_temp_c,
	CAST(AVG(air_temp_c) - AVG(wind_chill_temp_c) AS DECIMAL(10,2)) AS avg_vs_wind_chill_diff
FROM weatherline
WHERE	air_temp_c IS NOT NULL AND
		wind_chill_temp_c IS NOT NULL AND
		location = 'Helvellyn summit'
GROUP BY DATENAME(MONTH, DATEADD(MONTH, 0, date)), MONTH(DATEADD(m, 2, DATE))
ORDER BY MONTH(DATEADD(m, 2, DATE));
```
| month_name | season_month | avg_air_temp_c | avg_wind_chill_temp_c | avg_vs_wind_chill_diff |
|------------|--------------|----------------|-----------------------|------------------------|
| November   | 1            | -2.15          | -8.08                 | 5.93                   |
| December   | 2            | .31            | -8.23                 | 8.54                   |
| January    | 3            | -.53           | -9.89                 | 9.35                   |
| February   | 4            | -.42           | -9.19                 | 8.76                   |
| March      | 5            | 1.00           | -6.99                 | 7.99                   |
| April      | 6            | 3.28           | -4.49                 | 7.77                   |

### The difference in temperature between the summit of Helvellyn and the base (Glenridding) temperature (in Celcius)
```sql
SELECT 
	DATENAME(MONTH, DATEADD(MONTH, 0, date)) AS 'month_name',
	MONTH(DATEADD(m, 2, DATE)) AS season_month,
	CAST(AVG(air_temp_c) AS DECIMAL(10,2)) AS avg_air_temp_c,
	CAST(AVG(air_temp_c_town) AS DECIMAL(10,2)) AS avg_temp_c_town,
	CAST(AVG(air_temp_c_town) - AVG(air_temp_c) AS DECIMAL(10,2)) AS difference
FROM weatherline
WHERE	location = 'Helvellyn summit' AND 
		town = 'Glenridding' AND
		air_temp_c_town IS NOT NULL AND
		air_temp_c IS NOT NULL
GROUP BY DATENAME(MONTH, DATEADD(MONTH, 0, date)), MONTH(DATEADD(m, 2, DATE))
ORDER BY MONTH(DATEADD(m, 2, DATE));
```
| month_name | season_month | avg_air_temp_c | avg_temp_c_town | difference |
|------------|--------------|----------------|-----------------|------------|
| November   | 1            | 2.14           | 7.60            | 5.46       |
| December   | 2            | .59            | 6.19            | 5.60       |
| January    | 3            | .32            | 6.13            | 5.80       |
| February   | 4            | .60            | 7.18            | 6.58       |
| March      | 5            | 2.89           | 9.55            | 6.66       |
| April      | 6            | 4.86           | 11.79           | 6.93       |

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
		air_temp_c - LAG(air_temp_c, 1) over(ORDER BY date) AS diff_to_prev_day
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
|2003-03-12|-13.80           |
|2006-01-30|11.80          |

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
	CAST(AVG(november_wind) AS DECIMAL(10,2)) AS avg_nov_wind,
	CAST(AVG(december_wind) AS DECIMAL(10,2)) AS avg_dec_wind,
	CAST(AVG(january_wind) AS DECIMAL(10,2)) AS avg_jan_wind,
	CAST(AVG(february_wind) AS DECIMAL(10,2)) AS avg_feb_wind,
	CAST(AVG(march_wind) AS DECIMAL(10,2)) AS avg_mar_wind,
	CAST(AVG(april_wind) AS DECIMAL(10,2)) AS avg_apr_wind
FROM cte
GROUP BY season
ORDER BY season;
```
| season      | avg_nov_wind | avg_dec_wind | avg_jan_wind | avg_feb_wind | avg_mar_wind | avg_apr_wind |
|-------------|--------------|--------------|--------------|--------------|--------------|--------------|
| 1997 - 1998 | 17.43        | 21.37        | 22.87        | 28.52        | 20.50        | 18.36        |
| 1998 - 1999 | 15.86        | 23.10        | 23.83        | 24.33        | 21.52        | 17.06        |
| 1999 - 2000 |              | 25.12        | 23.62        | 28.59        | 17.71        | 14.47        |
| 2000 - 2001 | 33.91        | 20.23        | 18.70        | 18.65        |              |              |
| 2001 - 2002 |              | 13.50        | 26.86        | 26.60        | 19.65        | 7.51         |
| 2002 - 2003 |              | 10.24        | 20.00        | 13.78        | 15.64        | 9.69         |
| 2003 - 2004 |              | 14.74        | 20.13        | 14.23        | 18.76        |              |
| 2005 - 2006 |              | 16.62        | 14.68        | 16.62        | 14.02        |              |
| 2006 - 2007 |              | 22.62        | 26.85        | 11.52        | 20.97        | 7.04         |
| 2007 - 2008 |              | 20.05        | 22.27        | 22.03        | 22.11        | 13.80        |
| 2008 - 2009 | 5.50         | 16.75        | 19.77        |              | 20.90        |              |
| 2009 - 2010 | 23.43        | 17.09        | 16.73        | 10.41        | 15.65        | 15.75        |
| 2010 - 2011 |              | 15.30        | 18.56        | 17.74        | 14.47        | 45.00        |
| 2011 - 2012 |              | 22.70        | 18.92        | 20.88        | 15.09        | 19.78        |
| 2012 - 2013 |              | 17.79        | 19.22        | 17.21        | 18.10        | 19.63        |
| 2013 - 2014 |              | 30.22        | 22.78        | 21.39        | 18.07        | 6.00         |
| 2014 - 2015 |              | 25.45        | 25.91        | 19.89        | 25.48        | 12.60        |
| 2015 - 2016 |              | 28.99        | 20.56        | 19.87        | 15.89        | 13.10        |
| 2016 - 2017 |              | 20.51        | 21.05        | 27.37        | 17.51        | 26.70        |
| 2017 - 2018 |              | 20.26        | 21.12        | 15.76        | 16.39        | 20.15        |
| 2018 - 2019 | 11.30        | 22.73        | 26.21        | 29.67        | 14.40        |              |
| 2019 - 2020 |              | 22.51        | 25.89        | 29.67        | 14.40        |              |
| 2020 - 2021 |              | 19.58        | 20.95        | 25.84        | 15.89        | 15.86        |

### The difference between average wind speeds and max wind speeds by month (in MPH)
```sql
SELECT 
	DATENAME(MONTH, DATEADD(MONTH, 0, date)) AS 'month_name',
	MONTH(DATEADD(m, 2, date)) AS season_month,
	CAST(AVG(avg_wind_mph) AS DECIMAL(10,2)) AS avg_wind_mph,
	CAST(AVG(max_wind_mph) AS DECIMAL(10,2)) AS max_wind_mph,
	CAST(AVG(max_wind_mph) - AVG(avg_wind_mph) AS DECIMAL(10,2)) AS avg_max_wind_diff
FROM weatherline
WHERE	avg_wind_mph IS NOT NULL AND
		max_wind_mph IS NOT NULL AND
		location = 'Helvellyn summit'
GROUP BY DATENAME(MONTH, DATEADD(MONTH, 0, date)), MONTH(DATEADD(m, 2, DATE))
ORDER BY MONTH(DATEADD(m, 2, date));
```
| month_name | season_month | avg_wind_mph | max_wind_mph | avg_max_wind_diff |
|------------|--------------|--------------|--------------|-------------------|
| November   | 1            | 23.47        | 30.79        | 7.32              |
| December   | 2            | 20.19        | 29.37        | 9.18              |
| January    | 3            | 21.64        | 31.36        | 9.72              |
| February   | 4            | 20.89        | 30.07        | 9.18              |
| March      | 5            | 18.15        | 25.89        | 7.74              |
| April      | 6            | 14.06        | 21.23        | 7.17              |

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
	ROUND(COUNT(november_wind),2) AS nov_count,
	ROUND(COUNT(december_wind),2) AS dec_count,
	ROUND(COUNT(january_wind),2) AS jan_count,
	ROUND(COUNT(february_wind),2) AS feb_count,
	ROUND(COUNT(march_wind),2) AS mar_count,
	ROUND(COUNT(april_wind),2) AS apr_count
FROM cte
GROUP BY wind_force, wind_speed, description
ORDER BY wind_force;
```
|wind_force|wind_speed|description    |nov_count|dec_count|jan_count|feb_count|mar_count|apr_count|
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
WHERE 	location = 'Helvellyn summit' AND
		wind_direction IS NOT NULL
GROUP BY wind_direction
ORDER BY COUNT(wind_direction) DESC;
```
| wind_direction | count | percentage |
|----------------|-------|------------|
| SW             | 502   | 20         |
| W              | 482   | 19         |
| NW             | 244   | 9          |
| NE             | 181   | 7          |
| WSW            | 175   | 7          |
| SSW            | 128   | 5          |
| N              | 127   | 5          |
| S              | 121   | 4          |
| E              | 114   | 4          |
| WNW            | 81    | 3          |
| NNE            | 80    | 3          |
| SE             | 79    | 3          |
| NNW            | 40    | 1          |
| SSE            | 32    | 1          |
| ENE            | 22    | 0          |
| Varying        | 16    | 0          |
| ESE            | 13    | 0          |
| None           | 4     | 0          |
| NWN            | 1     | 0          |
