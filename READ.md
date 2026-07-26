# SQL Data Analytics Project

Analytics layer on top of my [sql-data-warehouse-project](https://github.com/DanielPilipenko/sql-data-warehouse-project) — exploratory data analysis (EDA) and advanced analytics written in T-SQL against the gold layer (star schema).

## Project Structure

```
scripts/
├── 01_eda/                          -- Exploratory Data Analysis
│   ├── 01_database_exploration.sql
│   ├── 02_dimensions_exploration.sql
│   ├── 03_date_exploration.sql
│   ├── 04_measures_exploration.sql
│   ├── 05_magnitude_analysis.sql
│   └── 06_ranking_analysis.sql
└── 02_advanced/                     -- Advanced Analytics
    ├── 01_change_over_time_analytics.sql
    ├── 02_cumulative_analysis.sql
    ├── 03_performance_analysis.sql
    ├── 04_part_to_whole_analysis.sql
    ├── 05_data_segmentation.sql
    ├── 06_report_customers.sql
    └── 07_report_products.sql
```

## Analyses

**EDA** — getting to know the data: database & dimension exploration, date ranges, key measures, magnitude comparisons and top/bottom rankings.

**Advanced Analytics** — answering business questions:
- **Change over time** — trends by year and month (`YEAR`, `DATETRUNC`, `FORMAT`)
- **Cumulative analysis** — running totals and Year-to-Date with window functions
- **Performance analysis** — Year-over-Year comparison per product (`LAG`, `AVG OVER`)
- **Part-to-whole** — category share of total sales (`SUM() OVER ()`)
- **Segmentation** — cost ranges and customer segments (VIP / Regular / New)

## Final Products

Two report views ready for BI consumption:

- **`gold.report_customers`** — customer segments, age groups, recency, average order value, average monthly spend
- **`gold.report_products`** — product segments, recency, average order revenue, average monthly revenue

## How to Use

1. Build the warehouse first: run the ETL from [sql-data-warehouse-project](https://github.com/DanielPilipenko/sql-data-warehouse-project) (Bronze → Silver → Gold).
2. Run the scripts in this repository against the resulting database.
3. Query the two report views for ready-to-use KPIs.

## Acknowledgments

Based on the SQL course by [Baraa Khatib Salkini](https://www.youtube.com/@DataWithBaraa) (Data With Baraa). All scripts were written along with the course, then debugged, refactored and documented independently.