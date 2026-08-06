{{ config(
    materialized='table',
    file_format='delta',
    tags=['layer_gold', 'mart', 'daily']
) }}

WITH daily_orders AS (
    SELECT
        DATE(order_date) as order_day,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) as unique_customers,
        SUM(total_amount) AS gross_revenue
    FROM {{ ref('slv_orders_merge') }}
    WHERE order_status != 'cancelled'
    GROUP BY DATE(order_date)
),

daily_payments AS (
    SELECT
        DATE(payment_date) AS payment_day,
        SUM(payment_amount) AS total_collected,
        COUNT(DISTINCT payment_id) AS total_transactions
    FROM {{ ref('slv_payments') }}
    WHERE payment_status = 'completed'
    GROUP BY DATE(payment_date)
)

SELECT
    o.order_day,
    o.total_orders,
    o.unique_customers,
    o.gross_revenue,
    COALESCE(p.total_collected, 0) AS total_collected,
    COALESCE(p.total_transactions, 0) AS total_transactions,
    ROUND(COALESCE(p.total_collected, 0)/ NULLIF(o.gross_revenue, 0) * 100, 2) AS collection_rate_pct,
    current_timestamp() AS pipeline_updated_at
FROM daily_orders o
LEFT JOIN daily_payments p
ON o.order_day = p.payment_day
ORDER BY o.order_day DESC