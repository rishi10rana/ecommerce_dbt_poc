{{ config(materialized='view') }}

SELECT
    customer_id,
    first_name,
    last_name,

    LOWER(TRIM(email)) AS clean_email,
    CASE 
        WHEN LOWER(TRIM(email)) LIKE '%@gmail.com'   THEN 'Gmail'
        WHEN LOWER(TRIM(email)) LIKE '%@yahoo.com'   THEN 'Yahoo'
        WHEN LOWER(TRIM(email)) LIKE '%@outlook.com' THEN 'Outlook'
        ELSE 'Corporate/Other'
    END AS email_provider
FROM {{ ref('brz_customers') }}