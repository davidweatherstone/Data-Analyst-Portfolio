https://www.kaggle.com/datasets/devansodariya/road-accident-united-kingdom-uk-dataset

color_palette = ["#440154", "#482677", "#404788", "#33638d", "#287d8e",
    "#1f968b", '#29af7f', '#55c667', '#73d055', '#b8de29', '#fde725']

 


```python
# Importing hte modules, setting plotting formats and importing the data

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, time

sns.set(font_scale=1, style="whitegrid", font="Calibri")

accidents = pd.read_csv("UK_Accident.csv")
accidents.memory_usage(deep=True).sum()
```




    1806485281




```python
# Creating a function to transform and clean the data as required for analysis.

def tweak_accidents(accidents):
   drop_columns = ["Unnamed: 0", 
                "Accident_Index",
                "Location_Easting_OSGR",
                "Location_Northing_OSGR",
                "Police_Force", 
                "Local_Authority_(District)", 
                "Local_Authority_(Highway)", 
                "1st_Road_Class",
                "1st_Road_Number", 
                "2nd_Road_Class",
                "2nd_Road_Number",
                "Year",
                "Did_Police_Officer_Attend_Scene_of_Accident",
                "LSOA_of_Accident_Location",
                "Junction_Control",
                "Pedestrian_Crossing-Human_Control",
                "Pedestrian_Crossing-Physical_Facilities"]
   
   return (accidents
      .rename(columns={"Speed_limit":"Speed_Limit"})
      .assign(
         Longitude=lambda df_: df_['Longitude'].astype("float32"),
         Latitude=lambda df_: df_['Latitude'].astype("float32"),
         Accident_Severity=lambda df_: df_['Accident_Severity']
            .map({1: "Most Severe", 2: "Moderate Severity", 3: "Least Severe"})
            .astype("category"),
         Number_of_Vehicles=lambda df_: df_['Number_of_Vehicles'].astype("uint8"),
         Number_of_Casualties=lambda df_: df_['Number_of_Casualties'].astype("uint8"),
         Date=lambda df_: pd.to_datetime(df_['Date'], format="%d/%m/%Y"),
         Day_of_Week=lambda df_: df_['Day_of_Week'].astype("uint8"),
         Time=lambda df_: pd.to_datetime(df_['Time'], format="%H:%M").dt.time,
         Road_Type=lambda df_: df_['Road_Type'].astype("category"),
         Speed_Limit=lambda df_: df_['Speed_Limit'].astype("uint8"),
         Light_Conditions=lambda df_: df_['Light_Conditions'].astype("category"),
         Weather_Conditions=lambda df_: df_['Weather_Conditions'].astype("category"),
         Road_Surface_Conditions=lambda df_: df_['Road_Surface_Conditions'].astype("category"),
         Special_Conditions_at_Site=lambda df_: df_['Special_Conditions_at_Site'].astype("category"),
         Carriageway_Hazards=lambda df_: df_['Carriageway_Hazards'].astype("category"),
         Urban_or_Rural_Area=lambda df_: df_['Urban_or_Rural_Area']
            .map({1: "Urban", 2: "Suburban", 3: "Rural"})
            .astype("category")
         )
      .drop(columns=drop_columns)
      .dropna()
      )
```


```python
# Applying the function

accidents = tweak_accidents(accidents)
accidents.info()
accidents.memory_usage(deep=True).sum()
```

    <class 'pandas.core.frame.DataFrame'>
    Int64Index: 1503932 entries, 0 to 1504149
    Data columns (total 16 columns):
     #   Column                      Non-Null Count    Dtype         
    ---  ------                      --------------    -----         
     0   Longitude                   1503932 non-null  float32       
     1   Latitude                    1503932 non-null  float32       
     2   Accident_Severity           1503932 non-null  category      
     3   Number_of_Vehicles          1503932 non-null  uint8         
     4   Number_of_Casualties        1503932 non-null  uint8         
     5   Date                        1503932 non-null  datetime64[ns]
     6   Day_of_Week                 1503932 non-null  uint8         
     7   Time                        1503932 non-null  object        
     8   Road_Type                   1503932 non-null  category      
     9   Speed_Limit                 1503932 non-null  uint8         
     10  Light_Conditions            1503932 non-null  category      
     11  Weather_Conditions          1503932 non-null  category      
     12  Road_Surface_Conditions     1503932 non-null  category      
     13  Special_Conditions_at_Site  1503932 non-null  category      
     14  Carriageway_Hazards         1503932 non-null  category      
     15  Urban_or_Rural_Area         1503932 non-null  category      
    dtypes: category(8), datetime64[ns](1), float32(2), object(1), uint8(4)
    memory usage: 63.1+ MB
    




    126335268



