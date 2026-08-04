{{ config(materialized='view') }}

SELECT
    employee_id,
    first_name,
    last_name,
    email,
    phone,
    job_title,
    department,
    hire_date,
    salary,
    manager_id,
    country_code,
    is_active,
    created_at,
    updated_at,
    {{ audit_columns() }}
FROM {{ source('raw_ecommerce', 'employees') }}