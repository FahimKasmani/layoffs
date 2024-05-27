# Introduction 
This Project 📊 outlines the steps taken fro the Exploratory Data Analysis of company layoffs dataset, using SQL queries to explore various aspects of the data. The focus 🔎 is on transforming data types, ensuring data quality, and performing exploratory data analysis (EDA) to derive meaningful insights.

SQL queries? Check them out here: [Project_Queries](/Layoffs)

# Background
- The layoffs data includes information on companies, industries, dates of layoffs, the number of employees laid off, and funds raised by companies. To make the data suitable for analysis, we need to ensure that all columns have the correct data types and that any inconsistencies are addressed. After cleaning the data, various analytical queries are executed to understand the patterns and trends in layoffs across different dimensions such as company, industry, country, and time.




# Tools I Used

- **SQL**: The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL**: The chosen database management system, ideal for handling the job posting data.
- **Git & GitHub**: Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.

# Analysis
### 1. Changing Data Type of total_laid_off
The total_laid_off column was converted from a string to an integer. Non-numeric values were identified and set to NULL to avoid errors during the conversion.
```
-- Convert `total_laid_off` to integer
ALTER TABLE layoffs_stg2
    ALTER COLUMN total_laid_off TYPE INT
    USING total_laid_off::INTEGER;

-- Find rows with non-numeric `total_laid_off` values
SELECT total_laid_off
FROM layoffs_stg2
WHERE total_laid_off !~ '^\d+$' AND total_laid_off IS NOT NULL;

-- Set non-numeric `total_laid_off` values to NULL
UPDATE layoffs_stg2
SET total_laid_off = NULL
WHERE total_laid_off !~ '^\d+$';


```
### 2. Changing Data Type of funds_raised_millions
The funds_raised_millions column was converted from a string to an integer. Non-numeric values were identified and set to NULL to avoid errors during the conversion.

```
-- Find rows with non-trimmed `funds_raised_millions` values
SELECT funds_raised_millions
FROM layoffs_stg2
WHERE funds_raised_millions != TRIM(funds_raised_millions);

-- Find rows with non-numeric `funds_raised_millions` values
SELECT funds_raised_millions 
FROM layoffs_stg2
WHERE funds_raised_millions !~ '^[0-9]+$' AND funds_raised_millions IS NOT NULL;

-- Set non-numeric `funds_raised_millions` values to NULL
UPDATE layoffs_stg2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL';

-- Convert `funds_raised_millions` to integer
ALTER TABLE layoffs_stg2
    ALTER COLUMN funds_raised_millions TYPE INT
    USING funds_raised_millions::INTEGER;


```
## Exploratory Data Analysis (EDA)

### 1. Layoffs per Company

Counts the number of layoffs per company on each date and sums the total number of employees laid off.

```
SELECT COUNT(*), date, company, SUM(total_laid_off) AS emp_no
FROM layoffs_stg2
GROUP BY company, date
HAVING SUM(total_laid_off) > 1
ORDER BY emp_no DESC;


```

### 2. Layoffs per Industry Type
Counts the number of layoffs per industry and sums the total number of employees laid off.

```
SELECT COUNT(*), industry, SUM(total_laid_off) AS emp_no
FROM layoffs_stg2
GROUP BY industry
HAVING SUM(total_laid_off) > 1
ORDER BY emp_no DESC;


```
### 3. Layoffs per Country
Counts the number of layoffs per country and sums the total number of employees laid off.

```
SELECT COUNT(*), country, SUM(total_laid_off) AS emp_no
FROM layoffs_stg2
GROUP BY country
HAVING SUM(total_laid_off) > 1
ORDER BY emp_no DESC;


```

### 4. Layoffs per Year
Sums the total number of employees laid off per year.

```
SELECT EXTRACT(YEAR FROM date) AS Years, SUM(total_laid_off) AS emp_no
FROM layoffs_stg2
GROUP BY Years
ORDER BY emp_no DESC;

```

