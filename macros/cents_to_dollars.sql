{% macro cents_to_dollars(column_name, scale=2) %}
    ROUND(CAST({{ column_name }} AS DECIMAL(18, 4)) / 100.0, {{ scale }})
{% endmacro%}