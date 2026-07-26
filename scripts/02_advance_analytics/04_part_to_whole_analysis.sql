/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - Which categories contribute how much to overall sales?

SQL Functions Used:
    - SUM() OVER (), CAST ... AS FLOAT
===============================================================================
*/

WITH category_sales AS (
	SELECT
		p.category,
		SUM(f.sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
	GROUP BY p.category
)

SELECT
	category,
	total_sales,
	-- OVER () empty --> one grand total for all rows
	SUM(total_sales) OVER () AS overall_sales,
	-- CAST to FLOAT first --> integer / integer cuts off the decimals
	ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- same thing with % sign --> CONCAT returns a string, display only,
-- no more sorting or calculating with it
WITH category_sales AS (
	SELECT
		p.category,
		SUM(f.sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
	GROUP BY p.category
)

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;