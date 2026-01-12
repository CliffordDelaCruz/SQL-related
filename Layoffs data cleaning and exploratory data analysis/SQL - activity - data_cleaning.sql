-- Data Cleaning
SELECT *
FROM layoffs;

## Steps in data cleaning
## 1. Remove duplicates
## 2. Standardize the data
## 3. Identify NULL / blank values
## 4. Remove any Columns that are irrelevant

-- Create a duplicate of the table to serve as a staging table
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- 1. Remove duplicates - check if there are instance of line records that has more than 1 instace
## Use ROW_NUMBER() OVER() to get the data that has row > 1

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte as
(
	SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging	
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Check the duplicate data
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create a table and include row_num
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- delete data with row_num > 1
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Check the duplicate data
SELECT *
FROM layoffs_staging2
WHERE company = 'Casper';

-- 2. Perform standardization
## remove any whitespace

SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2 SET
company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

# Standardize Crypto
SELECT *
FROM  layoffs_staging2
WHERE industry LIKE'Crypto%';

UPDATE layoffs_staging2 SET
industry = 'Crypto'
WHERE industry LIKE'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 SET
country = 'United States'
WHERE country LIKE'United States%';

-- Check date column and convert it to actual date
SHOW COLUMNS from layoffs_staging2
WHERE field = 'date';

-- use str_to_date function to convert the text to date
SELECT `date`, str_to_date(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2 SET 
`date`= str_to_date(`date`,'%m/%d/%Y');

-- after updating the value to a date format, we can now alter the table for the column
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT `date`
FROM  layoffs_staging2;

SHOW COLUMNS from layoffs_staging2
WHERE field = 'date';

-- 3. Take action on NULLS and Blanks
## [variable] IS NULL to identify

-- Check industry for blanks or NULLS
SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE (industry = '' OR industry IS NULL);

-- sample check: 'Airbnb' - it showss 2 records - one with industry and the other blank
SELECT *
FROM layoffs_staging2
WHERE company like 'Bally%';

-- do a quick checking on which ones have this same scenario
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND	t1.location = t2.location
WHERE (t1.industry = '' OR t1.industry IS NULL)
AND (t2.industry IS NOT NULL);

-- Set the Blank field tto NULL
UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry='';

-- Proceed to update the industry column
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND	t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Check columns total_laid_off and percentage_laid_off are BOTH NULL. if they are, delete those columns
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- DROP column row_num
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
