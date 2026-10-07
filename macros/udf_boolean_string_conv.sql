{% macro udf_boolean_string_conv(boolean_col) %}
    CASE
        WHEN {{ boolean_col }} = 1 THEN 'X'
        WHEN {{ boolean_col }} = 0 THEN ' '
        ELSE NULL
    END
{% endmacro %}
