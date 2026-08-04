{{ config(
    materialized='view',
    tags=['staging', 'customer_analytics']
) }}

WITH customer_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS most_recent_order_date,
        COUNT(order_id) AS total_orders_placed,
        SUM(CASE WHEN status = 'DELIVERED' THEN 1 ELSE 0 END) AS total_orders_delivered,
        SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS total_orders_cancelled,
        SUM(CASE WHEN status = 'RETURNED' THEN 1 ELSE 0 END) AS total_orders_returned,
        SUM(CASE WHEN status NOT IN ('CANCELLED') THEN total_amount ELSE 0 END) AS lifetime_gross_spend
    FROM {{ ref('slv_orders_merge') }}
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.country_code,
    c.loyalty_tier,
    co.first_order_date,
    co.most_recent_order_date,
    DATEDIFF(CURRENT_DATE(), co.most_recent_order_date) AS days_since_last_order,
    COALESCE(co.total_orders_placed, 0)     AS total_orders_placed,
    COALESCE(co.total_orders_delivered, 0)  AS total_orders_delivered,
    COALESCE(co.total_orders_cancelled, 0)  AS total_orders_cancelled,
    COALESCE(co.total_orders_returned, 0)   AS total_orders_returned,
    CAST(COALESCE(co.lifetime_gross_spend, 0) AS DECIMAL(12,2)) AS lifetime_gross_spend,
    ROUND(co.lifetime_gross_spend / NULLIF(co.total_orders_placed, 0), 2) AS average_order_value,
    CASE 
        WHEN co.total_orders_placed IS NULL THEN 'NEVER_ORDERED'
        WHEN DATEDIFF(CURRENT_DATE(), co.most_recent_order_date) <= 60 THEN 'ACTIVE'
        WHEN DATEDIFF(CURRENT_DATE(), co.most_recent_order_date) <= 180 THEN 'AT_RISK'
        ELSE 'CHURNED'
    END AS customer_recency_status
FROM {{ ref('slv_customers') }} c
LEFT JOIN customer_orders co ON c.customer_id = co.customer_id