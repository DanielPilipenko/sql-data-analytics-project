/*
===============================================================================
01 - Database Exploration
===============================================================================
Purpose: Explore the structure of the database - tables and columns.
Tables:  INFORMATION_SCHEMA.TABLES, INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- List all tables in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Inspect the columns of a specific table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';