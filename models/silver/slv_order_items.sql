{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_item_id'
) }}

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    CAST(unit_price AS DECIMAL(10,2))    AS unit_price,
    CAST(cost_price AS DECIMAL(10,2))    AS cost_price,
    CAST(discount_pct AS DECIMAL(5,2))   AS discount_pct,
    CAST(discount_amount AS DECIMAL(10,2)) AS discount_amount,
    CAST(line_total AS DECIMAL(12,2))    AS line_total,
    UPPER(TRIM(fulfillment_status))      AS fulfillment_status,
    created_at,
    updated_at
FROM {{ ref('brz_order_items') }}
{% if is_incremental() %}
WHERE updated_at > (SELECT  COALESCE(MAX(updated_at), '1900-01-01') FROM {{ this }})
{% endif %}
QUALIFY ROW_NUMBER() OVER (PARTITION BY order_item_id ORDER BY updated_at DESC) = 1