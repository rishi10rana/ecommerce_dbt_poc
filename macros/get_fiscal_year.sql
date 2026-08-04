{% macro get_fiscal_year(date_column) %}
    CASE
        WHEN MONTH({{ date_column }}) >= 4
        THEN YEAR({{ date_column }})
        ELSE YEAR({{ date_column}}) - 1
    END
{% endmacro %}