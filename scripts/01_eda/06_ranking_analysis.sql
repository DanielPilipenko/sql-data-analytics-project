/*
===============================================================================
06 - Ranking Analysis
===============================================================================
Purpose: Rank dimensions by measures (top/bottom performers).
Tables:  gold.fact_sales, gold.dim_products, gold.dim_customers
===============================================================================
*/

-- Which 5 products generate the highest revenue?
SELECT TOP 5
	SUM(f.sales_amount) AS total_revenue,
	p.product_name
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
	ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
	SUM(f.sales_amount) AS total_revenue,
	p.product_name
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
	ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- ROW_NUMBER() for more flexible ranking
SELECT *
FROM (
	SELECT
		SUM(f.sales_amount) AS total_revenue,
		p.product_name,
		ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON p.product_key = f.product_key
	GROUP BY p.product_name
) t
WHERE rank_products <= 5;

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
	SUM(s.sales_amount) AS total_revenue,
	c.customer_key,
	c.first_name,
	c.last_name
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
	ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- The 3 customers with the fewest orders placed
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders;