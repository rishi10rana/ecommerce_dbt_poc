{{ config(materialized='view') }}

SELECT
    return_id,
    order_id,
    order_item_id,
    customer_id,
    product_id,
    return_date,
    reason_code,
    reason_detail,
    quantity_returned,
    refund_amount,
    return_status,
    resolution_date,
    restocked,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'returns') }}