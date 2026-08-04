{{ config(
    materialized='view',
    tags=['staging', 'inventory']
) }}

WITH product_stock AS (
    SELECT
        product_id,
        COUNT(DISTINCT warehouse_code) AS warehouses_stocking_count,
        SUM(quantity_on_hand) AS total_quantity_on_hand,
        SUM(quantity_reserved) AS total_quantity_reserved,
        SUM(quantity_available) AS total_quantity_available,
        MIN(reorder_point) AS min_reorder_point
    FROM {{ ref('brz_inventory') }}
    GROUP BY product_id
)

SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    p.unit_price,
    p.is_digital,
    COALESCE(ps.warehouses_stocking_count, 0) AS warehouses_stocking_count,
    COALESCE(ps.total_quantity_on_hand, 0)    AS total_quantity_on_hand,
    COALESCE(ps.total_quantity_reserved, 0)   AS total_quantity_reserved,
    COALESCE(ps.total_quantity_available, 0)  AS total_quantity_available,
    CASE
        WHEN p.is_digital = CAST(1 AS BOOLEAN) THEN 'UNLIMITED'
        WHEN COALESCE(ps.total_quantity_available, 0) <= 0 THEN 'OUT_OF_STOCK'
        WHEN ps.total_quantity_available <= ps.min_reorder_point THEN 'LOW_STOCK_WARNING'
        ELSE 'HEALTHY'
    END AS stock_health_status
FROM {{ ref('slv_products') }} p
LEFT JOIN product_stock ps ON p.product_id = ps.product_id