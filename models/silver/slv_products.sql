{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='product_id'
) }}

WITH raw_prod AS (
    SELECT * FROM {{ ref('brz_products') }}
    {% if is_incremental() %}
    WHERE updated_at > (SELECT COALESCE(MAX(updated_at), '1900-01-01') FROM {{ this }})
    {% endif %}
)

SELECT
    product_id,
    UPPER(TRIM(sku))             AS sku,
    TRIM(product_name)           AS product_name,
    TRIM(category)               AS category,
    TRIM(sub_category)           AS sub_category,
    TRIM(brand)                  AS brand,
    CAST(unit_price AS DECIMAL(10,2)) AS unit_price,
    CAST(cost_price AS DECIMAL(10,2)) AS cost_price,
    ROUND(unit_price - cost_price, 2) AS profit_margin_amount,
    ROUND((unit_price - cost_price) / NULLIF(unit_price, 0) * 100, 2) AS profit_margin_pct,
    UPPER(TRIM(currency_code))   AS currency_code,
    CAST(is_active AS BOOLEAN)   AS is_active,
    CAST(is_digital AS BOOLEAN)  AS is_digital,
    created_at,
    updated_at
FROM raw_prod
QUALIFY ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY updated_at DESC) = 1
