{{ config(
    materialized='table',
    tags=['gold', 'mart']
) }}

WITH product_sales AS (
    SELECT
        product_id,
        COUNT(DISTINCT order_id) AS times_ordered_count,
        SUM(quantity) AS total_units_sold,
        SUM(gross_revenue) AS total_gross_revenue,
        SUM(total_profit) AS total_gross_profit
    FROM {{ ref('fct_order_items') }}
    GROUP BY product_id
),

product_reviews AS (
    SELECT
        product_id,
        COUNT(review_id) AS review_count,
        ROUND(AVG(rating), 2) AS average_rating
    FROM {{ ref('brz_reviews') }}
    WHERE moderation_status = 'APPROVED'
    GROUP BY product_id
)

SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    p.brand,
    p.unit_price,
    p.profit_margin_pct,
    COALESCE(ps.times_ordered_count, 0) AS times_ordered_count,
    COALESCE(ps.total_units_sold, 0) AS total_units_sold,
    COALESCE(ps.total_gross_revenue, 0.00) AS total_gross_revenue,
    COALESCE(ps.total_gross_profit, 0.00) AS total_gross_profit,
    COALESCE(pr.review_count, 0) AS total_reviews_count,
    COALESCE(pr.average_rating, 0.00) AS average_customer_rating,
    p.stock_health_status
FROM {{ ref('dim_products') }} p 
LEFT JOIN product_sales ps ON p.product_id = ps.product_id 
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
