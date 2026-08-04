{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id',
    tags=['gold', 'fact']
) }}

SELECT
    o.order_id,
    o.customer_id,
    o.employee_id,
    o.promotion_id,
    o.order_date_key,
    o.order_date,
    o.shipped_date,
    o.delivery_date,
    o.status AS order_status,
    o.shipping_method,
    o.shipping_country,
    o.order_channel,
    o.currency_code,
    COALESCE(rev.total_items_count, 0) AS line_items_count,
    COALESCE(rev.total_units_sold, 0) AS total_units_sold,
    o.subtotal_amount,
    o.discount_amount,
    o.tax_amount,
    o.shipping_amount,
    o.total_amount AS gross_order_revenue,
    COALESCE(rev.total_order_cost, 0.00) AS total_order_cost,
    COALESCE(rev.total_order_profit, 0.00) AS total_order_profit,
    COALESCE(rev.order_profit_margin_pct, 0) AS profit_margin_pct,
    o.created_at,
    o.updated_at
FROM {{ ref('slv_orders_merge') }} o
LEFT JOIN {{ ref('stg_order_revenue') }} rev ON o.order_id = rev.order_id 
{% if is_incremental() %}
WHERE o.updated_at > (SELECT COALESCE(MAX(updated_at), '1900-01-01') FROM {{ this }})
{% endif %}