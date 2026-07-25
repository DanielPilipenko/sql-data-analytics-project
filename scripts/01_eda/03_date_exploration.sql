/*
===============================================================================
03 - Date Exploration
===============================================================================
Purpose: Understand the time span of the data.
Tables:  gold.fact_sales, gold.dim_customers
===============================================================================
*/

-- Find the date of the first and last order and the covered time span
SELECT
	MIN(order_date) AS min_date,
	MAX(order_date) AS max_date,
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS sales_years_total
FROM gold.fact_sales;

-- Find the oldest and youngest customer
SELECT
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;