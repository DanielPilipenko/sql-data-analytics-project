/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - Consolidates key customer metrics and behaviors into one view.

Highlights:
    1. Essential fields: names, ages, transaction details.
    2. Segments: VIP / Regular / New + age groups.
    3. Customer-level metrics: orders, sales, quantity, products, lifespan.
    4. KPIs: recency, average order value, average monthly spend.
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
	DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: core columns from the tables
---------------------------------------------------------------------------*/
	SELECT
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		DATEDIFF(year, c.birthdate, GETDATE()) AS age
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
		ON c.customer_key = f.customer_key
	WHERE f.order_date IS NOT NULL
)

, customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: key metrics at customer level
---------------------------------------------------------------------------*/
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM base_query
	GROUP BY
		customer_key,
		customer_number,
		customer_name,
		age
)

/*---------------------------------------------------------------------------
3) Final Query: combine everything into the report output
---------------------------------------------------------------------------*/
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,
	CASE
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- compute average order value (AOV)
	-- guard the divisor against zero, CAST FLOAT --> keep the decimals
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(CAST(total_sales AS FLOAT) / total_orders, 2)
	END AS avg_order_value,
	-- compute average monthly spend
	-- lifespan 0 --> only one active month, avoid division by zero
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan, 2)
	END AS avg_monthly_spend
FROM customer_aggregation