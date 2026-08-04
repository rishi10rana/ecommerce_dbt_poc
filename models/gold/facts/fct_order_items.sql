{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_item_id',
    tags=['gold', 'fact']
) }}

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    o.customer_id,
    o.order_date_key,
    oi.quantity,
    oi.unit_price,
    oi.cost_price,
    oi.discount_pct,
    oi.discount_amount,
    oi.line_total AS gross_revenue,
    (oi.quantity * oi.cost_price) AS total_cost,
    (oi.line_total - (oi.quantity * oi.cost_price)) AS total_profit,
    oi.fulfillment_status,
    oi.created_at,
    oi.updated_at
FROM {{ ref('slv_order_items') }} oi 
JOIN {{ ref('slv_orders_merge') }} o ON oi.order_id = o.order_id 
{% if is_incremental() %}
WHERE oi.updated_at > (SELECT COALESCE(MAX(updated_at), '1900-01-01') FROM {{ this }})
{% endif %}