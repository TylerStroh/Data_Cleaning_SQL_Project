# Data_Cleaning_SQL_Project
 
This project was created to help give better insight on the data cleaning process in SQL to help remove duplicates, fix spelling errors, and more!
[Check out my work here](Data_Cleaning_SQL_Files)

## Introduction 

In this project I looked at the statistics for the household income in the US for each county. This project is focused on data cleaning and the steps required to take a dirty data set and make it clean for analysis.

## Background

Looking at the data I was immediately able to spot inconsistencies and blank data. I use two different methods to clean the data one is more standard and focuses on individual issues to fix as I find them and then the other method uses events and automation setting up a real-world example if this dataset were to be continually updated then it would get cleaned on its own automatically. After cleaning I then go into some basic analysis to make sure everything cleaned correctly.

## Tools Used

- SQL: The language used to run the queries for cleaning and analysis.
- MySQL: Where I saved my code and executed the SQL queries.
- Git & GitHub: Used for version control and sharing my SQL queries and analysis.

## Data Cleaning

After importing the data, I noticed that one of the column names did not come in correctly.
```
ALTER TABLE us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`;
```
Changing this column to "id" allows that column to be called for more easily in the queries.

The first step I took to clean the data was to search for duplicates.
```
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id)>1
;
```
When running this query I found this data did have some duplicates so the next step would be to remove the duplicates.
```
DELETE FROM us_household_income
WHERE row_id IN(
	SELECT row_id
	FROM (
		SELECT row_id, id, 
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		FROM us_household_income
	) duplicates
WHERE row_num >1)
;
```
This query removed the duplicates found in this table so now if we rerun the query beforehand we find no results.

The next step I took to clean the data was to search for spelling mistakes.
```
SELECT DISTINCT State_Name
FROM us_household_income
GROUP BY State_Name
;

SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type
;
```
These two queries found spelling mistakes that would have caused analysis to be inaccurate.

```
UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

UPDATE us_household_income
SET `Type` = 'CDP'
WHERE `Type` = 'CPD'
;
```
These queries fized the spelling mistakes that were found above.

Finally the last step I took to cleaning the data was to search for blank and missing data.
```
SELECT *
FROM us_household_income
WHERE Place = ''
;
```
Throughout the data the only missing data I found was one of the place entries. 

```
SELECT *
FROM us_household_income
WHERE County = 'Autauga County'
;

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;
```
Since there was other information I was able to determine what needed to be entered. This query above demonstrates the proccess taken to find and update the missing info.

## Automated Data Cleaning

Looking at this data it looks like it is regularly being updated so I wanted to clean the data again but this time set it up to run automatically when new data is added.

The automation process starts off by creating a procedure that includes the data cleaning steps that need to be executed.
```
DELIMITER $$
DROP PROCEDURE IF EXISTS Copy_and_Clean_Data;
CREATE PROCEDURE Copy_and_Clean_Data()
BEGIN
-- creating new table to make edits on
	CREATE TABLE IF NOT EXISTS `us_household_income_cleaned` (
	  `row_id` int DEFAULT NULL,
	  `id` int DEFAULT NULL,
	  `State_Code` int DEFAULT NULL,
	  `State_Name` text,
	  `State_ab` text,
	  `County` text,
	  `City` text,
	  `Place` text,
	  `Type` text,
	  `Primary` text,
	  `Zip_Code` int DEFAULT NULL,
	  `Area_Code` int DEFAULT NULL,
	  `ALand` int DEFAULT NULL,
	  `AWater` int DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL,
	  `TimeStamp` TIMESTAMP DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    
-- Copy data to new table
    INSERT INTO us_household_income_cleaned
    SELECT *, CURRENT_TIMESTAMP
	FROM raw_us_household_income;

-- Data cleaning steps
-- Start removing duplicates

	DELETE FROM us_household_income_cleaned 
	WHERE 
		row_id IN (
		SELECT row_id
	FROM (
		SELECT row_id, id,
			ROW_NUMBER() OVER (
				PARTITION BY id, `TimeStamp`
				ORDER BY id, `TimeStamp`) AS row_num
		FROM 
			us_household_income_cleaned
	) duplicates
	WHERE 
		row_num > 1
	);

-- Fixing some data quality issues by fixing typos and general standardization
	UPDATE us_household_income_cleaned
	SET State_Name = 'Georgia'
	WHERE State_Name = 'georia';

	UPDATE us_household_income_cleaned
	SET County = UPPER(County);

	UPDATE us_household_income_cleaned
	SET City = UPPER(City);

	UPDATE us_household_income_cleaned
	SET Place = UPPER(Place);

	UPDATE us_household_income_cleaned
	SET State_Name = UPPER(State_Name);

	UPDATE us_household_income_cleaned
	SET `Type` = 'CDP'
	WHERE `Type` = 'CPD';

	UPDATE us_household_income_cleaned
	SET `Type` = 'Borough'
	WHERE `Type` = 'Boroughs';
  
END $$
DELIMITER ;
```
Starting off the procedure with making a new separate table to make sure raw data is not messed with while also adding a timestamp column so we could see when the data most recently got cleaned.

Then we remove the duplicates again and after removing duplicates we remove the spelling errors we found previously.


Now that I have the procedure made I created an event to run on a schedule to continuously clean the data and when this event runs it inputs the date and time into the new timestamp column to let us know when the event last ran.
```
DROP EVENT run_data_cleaning;
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 30 DAY
    DO CALL Copy_and_Clean_Data();
```
This event runs the procedure every 30 days to ensure the data is consistently clean.

For the project I set the event originally to 30 seconds to make sure it was working and looking at the data before and after the event was able to clean the data and set up a timestamp of when it was last cleaned.

## Exploratory Analysis

Now that the data is cleaned I took some time to explore the data to see what I could find.

I was looking at the average income per state. First I looked at the states with the lowest and the highest average incomes and then I filtered it to look at Maryland since that is where I live.
```
SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
AND u.State_Name = 'Maryland'
GROUP BY u.State_Name
```
With this I was able to find that the average household income in Maryland is $88k

In this query I am also making sure to filter out all the entries that are not showing data so it does not affect the results. 

After finding the information on Maryland I also looked at the area type like if it was a city, town, track, etc. to see if that made a difference in average income in the US.
```
SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 3 DESC
;
```

With this query I was able to find that the area type does not have a drastic impact with Borough having the highest average with $68.5k and Town having the lowest with $55.1k.

When running the query originally I noticed way more drastic findings so I added the count and realized some types barely had any entries so I updated it to have area types that showed up more than 100 times.

This is all the analysis done, this project was primarily focused on the cleaning side of Data Analysis I just wanted a few examples to make sure the data was cleaned.

If you are interested in a project focused on SQL analysis [Check out my work here](Salary-Dashboard-Project)

## What I Learned

Throughout this SQL data cleaning project I gained knowledge on many SQL functions:

- I learned how to alter tables by using functions such as ALTER TABLE, DELETE FROM, and UPDATE. These three functions allowed me to do the data cleaning that was necessary for this data set such as updating column names, removing duplicates, and fixing spelling errors.
- I also learned how to utilize procedures and events to help automate the data cleaning process. I was able to create a procedure and event to run on a set schedule for when future data would be added.

## Conclusion

Throughout this project I learned to utilize data cleaning functions in SQL to prepare data for analysis. These are great tools to learn because when looking at data sets there is high likelihood that the data is not formatted the same throughout the numerous rows and now in my future role in Data Analytics if I run into a scenario where data cleaning is necessary, I will be prepared. 


























