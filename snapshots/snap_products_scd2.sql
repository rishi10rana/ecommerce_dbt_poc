{% snapshot snap_products_scd2 %}

{{
    config(
        target_database='dbt_cloud',
        target_schema='snapshots',
        unique_key='product_id',
        strategy='check',
        check_cols=['unit_price', 'cost_price', 'category', 'is_active'],
        invalidate_hard_deletes=True,
        tags=['snapshots', 'scd2']
    )
}}

SELECT
    product_id,
    sku,
    product_name,
    category,
    sub_category,
    brand,
    unit_price,
    cost_price,
    is_active,
    updated_at
FROM {{ ref('slv_products') }}

{% endsnapshot %}