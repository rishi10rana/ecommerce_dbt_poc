{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='customer_id'
) }}

WITH raw_cust AS (
    SELECT * FROM {{ ref('brz_customers') }}
    {% if is_incremental() %}
    WHERE updated_at > (SELECT COALESCE(MAX(updated_at), '1900-01-01') FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        customer_id,
        INITCAP(TRIM(first_name)) AS first_name,
        INITCAP(TRIM(last_name))  AS last_name,
        CONCAT(INITCAP(TRIM(first_name)), ' ', INITCAP(TRIM(last_name))) AS full_name,
        LOWER(TRIM(email))        AS email,
        REGEXP_REPLACE(phone, '[^0-9+]', '') AS phone_clean,
        UPPER(TRIM(gender))       AS gender,
        CAST(date_of_birth AS DATE) AS date_of_birth,
        TRIM(city)                AS city,
        TRIM(address_line1) as address_line1,
        TRIM(state_province)      AS state_province,
        UPPER(TRIM(country_code)) AS country_code,
        UPPER(TRIM(loyalty_tier)) AS loyalty_tier,
        COALESCE(loyalty_points, 0) AS loyalty_points,
        CAST(is_email_verified AS BOOLEAN) AS is_email_verified,
        CAST(is_active AS BOOLEAN)         AS is_active,
        UPPER(TRIM(acquisition_source))   AS acquisition_source,
        UPPER(TRIM(preferred_payment))    AS preferred_payment,
        CAST(account_created_at AS TIMESTAMP) AS account_created_at,
        CAST(last_login_at AS TIMESTAMP)     AS last_login_at,
        created_at,
        updated_at,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) AS rn
    FROM raw_cust
)
SELECT * EXCEPT(rn) FROM cleaned WHERE rn = 1