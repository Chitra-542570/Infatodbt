{% macro md5_hash(columns) %}
    MD5(
        {% for col in columns %}
            COALESCE(CAST({{ col }} AS VARCHAR), 'col_{{ loop.index }}')
            {% if not loop.last %} || {% endif %}
        {% endfor %}
    )
{% endmacro %}
