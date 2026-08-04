{{ config(materialized='view') }}
SELECT
    inventory_id,
    product_id,
    warehouse_code,
    warehouse_name,
    quantity_on_hand,
    quantity_reserved,
    quantity_available,
    reorder_point,
    reorder_quantity,
    last_restocked_at,
    unit_cost,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'inventory') }}