## Accident Severity Trends:


```python
# What is the trend in accident severity over the years?

## Creating a DataFrame showing the count of Accidents by Severity Level across the Years

(accidents
 .resample('Y', on='Date')['Accident_Severity']
 .value_counts()
 .unstack()
 .reset_index()
 .assign(Date=lambda df_: df_.Date.dt.year)
 .query("Date != 2008")
 .set_index("Date")
 .rename_axis(columns=None))
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Least Severe</th>
      <th>Moderate Severity</th>
      <th>Most Severe</th>
    </tr>
    <tr>
      <th>Date</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>2005</th>
      <td>170710</td>
      <td>25014</td>
      <td>2913</td>
    </tr>
    <tr>
      <th>2006</th>
      <td>161257</td>
      <td>24943</td>
      <td>2926</td>
    </tr>
    <tr>
      <th>2007</th>
      <td>155050</td>
      <td>24316</td>
      <td>2714</td>
    </tr>
    <tr>
      <th>2009</th>
      <td>139485</td>
      <td>21995</td>
      <td>2057</td>
    </tr>
    <tr>
      <th>2010</th>
      <td>132235</td>
      <td>20440</td>
      <td>1731</td>
    </tr>
    <tr>
      <th>2011</th>
      <td>128683</td>
      <td>20982</td>
      <td>1797</td>
    </tr>
    <tr>
      <th>2012</th>
      <td>151192</td>
      <td>26481</td>
      <td>2037</td>
    </tr>
    <tr>
      <th>2013</th>
      <td>117424</td>
      <td>19621</td>
      <td>1607</td>
    </tr>
    <tr>
      <th>2014</th>
      <td>123988</td>
      <td>20676</td>
      <td>1658</td>
    </tr>
  </tbody>
</table>
</div>




```python
## Plotting the Accident Severity trend by Count and Year

count_severity_by_year = (accidents
 .resample('Y', on='Date')['Accident_Severity']
 .value_counts()
 .reset_index(name="Count")
 .assign(Date=lambda df_: df_.Date.dt.year)
 .query("Date != 2008"))

plot_ct_severity_by_year = (sns
 .catplot(data=count_severity_by_year, 
          kind="bar",
          x="Date",
          y="Count",
          col="Accident_Severity",
          sharey=False,
          color="#33638d")
 )

for i, ax in enumerate(plot_ct_severity_by_year.axes.flat):
        ax.set_xlabel("Year")
        if i == 0:
            ax.set_ylabel("Count of Accidents")
            
        for p in ax.patches:
            height = p.get_height()
            ax.annotate(f'{height:.0f}', (p.get_x() + p.get_width() / 2, height),
                        ha='center', va='bottom', fontsize=12, color="black")


subtitle_text = "The trend shows a decline in the number of accidents at every level of severity over time"

plt.suptitle("Counting the Accident Severity by Year", fontsize=24)
plt.figtext(0.5, 0.88, subtitle_text, fontsize=12, ha='center')
plt.tight_layout(rect=[0, 0.05, 1, 0.95])
plt.ylabel("Count of Accidents")

```




    Text(1017.6296296296299, 0.5, 'Count of Accidents')




    
![png](output_6_1.png)
    



```python
## Plotting the Accident Severity trend by Percentage and Year

total_accidents_by_year = (accidents
 .assign(Date=lambda df_: df_.Date.dt.year)
 .groupby(["Date"])
 .size()
 .reset_index(name="Count")
)

percentage_severity_by_year = (accidents
 .assign(Date=lambda df_: df_.Date.dt.year)
 .groupby(["Date", "Accident_Severity"])
 .size()
 .div(total_accidents_by_year.set_index("Date")["Count"])
 .mul(100)
 .round(2)
 .reset_index(name="Percentage")
)

plot_pct_severity_by_year = (sns
 .catplot(data=percentage_severity_by_year, 
          kind="bar",
          x="Date",
          y="Percentage",
          col="Accident_Severity",
          sharey=False,
          color="#33638d"))

