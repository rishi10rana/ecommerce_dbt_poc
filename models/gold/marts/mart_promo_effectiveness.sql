{{ config(
    materialized='table',
    tags=['layer_gold', 'daily', 'mart', 'marketing']
) }}

WITH promo_orders AS (
    SELECT
        o.promotion_id,
        COUNT(DISTINCT o.order_id) AS orders_with_promo,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        SUM(o.gross_order_revenue) AS gross_revenue,
        SUM(o.discount_amount) AS total_discount_given,
        SUM(o.gross_order_revenue - o.discount_amount) AS net_revenue
    FROM {{ ref('fct_orders') }} o
    WHERE o.promotion_id IS NOT NULL
    AND o.order_status NOT IN ('CANCELLED')
    GROUP BY o.promotion_id
)

SELECT
    p.promotion_id,
    p.promo_code,
    p.promo_name,
    p.promo_type,
    p.discount_value,
    p.start_date,
    p.end_date,
    p.is_active,
    COALESCE(po.orders_with_promo, 0) AS orders_with_promo,
    COALESCE(po.unique_customers, 0) AS unique_customers_used,
    COALESCE(po.gross_revenue, 0.00) AS gross_revenue,
    COALESCE(po.total_discount_given, 0.00) AS total_discount_given,
    COALESCE(po.net_revenue, 0.00) AS net_revenue,
    ROUND(
        COALESCE(po.total_discount_given, 0) /
        NULLIF(COALESCE(po.gross_revenue, 0), 0) * 100, 2
    ) AS discount_rate_pct,
    ROUND(
        COALESCE(po.net_revenue, 0) /
        NULLIF(COALESCE(po.orders_with_promo, 0), 0), 2
    ) AS avg_net_revenue_per_or
FROM {{ ref('brz_promotions') }} p
LEFT JOIN promo_orders po ON p.promotion_id = po.promotion_id

