SELECT
    1 AS test_id,
    'Hello from Databricks DAB' AS message,
    current_timestamp() AS pipeline_run_at,
    '{{ target.name }}' AS dbt_project_env,
    '{{ target.catalog }}' AS dbt_catalog,
    '{{ target.schema }}' AS dbt_schema