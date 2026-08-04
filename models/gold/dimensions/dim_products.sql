{{ config(
    materialized='table',
    file_format='delta',
    tags=['gold', 'dimensions']
) }}

SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    p.sub_category,
    p.brand,
    p.unit_price,
    p.cost_price,
    p.profit_margin_amount,
    p.profit_margin_pct,
    p.currency_code,
    p.is_active,
    p.is_digital,
    COALESCE(pi.total_quantity_on_hand, 0) AS quantity_on_hand,
    COALESCE(pi.total_quantity_available, 0) AS quantity_available,
    COALESCE(pi.stock_health_status, 'UNKNOWN') AS stock_health_status,
    p.created_at,
    p.updated_at
FROM {{ ref('slv_products') }} p 
LEFT JOIN {{ ref('stg_product_inventory') }} pi ON p.product_id = pi.product_id 