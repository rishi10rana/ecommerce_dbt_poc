{{ config(materialized='view') }}

SELECT
    payment_id,
    order_id,
    payment_date,
    payment_method,
    payment_gateway,
    transaction_ref,
    amount,
    currency_code,
    status,
    failure_reason,
    is_refund,
    refund_for_id,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'payments') }}