for i, ax in enumerate(plot_pct_severity_by_year.axes.flat):
        ax.set_xlabel("Year")
        if i == 0:
            ax.set_ylabel("Percentage of Accidents")
        
        for p in ax.patches:
            height = p.get_height()
            ax.annotate(f'{height:.1f}%', (p.get_x() + p.get_width() / 2, height),
                        ha='center', va='bottom', fontsize=12, color="black")

subtitle_text = "A decreasing trend in the most severe accidents"

plt.suptitle("Percentage of Accident Severity by Year", fontsize=24)
plt.figtext(0.5, 0.88, subtitle_text, fontsize=12, ha='center')
plt.tight_layout(rect=[0, 0.05, 1, 0.95])
```


    
![png](output_7_0.png)
    



```python
## Creating a DataFrame showing the changes in the Count of Accidents across the Years

accident_changes_by_ct = (accidents
 .resample('Y', on='Date').size()
 .reset_index(name="Count")
 .assign(Date=lambda df_: df_.Date.dt.year)
 .query("Date != 2008")
 .assign(Previous_Count=lambda df_: df_.Count - df_.Count.shift(1)))

accident_changes_by_ct
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Date</th>
      <th>Count</th>
      <th>Previous_Count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2005</td>
      <td>198637</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2006</td>
      <td>189126</td>
      <td>-9511.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2007</td>
      <td>182080</td>
      <td>-7046.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2009</td>
      <td>163537</td>
      <td>-18543.0</td>
    </tr>
    <tr>
      <th>5</th>
      <td>2010</td>
      <td>154406</td>
      <td>-9131.0</td>
    </tr>
    <tr>
      <th>6</th>
      <td>2011</td>
      <td>151462</td>
      <td>-2944.0</td>
    </tr>
    <tr>
      <th>7</th>
      <td>2012</td>
      <td>179710</td>
      <td>28248.0</td>
    </tr>
    <tr>
      <th>8</th>
      <td>2013</td>
      <td>138652</td>
      <td>-41058.0</td>
    </tr>
    <tr>
      <th>9</th>
      <td>2014</td>
      <td>146322</td>
      <td>7670.0</td>
    </tr>
  </tbody>
</table>
</div>




```python
## Plotting the changes in the Count of Accidents across the Years

colors = ["#7bc164" if val < 0 else "#33638d" for val in accident_changes_by_ct['Previous_Count']]

plot_ct_change_by_year = (sns
      .barplot(
          data=accident_changes_by_ct,
          x="Date", 
          y="Previous_Count",
          palette=colors))

for p in plot_ct_change_by_year.patches:
    height = p.get_height()
    if height >= 0:
        label_position = height
    else:
        label_position = height - 3000
    plot_ct_change_by_year.annotate(
        f'{height:.0f}', 
        (p.get_x() + p.get_width() / 2, label_position),
        ha='center', 
        va='bottom', 
        fontsize=12, 
        color="black"
    )

plt.suptitle("Total Accident Changes each Period", fontsize=20)
plt.ylabel("Previous Count")
plt.xlabel("")
plt.tight_layout()
```


    
![png](output_9_0.png)
    


## Day of the Week Analysis:


```python
# Which day of the week witnesses the highest number of accidents?

(accidents
 .assign(Date=lambda df_: df_.Date.dt.strftime("%A"))
 ["Date"]
 .value_counts()[0:1])
```




    Friday    247103
    Name: Date, dtype: int64




```python
## Plotting the count of accidents by the day of the week

accident_ct_by_day = (accidents
            .assign(Date=lambda df_: df_.Date.dt.strftime("%A"))
            .groupby(["Date", "Day_of_Week"])
            .size()
            .reset_index(name="Count")
            .sort_values(by="Day_of_Week")
            )

plot_day_of_week = (sns
 .barplot(data=accident_ct_by_day,
          x="Date",
          y="Count",
          color="#33638d")
 )

for p in plot_day_of_week.patches:
    width = p.get_width()
    height = p.get_height()
    x, y = p.get_xy() 
    plot_day_of_week.annotate(f'{height:.0f}', (x + width/2, y + height + (height/95)), 
                         ha='center', 
                         fontsize=12, 
                         color='black')


subtitle_text = "Accidents are lowest on weekends increase throughout the week"

plt.figtext(0.5, 0.88, subtitle_text, fontsize=12, ha='center')
plt.suptitle("Count of Accidents by Day of Week", fontsize=24)
plt.xticks(rotation=45)
plt.xlabel("")
plt.tight_layout(rect=[0, 0.05, 1, 0.95])
```


    
![png](output_12_0.png)
    


