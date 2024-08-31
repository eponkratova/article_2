This dbt repo is setup to house macros of snowflake object management with dbt.
Macros use a combination of snowflake put operations and stages to use local file data to create objects, with file paths set as environment variables. It contains the following macros, with example data formats in the [./snowflake](./snowflake/) folder.


---
### [create_warehouses](./macros/create_warehouses.sql)

This macro helps with the creation and management of snowflake warehouses. 

<details>
  <summary>command line and file parameters</summary>

  ##### command line
  ```bash
  dbt run-operation create_warehouses
  ```

  ##### file parameters
  - **name** - the warehouse name
  - **attributes** - an array of properties

</details>


---
### [create_databases](./macros/create_databases.sql)

This macro helps with the creation and management of snowflake databases. 

<details>
  <summary>command line and file parameters</summary>

  ##### command line
  ```bash
  dbt run-operation create_databases
  ```

  ##### file parameters
  - **name** - the database name
  - **schemas** - a list of schemas existing in a database

</details>

---
### [grant_access](./macros/grant_access.sql)

This macro grants access to roles.

<details>
  <summary>command line and file parameters</summary>

  ##### command line
  ```bash
  dbt run-operation grant_access
  ```

  ##### file parameters
  - **name** - the role name
  - **warehouses** - a list of warehouses a role should be able to use
  - **databases** - a list of databases a role should be able to access
  - **schemas** - a list of schemas in a database a role should be able to access
  - **priviliges** - whether a role can read only or write to a particular database.schema

</details>


---
### [create_users](./macros/create_users.sql)

This macro helps with the creation and management of snowflake users. Any new users that are in the users file will be created and existing will be altered. It is non-destructive and will only disable users with the `disabled` flag.

In order to not version control / store passwords in plain text, you should also pass in the variable `password` which can be passed to your end users, and default to force change upon their first login.

<details>
  <summary>command line and file parameters</summary>

  ##### command line
  ```bash
  dbt run-operation create_users --vars "password: $3cr3t"
  ```

  ##### file parameters
  - **name** - the username for the user
  - **attributes** - array of properties as defined in the [Snowflake Documentation](https://docs.snowflake.com/en/sql-reference/sql/alter-user#object-properties-objectproperties)
  - **roles** - list of roles to grant to the user

</details>

---
### [create_tasks](./macros/create_tasks.sql)

This macro helps with the creation and management of snowflake tasks.

<details>
  <summary>command line and file parameters</summary>

  ##### command line
  ```bash
  dbt run-operation create_tasks
  ```

  ##### file parameters
  - **name** - the database name
  - **warehouse** - the warehouse name name
  - **tasks** - a list of tasks and attributes required to create a task
  - ***name*** - a task name
  - ***column*** - a column to be used for a join
  - ***src_tbl*** - a table to be used to join (additional)
  - ***tgt_tbl*** - a table to be used to join (main)

</details>

