{{ config(
    materialized='incremental',
    incremental_strategy='append',
    tags=['silver', 'incremental_append']
) }}

SELECT
    order_id,
    customer_id,
    CAST(order_date AS TIMESTAMP) AS order_date,
    UPPER(TRIM(status))           AS status,
    CAST(total_amount AS DECIMAL(12,2)) AS total_amount,
    created_at,
    updated_at
FROM {{ ref('brz_orders') }}

{% if is_incremental() %}
WHERE updated_at > (SELECT COALESCE(MAX(updated_at), '1900-01-01') FROM {{ this }})
{% endif %}