### 5. Layoffs per Stage
Counts the number of layoffs per stage and sums the total number of employees laid off.

```
SELECT COUNT(*), stage, SUM(total_laid_off) AS emp_no
FROM layoffs_stg2
GROUP BY stage
HAVING SUM(total_laid_off) > 1
ORDER BY emp_no DESC;

```

### 6. Layoffs per Month
Sums the total number of employees laid off per month.

```
SELECT EXTRACT(MONTH FROM date) AS Month, SUM(total_laid_off) AS emp_no
FROM layoffs_stg2
GROUP BY Month
ORDER BY emp_no DESC;

```

### 7. Layoffs per Year-Month
Sums the total number of employees laid off per year-month.

```
SELECT TO_CHAR(date, 'YYYY-MM') AS Month, SUM(total_laid_off) AS emp_no
FROM layoffs_stg2
GROUP BY Month
ORDER BY emp_no DESC;
```
### 8. Rolling Sum of Layoffs
Calculates the rolling sum of layoffs, providing the cumulative total of employees laid off from the start to each month.

```
WITH Rolling_Total AS (
    SELECT TO_CHAR(date, 'YYYY-MM') AS Month, SUM(total_laid_off) AS emp_no
    FROM layoffs_stg2
    GROUP BY Month
    ORDER BY emp_no DESC
)
SELECT 
    Month,
    emp_no AS laid_off_per_month,
    SUM(emp_no) OVER(ORDER BY Month) AS roll_total
FROM Rolling_Total;

```

### 9. Layoffs per Country per Year
Sums the total number of employees laid off per company per year.

```
SELECT EXTRACT(YEAR FROM date) AS Year, company, SUM(total_laid_off) AS emp_no
FROM layoffs_stg2
GROUP BY company, Year
HAVING SUM(total_laid_off) > 1
ORDER BY emp_no DESC;

```

### 10. Ranking Layoffs for Each Company by Year
Ranks companies by the number of employees laid off each year.

```
WITH Company_year AS (
    SELECT EXTRACT(YEAR FROM date) AS Year, company, SUM(total_laid_off) AS emp_no
    FROM layoffs_stg2
    GROUP BY company, Year
    HAVING SUM(total_laid_off) > 1
)
SELECT *, DENSE_RANK() OVER(PARTITION BY Year ORDER BY emp_no DESC) AS Ranking
FROM Company_year
ORDER BY Ranking;

```

### 11. Top 5 Layoffs per Year for Each Company
Retrieves the top 5 companies with the highest number of layoffs for each year.

```
WITH Company_year AS (
    SELECT EXTRACT(YEAR FROM date) AS Year, company, SUM(total_laid_off) AS emp_no
    FROM layoffs_stg2
    GROUP BY company, Year
    HAVING SUM(total_laid_off) > 1
), 
Company_Year_Ranks AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY Year ORDER BY emp_no DESC) AS Ranking
    FROM Company_year
    ORDER BY Ranking 
)
SELECT * 
FROM Company_Year_Ranks
WHERE Ranking <= 5
ORDER BY Ranking, Year;

```

# What I Learned
- The importance of data cleaning before performing any analysis to ensure data accuracy.
- Techniques to handle non-numeric values and convert data types in SQL.
- How to use SQL for various types of exploratory data analysis, including aggregations and ranking.
- The significance of understanding trends and patterns in data to derive actionable insights.

# Conclusion
- Through Exploratory Data Analysis, I found that the highest number of layoffs occurred in 2022, with over 150,000 individuals losing their jobs.

- The year with the fewest layoffs was 2021, with 15,823 individuals affected.

- The United States recorded the highest number of layoffs, with over 255,000 people losing their jobs, followed by India and the Netherlands.

- Over 62,000 employees were laid off by Amazon, Google, Meta, Philips, Salesforce, and Microsoft combined.