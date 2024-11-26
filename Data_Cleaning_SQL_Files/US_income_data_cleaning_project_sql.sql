-- US Income Project (Data Cleaning)

-- Starting with statistics table
SELECT * 
FROM us_household_income_statistics;

-- A column name imported incorrectly so editing it here
ALTER TABLE us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`;

-- Start looking for duplicates
SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id)>1
;
-- 0 duplicates found





-- Start cleaning second table
SELECT * 
FROM us_household_income;

-- Start looking for duplicates
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id)>1
;
-- Found 6 duplicates

-- removing duplicate rows
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

SELECT DISTINCT State_Name
FROM us_household_income
GROUP BY State_Name
;
-- Found some mispelled state names

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;
-- Fixed mispelled state names

SELECT DISTINCT State_ab
FROM us_household_income
GROUP BY State_ab
;
-- State Abv looks good

SELECT *
FROM us_household_income
WHERE Place = ''
;
-- Found one missing place in Data

SELECT *
FROM us_household_income
WHERE County = 'Autauga County'
;

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;
-- Updated missing place entry

SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type
;
-- found two typos in type

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

UPDATE us_household_income
SET `Type` = 'CDP'
WHERE `Type` = 'CPD'
;
-- updated type typos

SELECT ALand, AWater
FROM us_household_income
WHERE (AWater = 0 OR AWater = '' OR AWater IS NULL)
AND (ALand = 0 OR ALand = '' OR ALand IS NULL)

-- no entries that have nothing listed for Land and Water so nothing to update







