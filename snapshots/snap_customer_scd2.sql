{% snapshot snap_customer_scd2 %}
{{ config(
    target_database='dbt_cloud',
    target_schema='snapshots',
    unique_key='customer_id',
    strategy='timestamp',
    updated_at='updated_at',
    invalidate_hard_deletes=True,
    tags=['snapshots', 'scd2']
) }}

SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone_clean,
    address_line1,
    city,
    state_province,
    country_code,
    loyalty_tier,
    loyalty_points,
    is_active,
    updated_at
FROM {{ ref('slv_customers') }}

{% endsnapshot %}