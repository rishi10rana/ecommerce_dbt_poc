{{ config(
    materialized='view'
) }}

SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    gender,
    date_of_birth,
    address_line1,
    address_line2,
    city,
    state_province,
    postal_code,
    country_code,
    loyalty_tier,
    loyalty_points,
    is_email_verified,
    is_active,
    acquisition_source,
    preferred_payment,
    account_created_at,
    last_login_at,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'customers') }}