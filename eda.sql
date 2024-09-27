select *
from layoffs_staging2;

-- What is the range of the total amount laid off for this dataset
select MAX(total_laid_off), MAX(percentage_laid_off)
from layoffs_staging2;

-- Which companies laid off their entire workforce
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions DESC;

-- Total layoffs by company
select company, SUM(total_laid_off)
from layoffs_staging2
group by company
order by 2 DESC;

-- What is the range of the dates for this dataset
select MIN(`date`), MAX(`date`)
from layoffs_staging2;

-- What industry had the most layoffs
select industry, SUM(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- Which country had the most layoffs
select country, SUM(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- How many layoffs were there each year
select YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
group by YEAR(`date`)
order by 1 DESC;

-- How many layoffs for each stage
select stage, SUM(total_laid_off)
from layoffs_staging2
group by stage
order by 1 DESC;

-- The average percentage laid off from each company
select company, AVG(percentage_laid_off)
from layoffs_staging2
group by company
order by 1 DESC;

-- Get total layoffs for specific months in each year
select SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
from layoffs_staging2
where SUBSTRING(`date`, 1, 7) is not null
group by `MONTH`
order by 1 ASC;

-- Get the rolling total layoffs
with Rolling_Total as
(
select SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) as total_off
from layoffs_staging2
where SUBSTRING(`date`, 1, 7) is not null
group by `MONTH`
order by 1 ASC
)
select `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) as rolling_total
from Rolling_Total;

select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
order by 3 DESC;

-- Which companies laid off the most amount of employees ordered by year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
group by company, YEAR(`date`)
), Company_Year_Rank AS
(
select *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) as Ranking
from Company_Year
where years IS NOT NULL
)
select *
from Company_Year_Rank
where Ranking <= 5;