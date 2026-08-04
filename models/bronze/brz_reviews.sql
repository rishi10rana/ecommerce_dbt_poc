{{ config(materialized='view') }}

SELECT
    review_id,
    product_id,
    customer_id,
    order_id,
    rating,
    review_title,
    review_body,
    is_verified_purchase,
    helpful_votes,
    is_published,
    moderation_status,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'reviews') }}