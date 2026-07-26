/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - Running totals and running averages over time.

SQL Functions Used:
    - SUM() OVER (...), AVG() OVER (...)
    - pattern: aggregate first, window second
===============================================================================
*/

/*
===============================================================================
WINDOW FUNCTIONS - When to use PARTITION BY (and when not)
===============================================================================
Decision rule: Look for a "per X" in the task.
  "per year / per customer / per category"  -> PARTITION BY X
  "overall / across everything"             -> no PARTITION BY

The OVER() clause has two independent switches - PARTITION BY and ORDER BY:

  1) OVER ()
     One grand total, attached to every row.
     e.g. to calculate "share of total sales" later on.

  2) OVER (PARTITION BY category)
     One value per group, attached to every row - nothing is running.
     e.g. category total next to each product.

  3) OVER (ORDER BY order_date)
     Running total across ALL rows - never resets.
     e.g. cumulative sales over the whole timeline.

  4) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date)
     Running total that RESTARTS at every partition wall.
     e.g. Year-to-Date (YTD): resets to the monthly value every January.

Mental model: PARTITION BY puts up walls in the room - the calculation
only ever sees its own compartment. A running total starts from zero
behind every wall.
===============================================================================
*/

-- total sales per month + running total over the whole timeline
-- inner GROUP BY sets the grain (one row per month), window runs on top
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
	SELECT
		DATETRUNC(month, order_date) AS order_date,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
) t;

-- PARTITION BY YEAR --> restarts every january = YTD
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_sales
FROM (
	SELECT
		DATETRUNC(month, order_date) AS order_date,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
) t;

-- adding moving AVG in the inner function first
-- this AVG is expanding (start --> current row); a real 3-month window would need
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
	SELECT
		DATETRUNC(month, order_date) AS order_date,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
) t;