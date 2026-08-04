{{ config(
    materialized='ephemeral',
    tags=['staging', 'ephemeral']
) }}

WITH order_item_aggregates AS (
    SELECT
        order_id,
        order_id,
        COUNT(order_item_id) AS total_items_count,
        SUM(quantity) AS total_units_sold,
        SUM(line_total) AS gross_item_revenue,
        SUM(discount_amount) AS total_item_discounts,
        SUM(quantity * unit_price) AS total_base_revenue,
        SUM(quantity * cost_price) AS total_order_cost,
        SUM(line_total - (quantity * cost_price)) AS total_order_profit
    FROM {{ ref('slv_order_items') }}
    WHERE fulfillment_status NOT IN ('CANCELLED')
    GROUP BY order_id
)

SELECT
    order_id,
    total_items_count,
    total_units_sold,
    CAST(gross_item_revenue AS DECIMAL(12,2))   AS gross_item_revenue,
    CAST(total_item_discounts AS DECIMAL(12,2)) AS total_item_discounts,
    CAST(total_base_revenue AS DECIMAL(12,2))   AS total_base_revenue,
    CAST(total_order_cost AS DECIMAL(12,2))     AS total_order_cost,
    CAST(total_order_profit AS DECIMAL(12,2))   AS total_order_profit,
    ROUND((total_order_profit / NULLIF(gross_item_revenue, 0)) * 100, 2) AS order_profit_margin_pct
FROM order_item_aggregates