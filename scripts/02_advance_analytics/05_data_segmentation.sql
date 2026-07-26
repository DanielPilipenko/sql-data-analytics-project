/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - Group data into meaningful categories for targeted insights.

SQL Functions Used:
    - CASE: defines the segmentation logic.
    - GROUP BY: groups data into the segments built by CASE.
===============================================================================
*/

/* Segment products into cost ranges and
   count how many products fall into each segment */
WITH product_segments AS (
	SELECT
		product_key,
		product_name,
		cost,
		-- CASE checks top-down, stops at the FIRST match
		-- --> cost = 500 lands in '100-500', not in '500-1000'
		CASE
			WHEN cost < 100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products
)
SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/* Group customers into three segments:
	- VIP:     >= 12 months history and spending > 5000
	- Regular: >= 12 months history and spending <= 5000
	- New:     lifespan < 12 months */
WITH customer_spending AS (
	SELECT
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
		ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
)
SELECT
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM (
	-- build the label first, group by it one level up
	SELECT
		customer_key,
		CASE
			WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_segment
	FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;