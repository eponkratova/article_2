{% macro grant_access() %}

{% set file = var('snowflake_access_file' , 'snowflake/object_roles/object_roles.yml') %}

{% set roles_list = gather_results(file) %}

{%- set access_sql -%}

-- set single transaction to rollback if errors
begin name grant_access;
use role USERADMIN;

{% for rl in roles_list -%}
    {%- set role_name = rl.get('name') -%}
    {%- set warehouses = rl['warehouses'] %}
    {%- set databases = rl['databases'] %}

    CREATE ROLE IF NOT EXISTS {{ role_name }};

    USE ROLE SECURITYADMIN;
    
    {% for dict_item in databases %}
        {% for dict_item_low in dict_item.schemas %}
            {% if dict_item_low.privileges  == 'read' %}
                GRANT USAGE ON DATABASE {{ dict_item.name }} TO ROLE {{ role_name }};
                GRANT USAGE ON FUTURE SCHEMAS IN DATABASE {{ dict_item.name  }} TO ROLE  {{ role_name }};
                GRANT SELECT ON ALL TABLES IN SCHEMA {{ dict_item.name  }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
                GRANT SELECT ON ALL VIEWS IN SCHEMA {{ dict_item.name  }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
                GRANT SELECT ON FUTURE VIEWS IN SCHEMA {{ dict_item.name  }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
                GRANT SELECT ON FUTURE TABLES IN SCHEMA {{ dict_item.name  }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
            {% elif dict_item_low.privileges == 'write' %}
                GRANT USAGE ON DATABASE {{ dict_item.name }} TO ROLE {{ role_name }};     
                GRANT USAGE ON FUTURE SCHEMAS IN DATABASE {{ dict_item.name  }} TO ROLE  {{ role_name }};
                GRANT SELECT ON ALL VIEWS IN SCHEMA {{ dict_item.name  }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
                GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA {{ dict_item.name }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
                GRANT CREATE TABLE, CREATE VIEW ON SCHEMA {{ dict_item.name }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
                GRANT SELECT ON FUTURE VIEWS IN SCHEMA {{ dict_item.name  }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
                GRANT SELECT ON FUTURE TABLES IN SCHEMA {{ dict_item.name  }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
                GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA {{ dict_item.name }}.{{ dict_item_low.name }} TO ROLE {{ role_name }};
            {% endif %}        
        {% endfor %}
    {%- endfor -%}

    USE ROLE SECURITYADMIN;
    {% for dict_item_high in warehouses %}
        GRANT USAGE ON WAREHOUSE  {{ dict_item_high.name }} TO ROLE {{ role_name }};
    {% endfor %}

{%- endfor -%}

commit;

{%- endset %}

{% do log(access_sql, info=True) %}
{% if not var('dry_run', False) %}
  {{ run_query(access_sql) }}
{% endif %}

{% endmacro %}
