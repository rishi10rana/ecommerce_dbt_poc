{{ config(materialized='view') }}

SELECT
    product_id,
    sku,
    product_name,
    description,
    category,
    sub_category,
    brand,
    unit_price,
    cost_price,
    currency_code,
    weight_kg,
    is_active,
    is_digital,
    tax_category,
    supplier_id,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'products') }}