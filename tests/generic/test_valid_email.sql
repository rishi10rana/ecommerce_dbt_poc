{% test valid_email(model, column_name) %}

SELECT
    {{ column_name}} AS invalid_email
FROM {{ model }}
WHERE {{ column_name }} NOT RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
AND {{ column_name }} IS NOT NULL

{% endtest %}