## Time Analysis:

* What are the peak hours for accidents during the day?


```python
# Are there differences in accident frequency during daylight and nighttime?

## Dictionary of Average Sun Rise and Sun Set times by month in the UK
month_times = {
    "January": (time(8, 0, 0), time(15, 0, 0)),
    "February": (time(7, 30, 0), time(16, 30, 0)),
    "March": (time(6, 30, 0), time(17, 30, 0)),
    "April": (time(6, 0, 0), time(20, 0, 0)),
    "May": (time(5, 30, 0), time(20, 30, 0)),
    "June": (time(4, 30, 0), time(21, 30, 0)),
    "July": (time(4, 30, 0), time(21, 30, 0)),
    "August": (time(5, 0, 0), time(20, 0, 0)),
    "September": (time(6, 0, 0), time(19, 0, 0)),
    "October": (time(7, 0, 0), time(18, 0, 0)),
    "November": (time(7, 30, 0), time(16, 30, 0)),
    "December": (time(8, 0, 0), time(15, 30, 0)),
}

light_mask = (
    (accidents["Time"] >= accidents["Date"].dt.month_name().map(month_times).str[0]) &
    (accidents["Time"] <= accidents["Date"].dt.month_name().map(month_times).str[1])
)

accidents["Day_Light"] = "Light"
accidents.loc[~light_mask, "Day_Light"] = "Dark"
accidents["Day_Light"] = accidents["Day_Light"].astype("category")
```


```python
## Creating a DataFrame showing the count of accidents by Day Light hours and Severity Level

day_light_accident_comparison = (accidents
 .groupby(["Day_Light", "Accident_Severity"])
 .size()
 .reset_index(name="Count")
 .assign(
        Total_Count=lambda df_: df_.groupby("Day_Light")["Count"].transform("sum"),
        Percentage=lambda df_: ((df_["Count"] / df_["Total_Count"]) * 100).round(2))
 .drop(columns="Total_Count")
 .sort_values("Day_Light", ascending=False)
)

day_light_accident_comparison
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Day_Light</th>
      <th>Accident_Severity</th>
      <th>Count</th>
      <th>Percentage</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>3</th>
      <td>Light</td>
      <td>Least Severe</td>
      <td>912478</td>
      <td>86.16</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Light</td>
      <td>Moderate Severity</td>
      <td>135573</td>
      <td>12.80</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Light</td>
      <td>Most Severe</td>
      <td>10988</td>
      <td>1.04</td>
    </tr>
    <tr>
      <th>0</th>
      <td>Dark</td>
      <td>Least Severe</td>
      <td>367546</td>
      <td>82.61</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Dark</td>
      <td>Moderate Severity</td>
      <td>68895</td>
      <td>15.49</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Dark</td>
      <td>Most Severe</td>
      <td>8452</td>
      <td>1.90</td>
    </tr>
  </tbody>
</table>
</div>




```python
## Plotting reported accidents count and percentage split by Day Light

fig, axes = plt.subplots(1, 2, figsize=(12,4))

colors = (["#7bc164" if val == "Light" else "#33638d" 
           for val in day_light_accident_comparison
           .query("Accident_Severity == 'Most Severe'")['Day_Light']])

day_light_ct = (sns
.barplot(
    data=day_light_accident_comparison.query("Accident_Severity == 'Most Severe'"), 
    x="Day_Light", 
    y="Count",
    ax=axes[0],
    palette=colors))

for p in day_light_ct.patches:
    width = p.get_width()
    height = p.get_height()
    x, y = p.get_xy() 
    day_light_ct.annotate(f'{height:.0f}', (x + width/2, y + height), 
                         ha='center', 
                         fontsize=12, 
                         color='black')

day_light_pct = (sns
.barplot(
    data=day_light_accident_comparison.query("Accident_Severity == 'Most Severe'"), 
    x="Day_Light", 
    y="Percentage",
    ax=axes[1],
    palette=colors))

