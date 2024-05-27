--Changing Data Type of total_laid_off column
		ALTER TABLE layoffs_stg2
		    ALTER COLUMN total_laid_off TYPE INT
		    USING total_laid_off::INTEGER;
		
		SELECT total_laid_off
		FROM layoffs_stg2
		WHERE total_laid_off !~ '^\d+$' AND total_laid_off IS NOT NULL;
		
		UPDATE layoffs_stg2
		SET total_laid_off = NULL
		WHERE total_laid_off !~ '^\d+$';

-- Changing data Type of Funds_raised_millions

SELECT funds_raised_millions
FROM layoffs_stg2
WHERE funds_raised_millions != TRIM(funds_raised_millions);


Select funds_raised_millions 
From layoffs_stg2
where funds_raised_millions !~ '^[0-9]+$' And funds_raised_millions is Not Null

UPDATE layoffs_stg2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL';

Alter Table layoffs_stg2
	Alter column funds_raised_millions TYPE INT
	USING funds_raised_millions::INTEGER;
	
-- EDA Exploratory Data Analysis
Select *
From layoffs_stg2
Where percentage_laid_off = '1'
Order By funds_raised_millions DESC;

Select (total_laid_off)
From layoffs_stg2
Order By total_laid_off DESC

--1 Query
	--Checking Layoffs per company
Select Count(*), date, company, SUM(total_laid_off) as emp_no
From layoffs_stg2
Group By company, date
Having SUM(total_laid_off) > 1
Order BY emp_no DEsc

	--Checking Layoffs per industry type
Select Count(*), industry, SUM(total_laid_off) as emp_no
From layoffs_stg2
Group By industry
Having SUM(total_laid_off) > 1
Order BY emp_no DEsc

	--Checking Layoffs per country

Select Count(*), country, SUM(total_laid_off) as emp_no
From layoffs_stg2
Group By country
Having SUM(total_laid_off) > 1
Order BY emp_no DEsc

	--Checking Layoffs per year
	
Select Extract(Year From date) as Years, Sum(total_laid_off) as emp_no
From layoffs_stg2
Group by Years
Order by emp_no DESC

	--Checking layoffs per stage
Select Count(*), stage, SUM(total_laid_off) as emp_no
From layoffs_stg2
Group By stage
Having SUM(total_laid_off) > 1
Order BY emp_no DEsc
	
	--Checking Layoffs per year

Select Extract(YEAR From date) as Month, Sum(total_laid_off) as emp_no
From layoffs_stg2
Group by Month
Order by emp_no DESC

	--Checking Layoffs per month
	
Select Extract(Month From date) as Month, Sum(total_laid_off) as emp_no
From layoffs_stg2
Group by Month
Order by emp_no DESC

	--Checking Layoffs per Year_month
	
Select to_char(date, 'YYYY-MM') as Month, Sum(total_laid_off) as emp_no
From layoffs_stg2
Group by Month
Order by emp_no DESC

	--Calculating the rolling sum (means from start date we will add every month)

With Rolling_Total AS (
		Select to_char(date, 'YYYY-MM') as Month, Sum(total_laid_off) as emp_no
		From layoffs_stg2
		Group by Month
		Order by emp_no DESC
	)
Select 
	Month,
	emp_no as laid_off_per_month,
	SUM(Emp_no) OVER(Order By Month) as roll_total
From Rolling_Total

	--Checking Layoffs per country per year

Select Extract(YEAR From date) As Year, company, SUM(total_laid_off) as emp_no
From layoffs_stg2
Group By company, Year
Having SUM(total_laid_off) > 1
Order BY emp_no DEsc

	--Checking the layoff of each year for each company and giving ranks 

With Company_year AS (
	Select Extract(YEAR From date) As Year, company, SUM(total_laid_off) as emp_no
	From layoffs_stg2
	Group By company, Year
	Having SUM(total_laid_off) > 1
)
SELECT *, DENSE_RANK() OVER(Partition By Year Order By emp_no Desc) As Ranking
From Company_year
Order By Ranking 

	---Checkin the layoffs of each year for each company for 5 ranks
With Company_year AS (
	Select Extract(YEAR From date) As Year, company, SUM(total_laid_off) as emp_no
	From layoffs_stg2
	Group By company, Year
	Having SUM(total_laid_off) > 1
), 
Company_Year_Ranks AS (
	SELECT *, DENSE_RANK() OVER(Partition By Year Order By emp_no Desc) As Ranking
	From Company_year
	Order By Ranking 
)

Select * from Company_Year_Ranks
Where Ranking <= 5
Order By ranking, Year 

	
--Checking the date range 
Select Min(date), Max(date)
From layoffs_stg2

Select * from layoffs_stg2


