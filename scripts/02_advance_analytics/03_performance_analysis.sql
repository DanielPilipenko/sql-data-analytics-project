/*
===============================================================================
Performance Analysis (Year-over-Year)
===============================================================================
Purpose:
    - Compare each product's yearly sales to its own average
      and to the previous year.

SQL Functions Used:
    - CTE, AVG() OVER (PARTITION BY ...), LAG()
===============================================================================
*/

WITH yearly_product_sales AS (
	-- one row per product per year
	SELECT
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY
		YEAR(f.order_date),
		p.product_name
)

SELECT
	order_year,
	product_name,
	current_sales,
	-- PARTITION BY product_name --> every product only compared to itself
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END AS avg_change,	-- close with END, followed by the column alias
	-- LAG needs ORDER BY inside OVER() --> defines what "previous row" means (here: previous year)
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;