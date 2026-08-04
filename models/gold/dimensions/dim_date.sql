{{ config(
    materialized='table',
    tags=['gold', 'dimensions']
) }}

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2023-01-01' as date)",
        end_date="cast('2026-12-31' as date)"
    ) }}
)

SELECT
    CAST(date_day as DATE) AS date_key,
    YEAR(date_day) AS year_number,
    MONTH(date_day) AS month_number,
    MONTHNAME(date_day) AS month_name,
    QUARTER(date_day) AS quarter_number,
    WEEKOFYEAR(date_day) AS week_number,
    DAYOFWEEK(date_day) AS day_of_week_number,
    DAYNAME(date_day) AS day_of_week_name,
    CASE WHEN DAYOFWEEK(date_day) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend,
    {{ get_fiscal_year('date_day') }} AS fiscal_year
FROM date_spine