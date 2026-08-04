{% test not_negative(model, column_name) %}

SELECT
    {{ column_name }} AS failing_value,
    COUNT(*) AS violation_count
FROM {{ model }}
WHERE {{ column_name }} < 0
GROUP BY {{ column_name }}

{% endtest %}