for p in day_light_pct.patches:
    width = p.get_width()
    height = p.get_height()
    x, y = p.get_xy() 
    day_light_pct.annotate(f'{height:.2f}%', (x + width/2, y + height), 
                         ha='center', 
                         fontsize=12, 
                         color='black')

subtitle_text = "More severe accidents are reported during daylight hours, but"\
                " their proportion is almost double during the dark hours"

axes[0].set_title("Count of Severe Accidents by Day Light")
axes[0].set_xlabel("Day Light")
axes[1].set_title("Percentage of Severe Accidents by Day Light")
axes[1].set_xlabel("Day Light")
plt.suptitle("Severe Accidents by Light and Dark hours of the day")
plt.figtext(0.5, 0.88, subtitle_text, fontsize=12, ha='center')
plt.tight_layout(rect=[0, 0.05, 1, 0.95])
```


    
![png](output_16_0.png)
    


## Road Type Insights:

* Which road types are more prone to accidents?
* Do accidents on specific road types have higher severity?

## Speed Limit Impact:


```python
# Which road speed limit has the highest proportion of severe accidents?

speed_limit_severity_ct = (accidents
            .groupby(["Accident_Severity"])["Speed_Limit"]
            .value_counts()
            .unstack())

speed_limit_severity_pct = (speed_limit_severity_ct
                        .div(speed_limit_severity_ct.sum(axis=0), axis=1).mul(100)
                        .T
                        .stack()
                        .reset_index(["Speed_Limit", "Accident_Severity"])
                        .rename(columns={0: "Percentage"})
                    )

speed_limit_severity_pct[speed_limit_severity_pct["Accident_Severity"] == "Most Severe"].iloc[0:1]

# While the actual number of accidents at the speed limit 10mph is low, 
# the proportion of accidents that are deemed to be most severe are highest
# at this speed limit.
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Speed_Limit</th>
      <th>Accident_Severity</th>
      <th>Percentage</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>2</th>
      <td>10</td>
      <td>Most Severe</td>
      <td>14.285714</td>
    </tr>
  </tbody>
</table>
</div>




```python
## In order to focus our analysis on typical data points, I have filtered out
## the low-frequency accidents occurring below 20mph

speed_limit_severity_pct = (accidents
            .query("Speed_Limit >= 20")
            .groupby(["Accident_Severity"])["Speed_Limit"]
            .value_counts()
            .unstack())

speed_limit_severity_pct = (speed_limit_severity_pct
                        .div(speed_limit_severity_pct.sum(axis=0), axis=1).mul(100)
                        .T
                        .stack()
                        .reset_index(["Speed_Limit", "Accident_Severity"])
                        .rename(columns={0: "Percentage"})
                    )

(speed_limit_severity_pct[speed_limit_severity_pct["Accident_Severity"] == "Most Severe"]
.sort_values("Percentage", ascending=False)
.iloc[0:1])
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Speed_Limit</th>
      <th>Accident_Severity</th>
      <th>Percentage</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>14</th>
      <td>60</td>
      <td>Most Severe</td>
      <td>3.140038</td>
    </tr>
  </tbody>
</table>
</div>




```python
## Plotting Percentage of Accidents occuring at each Speed Limit by Severity

plot_speed_limit_severity_pct = (sns
 .catplot(
    data=speed_limit_severity_pct,
    kind="bar",
    x="Speed_Limit",
    y="Percentage",
    col="Accident_Severity",
    sharey=False,
    color="#33638d")
)

for i, ax in enumerate(plot_speed_limit_severity_pct.axes.flat):
        ax.set_xlabel("Speed Limit (MPH)")
        if i == 0:
            ax.set_ylabel("Percentage of Accidents")
            
        for p in ax.patches:
            height = p.get_height()
            offset = - 1
            ax.annotate(f'{height:.2f}%', (p.get_x() + p.get_width() / 2, height),
                        ha='center', va='bottom', fontsize=12, color="black")


subtitle_text = "Severe accidents trend worse as speed limits rise, with"\
                " a slight drop between 60mph and 70mph"
                            
plt.suptitle("Severity of Accidents by Speed Limit")
plt.figtext(0.5, 0.88, subtitle_text, fontsize=14, ha='center')
plt.tight_layout(rect=[0, 0.05, 1, 0.95])
```


    
![png](output_21_0.png)
    


## Road Surface and Special Conditions:

* Do specific road surface conditions or special conditions at sites lead to more accidents?
* What types of hazards are most associated with accidents?


```python
## Do windy conditions specifically affect certain speed zones?

