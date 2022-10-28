# Learning DBT 

## Best Practices

- Write the SQL Logic in snowflake before dbt

<br/>

## Note on Schema 

The default behaviour here is that `dbt` will append your custome schema to the default schema and give you `<default_schema>_<customer_schema>`. This is useful when you have multiple people collaborating however for this project, the specified schema name is preferred.

<br/>

## Config blocks 

- Transcient tables

	```sql 

	{{
	   config(
	      materialize='table',
	      transcient=true 
	   )
	}}
       ```

<br/>

- Cluster by 

```sql
{{
   config(
      materialize='table',
      cluster_by=['session_start']
   )
}}

```

Checkout the Snowflake dbt config docs for more.

<br/>


## Materialization

How do you want to persist your model in the warehouse? Materialisations in `dbt` include:

- incremental
- ephemeral
- table
- view 
- custom


<br/>

## Sources 

Sources are used to describe tables loaded by means other than dbt. The tables uploaded from `s3` are all source tables

<br/>

## Sources 

Sources are used to describe tables loaded by means other than dbt. The tables uploaded from `s3` are all source tables. Sources are defined in `yml`files. These `yml` files can be placed anywhere in the `models` folder.


- `dbt` is able to check the freshness of your sources by configuring `sources.yml` appropriately.
- `dbt` also allows assumptions checks about your data. 


<br/>

## `ref()`

Use the `ref` function to reference other models in `dbt`. It helps `dbt` determine the order to run the models by creating a DAG. You should never use direct table names. They should be replaced by either `ref()` or `source()`.


<br/>


## Seeds

Seeds are CSV files in your `dbt` project (typically in your `seeds` directory), that dbt can load into your data warehouse using the `dbt seed` command. The can be referrenced with the `ref()` function. You can learn more seeds here: https://docs.getdbt.com/docs/build/seeds 


<br/>


## Generate the Docs 
```bash 

dbt docs generate 
``` 

```bash 

dbt docs serve 
```

<br/>

## Running `dbt` in Production 

- Create a new `profiles.yml` configuration file.
- Clean the repo with `dbt clean`.
- Store sensitive information in a `.env` file - `dbt.env`.
- Containerise your application
- Make sure the docker container runs successfully 
	
	```bash 
	docker run -it --entrypoint bash dbtbuild
	```

<br/>




