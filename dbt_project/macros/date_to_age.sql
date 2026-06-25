{% macro date_to_age(column_name) -%}
    EXTRACT(YEAR FROM AGE({{ column_name }}))
{%- endmacro %}