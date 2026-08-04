{{ config(materialized='view') }}
SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    cost_price,
    discount_pct,
    discount_amount,
    line_total,
    fulfillment_status,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'order_items') }}