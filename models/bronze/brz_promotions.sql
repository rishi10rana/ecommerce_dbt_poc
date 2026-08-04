{{ config(materialized='view') }}

SELECT
    promotion_id,
    promo_code,
    promo_name,
    promo_type,
    discount_value,
    min_order_amount,
    max_discount_cap,
    start_date,
    end_date,
    is_active,
    usage_limit,
    times_used,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'promotions') }}