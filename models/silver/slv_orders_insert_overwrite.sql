{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by=['order_date_key'],
    file_format='delta',
    tags=['silver', 'incremental_insert_overwrite']
) }}

SELECT
    order_id,
    customer_id,
    CAST(order_date AS TIMESTAMP) AS order_date,
    CAST(order_date AS DATE)      AS order_date_key,
    UPPER(TRIM(status))           AS status,
    CAST(total_amount AS DECIMAL(12,2)) AS total_amount,
    created_at,
    updated_at
FROM {{ ref('brz_orders') }}

{% if is_incremental() %}
WHERE CAST(order_date AS DATE) >= DATE_SUB(CURRENT_DATE(), 3)
{% endif %}