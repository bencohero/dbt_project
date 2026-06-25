{% macro get_age_bucket(column_dob, mode='simple') -%}

    {%- set m = mode | lower -%}
    
    case
        when {{ column_dob }} is null then 'unknown'
        when extract(year from age({{ column_dob }}))::int is null or extract(year from age({{ column_dob }}))::int < 0 then 'unknown'
        
        {% if m == 'simple' %}
        when extract(year from age({{ column_dob }}))::int < 5 then '0-4'
        when extract(year from age({{ column_dob }}))::int between 5 and 14 then '5-14'
        when extract(year from age({{ column_dob }}))::int between 15 and 24 then '15-24'
        when extract(year from age({{ column_dob }}))::int between 25 and 64 then '25-64'
        else '65+'
        
        {% elif m == 'oms' %}
        when extract(year from age({{ column_dob }}))::int < 1 then '0-<1'
        when extract(year from age({{ column_dob }}))::int between 1 and 4 then '1-4'
        when extract(year from age({{ column_dob }}))::int between 5 and 9 then '5-9'
        when extract(year from age({{ column_dob }}))::int between 10 and 19 then '10-19'
        when extract(year from age({{ column_dob }}))::int between 20 and 24 then '20-24'
        when extract(year from age({{ column_dob }}))::int between 25 and 59 then '25-59'
        else '60+'
        
        {% elif m == 'onu' %}
        when extract(year from age({{ column_dob }}))::int >= 85 then '85+'
        else 
            -- Calcul mathématique pour les tranches de 5 ans en Postgres SQL
            ((extract(year from age({{ column_dob }}))::int / 5) * 5)::text || '-' || (((extract(year from age({{ column_dob }}))::int / 5) * 5) + 4)::text
            
        {% else %}
        -- Fallback : comportement 'simple'
        when extract(year from age({{ column_dob }}))::int < 5 then '0-4'
        when extract(year from age({{ column_dob }}))::int between 5 and 14 then '5-14'
        when extract(year from age({{ column_dob }}))::int between 15 and 24 then '15-24'
        when extract(year from age({{ column_dob }}))::int between 25 and 64 then '25-64'
        else '65+'
        {% endif %}
    end

{%- endmacro %}