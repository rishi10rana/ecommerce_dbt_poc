{{ config(
    materialized='table',
    file_format='delta',
    tags=['gold', 'dimensions']
) }}

SELECT
    c.customer_id,
    c.full_name,
    c.first_name,
    c.last_name,
    c.email,
    c.phone_clean AS phone_number,
    c.gender,
    c.date_of_birth,
    FLOOR(DATEDIFF(CURRENT_DATE(), c.date_of_birth) / 365.25) AS age,
    c.city,
    c.state_province,
    c.country_code,
    COALESCE(cc.country_name, 'Unknown') AS country_name,
    COALESCE(cc.region, 'Other') AS global_region,
    COALESCE(cc.is_high_value_market, 0) AS is_high_value_market,
    c.loyalty_tier,
    c.loyalty_points,
    c.is_email_verified,
    c.is_active,
    c.acquisition_source,
    c.preferred_payment,
    cm.first_order_date,
    cm.most_recent_order_date,
    cm.days_since_last_order,
    COALESCE(cm.total_orders_placed, 0) AS lifetime_orders_count,
    COALESCE(cm.lifetime_gross_spend, 0.00) AS lifetime_gross_spend,
    COALESCE(cm.average_order_value, 0.00) AS average_order_value,
    COALESCE(cm.customer_recency_status, 'NEVER_ORDERED') AS recency_status,
    c.account_created_at,
    c.last_login_at,
    c.updated_at
FROM {{ ref('slv_customers') }} c 
LEFT JOIN {{ ref('seed_country_codes') }} cc ON c.country_code = cc.country_code
LEFT JOIN {{ ref('stg_customer_metrics') }} cm ON c.customer_id = cm.customer_id 
