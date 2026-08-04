{{ config(materialized='view') }}

SELECT
    order_id,
    customer_id,
    employee_id,
    promotion_id,
    order_date,
    required_date,
    shipped_date,
    delivery_date,
    status,
    shipping_method,
    shipping_address,
    shipping_city,
    shipping_country,
    subtotal_amount,
    discount_amount,
    tax_amount,
    shipping_amount,
    total_amount,
    currency_code,
    order_channel,
    notes,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'orders') }}