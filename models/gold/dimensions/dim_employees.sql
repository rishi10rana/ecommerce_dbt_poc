{{ config(
    materialized='table',
    file_format='delta',
    tags=['gold', 'dimensions']
) }}

SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    job_title,
    department,
    hire_date,
    salary,
    manager_id,
    country_code,
    is_active,
    updated_at
FROM {{ ref('brz_employees') }}