/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - Consolidates key product metrics and behaviors into one view.

Highlights:
    1. Essential fields: product name, category, subcategory, cost.
    2. Segments by revenue: High-Performer / Mid-Range / Low-Performer.
    3. Product-level metrics: orders, sales, quantity, unique customers, lifespan.
    4. KPIs: recency, average order revenue, average monthly revenue.
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
	DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
	SELECT
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL	-- only valid sales dates
)

, product_aggregations AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: key metrics at product level
---------------------------------------------------------------------------*/
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
		MAX(order_date) AS last_sale_date,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		-- NULLIF(quantity, 0) --> division returns NULL instead of crashing
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
	FROM base_query
	GROUP BY
		product_key,
		product_name,
		category,
		subcategory,
		cost
)

/*---------------------------------------------------------------------------
3) Final Query: combine all product results into one output
---------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR) --> guard the divisor, keep the decimals
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(CAST(total_sales AS FLOAT) / total_orders, 2)
	END AS avg_order_revenue,
	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan, 2)
	END AS avg_monthly_revenue
FROM product_aggregations