{% macro audit_columns() %}
    CURRENT_TIMESTAMP() AS _dbt_loaded_at,
    '{{ invocation_id }}' AS _dbt_invocation_id,
    '{{ target.name }}' AS _dbt_environment
{% endmacro %}