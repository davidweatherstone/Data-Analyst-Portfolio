# UK Vehicle Accidents 
[Data Source](https://www.kaggle.com/datasets/devansodariya/road-accident-united-kingdom-uk-dataset)

## Overview

This dataset was found on Kaggle, I thought it would be a useful dataset to practice data analysis with Python with a large real world data set. Vehicle Accidents are displayed as individual records (rows) with many data items collected per accident. Various columns allow for time series, regression and geospatial analysis. I'm not necessarily that interested in the data itself, but I am using it as practice to expand my skills with Python.

## Initial cleaning

To use the data further I've transformed the data to allow me to query it further and export as required.

<details>
<summary>Tweak Function created to clean and transform the Accident data</summary>

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
         Longitude=lambda df_: df_["Longitude"].astype("float32"),
         Latitude=lambda df_: df_["Latitude"].astype("float32"),
         Accident_Severity=lambda df_: df_["Accident_Severity"]
            .map({1: "Most Severe", 2: "Moderate Severity", 3: "Least Severe"})
            .astype("category"),
         Number_of_Vehicles=lambda df_: df_["Number_of_Vehicles"].astype("uint8"),
         Number_of_Casualties=lambda df_: df_["Number_of_Casualties"].astype("uint8"),
         Date=lambda df_: pd.to_datetime(df_["Date"]+" "+df_["Time"], format="%d/%m/%Y %H:%M"),
         Time=lambda df_: pd.to_datetime(df_["Time"], format="%H:%M").dt.time,
         Day_of_Week=lambda df_: df_["Day_of_Week"].astype("uint8"),
         Road_Type=lambda df_: df_["Road_Type"].astype("category"),
         Speed_Limit=lambda df_: df_["Speed_Limit"].astype("uint8"),
         Light_Conditions=lambda df_: df_["Light_Conditions"].astype("category"),
         Weather_Conditions=lambda df_: df_["Weather_Conditions"].astype("category"),
         Road_Surface_Conditions=lambda df_: df_["Road_Surface_Conditions"].astype("category"),
         Special_Conditions_at_Site=lambda df_: df_["Special_Conditions_at_Site"].astype("category"),
         Carriageway_Hazards=lambda df_: df_["Carriageway_Hazards"].astype("category"),
         Urban_or_Rural_Area=lambda df_: df_["Urban_or_Rural_Area"]
            .map({1: "Urban", 2: "Suburban", 3: "Rural"})
            .astype("category")
         )
      .drop(columns=drop_columns)
      .dropna()
      )
```

</details>

Creating this function allowed me to save a significant amount of memory which will speed up querying the data and allow for the correct methods to be used.

The format used is discussed in Matt Harrisons book "Effective Pandas". By chaining methods within my query it means that I'm able to comment out code as I go, so that I can build on the previous query and experiment as I do.

## Exploration

I've created multiple queries using Pandas and then often displayed the results in plots using Seaborn to visualize the results better.

While you can view the full notebook here: [[Notebook]](/UK_Accident.ipynb)

