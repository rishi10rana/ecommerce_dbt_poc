{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='payment_id'
) }}

SELECT
    payment_id,
    order_id,
    CAST(payment_date AS TIMESTAMP)     AS payment_date,
    UPPER(TRIM(payment_method))         AS payment_method,
    UPPER(TRIM(payment_gateway))        AS payment_gateway,
    TRIM(transaction_ref)               AS transaction_ref,
    CAST(amount AS DECIMAL(12,2))       AS amount,
    UPPER(TRIM(status))                 AS status,
    CAST(is_refund AS BOOLEAN)          AS is_refund,
    refund_for_id,
    created_at,
    updated_at
FROM {{ ref('brz_payments') }}
{% if is_incremental() %}
WHERE updated_at > (SELECT COALESCE(MAX(updated_at), '1900-01-01') FROM {{ this }})
{% endif %}
QUALIFY ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY updated_at DESC) = 1