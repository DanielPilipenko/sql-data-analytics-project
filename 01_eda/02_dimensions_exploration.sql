/*
===============================================================================
02 - Dimensions Exploration
===============================================================================
Purpose: Identify the unique values of each dimension.
Tables:  gold.dim_customers, gold.dim_products
===============================================================================
*/

-- Explore all countries our customers come from
SELECT DISTINCT country
FROM gold.dim_customers;

-- Explore all product categories, subcategories and products
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;