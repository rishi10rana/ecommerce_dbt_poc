SELECT
    oi.order_item_id,
    oi.order_id
FROM {{ ref('fct_order_items') }} oi 
LEFT JOIN {{ ref('fct_orders') }} o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL