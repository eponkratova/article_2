{% macro create_databases() %}

{% set file = var('snowflake_db_file' , 'snowflake/databases/databases.yml') %}

{% set db_list = gather_results(file) %}

{%- set database_sql -%}

-- set single transaction to rollback if errors
begin name create_databases;
use role sysadmin;

{% for db in db_list -%}

    {%- set db_name = db.get('name') -%}
    {%- set schemas = db.get('schemas') %}

    CREATE DATABASE IF NOT EXISTS {{ db_name.upper() }}  
    ;

  {% for schema in schemas -%}
  CREATE SCHEMA IF NOT EXISTS {{ db_name }}.{{ schema.upper() }}  
  ;

  {% endfor -%}

{%- endfor -%}

commit;

{%- endset %}

{% do log(database_sql, info=True) %}
{% if not var('dry_run', False) %}
  {{ run_query(database_sql) }}
{% endif %}

{% endmacro %}