accident_severity_by_wind = (accidents
        .assign(Windy=lambda df_: df_['Weather_Conditions']
                .str.contains("with high winds", case=False, regex=True))
        .groupby(["Accident_Severity", "Windy", "Speed_Limit"]).size()
        .reset_index(name="Count")
        )

accident_severity_by_wind.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Accident_Severity</th>
      <th>Windy</th>
      <th>Speed_Limit</th>
      <th>Count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Least Severe</td>
      <td>False</td>
      <td>10</td>
      <td>9</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Least Severe</td>
      <td>False</td>
      <td>15</td>
      <td>10</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Least Severe</td>
      <td>False</td>
      <td>20</td>
      <td>14296</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Least Severe</td>
      <td>False</td>
      <td>30</td>
      <td>822541</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Least Severe</td>
      <td>False</td>
      <td>40</td>
      <td>101209</td>
    </tr>
  </tbody>
</table>
</div>




```python
(sns
 .catplot(
    data=accident_severity_by_wind, 
    kind="bar", 
    x="Speed_Limit", 
    y="Count", 
    hue="Windy", 
    col="Accident_Severity",
    sharey=False,
    palette=["#7bc164", "#33638d"]))
```




    <seaborn.axisgrid.FacetGrid at 0x1e630c0fcd0>




    
![png](output_24_1.png)
    


## Urban vs. Rural Analysis:

* Are accidents more common in urban or rural areas?
* Do accident severity levels differ between urban and rural settings?


```python
accidents.columns
```




    Index(['Longitude', 'Latitude', 'Accident_Severity', 'Number_of_Vehicles',
           'Number_of_Casualties', 'Date', 'Day_of_Week', 'Time', 'Road_Type',
           'Speed_Limit', 'Light_Conditions', 'Weather_Conditions',
           'Road_Surface_Conditions', 'Special_Conditions_at_Site',
           'Carriageway_Hazards', 'Urban_or_Rural_Area', 'Day_Light'],
          dtype='object')




```python
accidents.Road_Type.value_counts()
```




    Single carriageway    1126781
    Dual carriageway       221717
    Roundabout             100453
    One way street          30977
    Slip road               15667
    Unknown                  8337
    Name: Road_Type, dtype: int64




```python
accidents_by_area = (accidents
 .groupby(["Urban_or_Rural_Area", "Accident_Severity"])
 .size()
 .reset_index(name="Count")
 .assign(
     Total_Count=lambda df_: df_.groupby("Urban_or_Rural_Area")["Count"].transform("sum"),
     Percentage=lambda df_: ((df_["Count"] / df_["Total_Count"]) *100).round(2))
 .drop(columns="Total_Count"))

accidents_by_area
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Urban_or_Rural_Area</th>
      <th>Accident_Severity</th>
      <th>Count</th>
      <th>Percentage</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Rural</td>
      <td>Least Severe</td>
      <td>32</td>
      <td>91.43</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Rural</td>
      <td>Moderate Severity</td>
      <td>3</td>
      <td>8.57</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Rural</td>
      <td>Most Severe</td>
      <td>0</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Suburban</td>
      <td>Least Severe</td>
      <td>434615</td>
      <td>81.70</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Suburban</td>
      <td>Moderate Severity</td>
      <td>84839</td>
      <td>15.95</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Suburban</td>
      <td>Most Severe</td>
      <td>12497</td>
      <td>2.35</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Urban</td>
      <td>Least Severe</td>
      <td>845377</td>
      <td>86.98</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Urban</td>
      <td>Moderate Severity</td>
      <td>119626</td>
      <td>12.31</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Urban</td>
      <td>Most Severe</td>
      <td>6943</td>
      <td>0.71</td>
    </tr>
  </tbody>
</table>
</div>




```python
by_area = sns.catplot(
    data=accidents_by_area, 
    kind="bar", 
    x="Urban_or_Rural_Area", 
    y="Percentage", 
    col="Accident_Severity",
    color="#33638d",
    sharey=False)

