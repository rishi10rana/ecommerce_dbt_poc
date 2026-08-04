{% macro log_run_start() %}
    {% set msg = "dbt execution STARTED for invocation_id: " ~ invocation_id ~ " at " ~ modules.datetime.datetime.now() %}
    {{ log(msg, info=True) }}
{% endmacro %}

{% macro log_run_end() %}
    {% set msg = "dbt execution COMPLETED for invocation_id: " ~ invocation_id ~ " at " ~ modules.datetime.datetime.now() %}
    {{ log(msg, info=True) }}
{% endmacro %}