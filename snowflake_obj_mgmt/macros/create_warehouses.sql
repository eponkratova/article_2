{% macro create_warehouses() %}

{% set file = var('snowflake_warehouse_file' , 'snowflake/warehouses/warehouses.yml') %}
{% set must_quote_columns = [ 'COMMENT'] %}

{% set warehouses_list = gather_results(file) %}

{%- set warehouse_sql -%}

-- set single transaction to rollback if errors
begin name create_warehouses;
use role sysadmin;

{% for w in warehouses_list -%}

  {%- set warehouse_name = w.get('name') %}
  {%- set attributes = w.get('attributes') -%}

  CREATE WAREHOUSE IF NOT EXISTS {{ warehouse_name }}  
    WITH 
    {% for key, value in attributes.items() -%}
    {%- if key in must_quote_columns or ' ' in value|string -%}
    {{ key }} = {{ "'" ~ value ~ "'" }}
    {%- else -%}
    {{ key }} = {{ value }}
    {%- endif %}
    {% endfor -%}
  ;

{%- endfor -%}

commit;

{%- endset %}

{% do log(warehouse_sql, info=True) %}
{% if not var('dry_run', False) %}
  {{ run_query(warehouse_sql) }}
{% endif %}

{% endmacro %}
