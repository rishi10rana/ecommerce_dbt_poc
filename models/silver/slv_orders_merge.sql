{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id',
    merge_excluded_columns='created_at',
    tags=['silver', 'incremental_merge']
) }}

WITH raw_orders AS (
    SELECT * FROM {{ ref('brz_orders') }}
    {% if is_incremental() %}
    -- Filter incoming records to only those updated after the max timestamp in existing siver table
    WHERE updated_at > (SELECT COALESCE(MAX(updated_at), '1900-01-01') FROM {{ this }})
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY updated_at DESC) AS rn 
        FROM raw_orders
)

SELECT
    order_id,
    customer_id,
    employee_id,
    promotion_id,
    CAST(order_date AS TIMESTAMP) AS order_date,
    CAST(order_date AS DATE) AS order_date_key,
    CAST(shipped_date AS DATE) AS shipped_date,
    CAST(delivery_date AS DATE) AS delivery_date,
    UPPER(TRIM(status)) AS status,
    UPPER(TRIM(shipping_method)) AS shipping_method,
    UPPER(TRIM(shipping_country)) AS shipping_country,
    CAST(subtotal_amount AS DECIMAL(12, 2)) AS subtotal_amount,
    CAST(discount_amount AS DECIMAL(12, 2)) AS discount_amount,
    CAST(tax_amount AS DECIMAL(12, 2)) AS tax_amount,
    CAST(shipping_amount AS DECIMAL(12,2)) AS shipping_amount,
    CAST(total_amount AS DECIMAL(12,2))    AS total_amount,
    UPPER(TRIM(currency_code))    AS currency_code,
    UPPER(TRIM(order_channel))    AS order_channel,
    created_at,
    updated_at
FROM deduped
WHERE rn = 1