for i, ax in enumerate(by_area.axes.flat):
        ax.set_xlabel("Area")
        if i == 0:
            ax.set_ylabel("Percentage of Accidents")
            
        for p in ax.patches:
            height = p.get_height()
            offset = - 1
            ax.annotate(f'{height:.2f}%', (p.get_x() + p.get_width() / 2, height),
                        ha='center', va='bottom', fontsize=12, color="black")

subtitle_text = "Severe accidents trend worse as speed limits rise, with"\
                " a slight drop between 60mph and 70mph"
                            
plt.suptitle("Severity of Accidents by Area")
plt.figtext(0.5, 0.88, subtitle_text, fontsize=14, ha='center')
plt.tight_layout(rect=[0, 0.05, 1, 0.95])
```


    
![png](output_29_0.png)
    



```python
accidents_by_area_and_speed = (accidents
 .groupby(["Urban_or_Rural_Area", "Speed_Limit"])
 .size()
 .reset_index(name="Count")
 .assign(
     Total_Count=lambda df_: df_.groupby("Urban_or_Rural_Area")["Count"].transform("sum"),
     Percentage=lambda df_: ((df_["Count"] / df_["Total_Count"]) *100).round(2))
 .drop(columns="Total_Count"))

accidents_by_area_and_speed
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Urban_or_Rural_Area</th>
      <th>Speed_Limit</th>
      <th>Count</th>
      <th>Percentage</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Rural</td>
      <td>10</td>
      <td>0</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Rural</td>
      <td>15</td>
      <td>0</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Rural</td>
      <td>20</td>
      <td>0</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Rural</td>
      <td>30</td>
      <td>21</td>
      <td>60.00</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Rural</td>
      <td>40</td>
      <td>2</td>
      <td>5.71</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Rural</td>
      <td>50</td>
      <td>1</td>
      <td>2.86</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Rural</td>
      <td>60</td>
      <td>9</td>
      <td>25.71</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Rural</td>
      <td>70</td>
      <td>2</td>
      <td>5.71</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Suburban</td>
      <td>10</td>
      <td>6</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Suburban</td>
      <td>15</td>
      <td>0</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>10</th>
      <td>Suburban</td>
      <td>20</td>
      <td>1691</td>
      <td>0.32</td>
    </tr>
    <tr>
      <th>11</th>
      <td>Suburban</td>
      <td>30</td>
      <td>123055</td>
      <td>23.13</td>
    </tr>
    <tr>
      <th>12</th>
      <td>Suburban</td>
      <td>40</td>
      <td>53170</td>
      <td>10.00</td>
    </tr>
    <tr>
      <th>13</th>
      <td>Suburban</td>
      <td>50</td>
      <td>33144</td>
      <td>6.23</td>
    </tr>
    <tr>
      <th>14</th>
      <td>Suburban</td>
      <td>60</td>
      <td>225905</td>
      <td>42.47</td>
    </tr>
    <tr>
      <th>15</th>
      <td>Suburban</td>
      <td>70</td>
      <td>94980</td>
      <td>17.86</td>
    </tr>
    <tr>
      <th>16</th>
      <td>Urban</td>
      <td>10</td>
      <td>8</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>17</th>
      <td>Urban</td>
      <td>15</td>
      <td>10</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>18</th>
      <td>Urban</td>
      <td>20</td>
      <td>15463</td>
      <td>1.59</td>
    </tr>
    <tr>
      <th>19</th>
      <td>Urban</td>
      <td>30</td>
      <td>845102</td>
      <td>86.95</td>
    </tr>
    <tr>
      <th>20</th>
      <td>Urban</td>
      <td>40</td>
      <td>69214</td>
      <td>7.12</td>
    </tr>
    <tr>
      <th>21</th>
      <td>Urban</td>
      <td>50</td>
      <td>15642</td>
      <td>1.61</td>
    </tr>
    <tr>
      <th>22</th>
      <td>Urban</td>
      <td>60</td>
      <td>12236</td>
      <td>1.26</td>
    </tr>
    <tr>
      <th>23</th>
      <td>Urban</td>
      <td>70</td>
      <td>14271</td>
      <td>1.47</td>
    </tr>
  </tbody>
</table>
</div>




```python
sns.violinplot(data=accidents.sample(n=100, random_state=42), x="Urban_or_Rural_Area", y="Speed_Limit")
```




    <Axes: xlabel='Urban_or_Rural_Area', ylabel='Speed_Limit'>




    
![png](output_31_1.png)
    

