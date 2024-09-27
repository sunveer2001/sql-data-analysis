-- Create Copy of Table to Edit

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- Remove Duplicates

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;


-- Standardize Data

UPDATE layoffs_staging2
set company = TRIM(company);

select *
from layoffs_staging2
where industry like 'Crypto%';

UPDATE layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

UPDATE layoffs_staging2
set country = TRIM(TRAILING '.' FROM country)
where country like 'United States%';

UPDATE layoffs_staging2
set date = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;


-- Check Null/Blank Values

SELECT * 
from layoffs_staging2
where total_laid_off IS NULL
and percentage_laid_off IS NULL;

select * 
from layoffs_staging2
where company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = NULL
where industry = '';

select * 
from layoffs_staging2 t1
join layoffs_staging2 t2 on t1.company=t2.company and t1.location = t2.location
where t1.industry IS NULL and t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
join layoffs_staging2 t2 on t1.company=t2.company and t1.location = t2.location
set t1.industry = t2.industry
where t1.industry IS NULL and t2.industry IS NOT NULL;

DELETE
from layoffs_staging2
where total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT 
    *
FROM
    layoffs_staging2;


-- Remove Unnecessary Columns

alter table layoffs_staging2
drop column row_num;
