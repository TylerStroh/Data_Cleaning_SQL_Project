-- US Household Income Exploratory Data Analysis

SELECT *
FROM us_household_income_statistics;

SELECT *
FROM us_household_income;

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10
;
-- Texas has the most land by a large margin

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10
;
-- Michgan has tge most water by a large margin as well

-- Joining both tables together filtering out records that are not showing Mean data
SELECT *
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
;


SELECT u.State_Name, Type, `Primary`, Mean, Median
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
;

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 2 DESC
LIMIT 10
;
-- Mississippi has the lowest average income per household and Connecticut has the highest when looking at the States

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
AND u.State_Name = 'Maryland'
GROUP BY u.State_Name
;
-- Searching Maryland because that is where I currently live and the average household income here is $88k

SELECT Type, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 2 DESC
;

SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 3 DESC
;
-- Municipality has the highest avgerage income but it only has one entry Track having the most 
-- by far still with 29k still has an average of $68k. The only standout is community having an average of $19k but they also only have 17 entries

SELECT *
FROM us_household_income
WHERE Type = 'Community'
;
-- After looking into the community incomes I found all of them are in Puerto Rico

-- Looking into the Type's with more than 100 entries to help get better data insights
SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 3 DESC
;
-- Borough has the highest average household income with $68.6k while Town has the lowest with $55.1k

SELECT u.State_Name, City, ROUND(AVG(Mean),1)
FROM us_household_income AS u
INNER JOIN us_household_income_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name, City
ORDER BY 3 DESC
;
-- The City with the highest household income is Delta Junction in Alaska with $243k






