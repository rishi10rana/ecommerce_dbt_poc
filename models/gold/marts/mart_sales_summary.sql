{{ config(
    materialized='table',
    tags=['gold', 'mart']
) }}

SELECT
    f.order_date_key AS sales_date,
    d.year_number,
    d.month_name,
    d.quarter_number,
    c.global_region,
    c.country_name,
    f.order_channel,
    f.order_status,
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(DISTINCT f.customer_id) AS active_purchasing_customers,
    SUM(f.line_items_count) AS total_line_items_sold,
    SUM(f.total_units_sold) AS total_units_sold,
    CAST(SUM(f.gross_order_revenue) AS DECIMAL(14,2)) AS gross_revenue,
    CAST(SUM(f.discount_amount)     AS DECIMAL(14,2)) AS total_discounts_given,
    CAST(SUM(f.total_order_profit)  AS DECIMAL(14,2)) AS total_net_profit,
    ROUND(SUM(f.gross_order_revenue) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS average_order_value
FROM {{ ref('fct_orders') }} f
JOIN {{ ref('dim_customers') }} c ON f.customer_id = c.customer_id 
JOIN {{ ref('dim_date') }} d ON f.order_date_key = d.date_key
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8