# Exploratory data analysis
-- start checking cleaned data

SELECT *
FROM layoffs_staging2;

-- check MAX laid off employees (12000: by Google, on 20 Jan 2023)
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

SELECT company, total_laid_off, `date`
FROM layoffs_staging2
WHERE total_laid_off = 12000;

-- check which companies have the highest layoffs. Top 3 (Amazon, Google, Meta)
SELECT company, SUM(total_laid_off) as sum_total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY sum_total_laid_off DESC;

-- check the entire duration of the data sample (11 Mar 2020 - 06 Mar 2023)
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- check which industry got the most layoffs (top 3: Consumer, Retail, Transportation)
SELECT industry, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY sum_total_laid_off DESC;

-- check which country got the most layoffs (top 3: United States, India, Netherlands)
SELECT country, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY sum_total_laid_off DESC;

-- check which year got the most layoffs (top 3: 2022, 2023, 2020 Note: 2023 only has 3 month data)
SELECT YEAR(`date`) AS year_data, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY year_data
ORDER BY sum_total_laid_off DESC;

-- Check Singapore's layoff per month with rolling total
SELECT country, SUBSTRING(`date`,1,7) as fiscal_month, SUM(total_laid_off) as sum_total_laid_off
FROM layoffs_staging2
WHERE country = 'Singapore'
GROUP BY country, fiscal_month;

WITH sg_rolling_total AS
(
SELECT country, SUBSTRING(`date`,1,7) as fiscal_month, SUM(total_laid_off) as sum_total_laid_off
FROM layoffs_staging2
WHERE country = 'Singapore'
GROUP BY country, fiscal_month
)
SELECT country, fiscal_month, sum_total_laid_off, SUM(sum_total_laid_off) OVER(ORDER BY fiscal_month) as rolling_total
FROM sg_rolling_total;

-- Get top 5 companies that has the highest number of layoffs of the year
WITH company_year (company, year_date, sum_total_laid_off) AS
(
SELECT company, year(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, year(`date`)
), company_ranking AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY year_date ORDER BY sum_total_laid_off DESC) AS Ranking
FROM company_year
WHERE year_date IS NOT NULL
)
SELECT *
FROM company_ranking
WHERE ranking <= 5
ORDER BY year_date;