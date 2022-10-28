# Refactoring SQL for Modularity 

Let's say the head of finance reaches out to you to put this code in a dbt project. How do you go about it? 

```sql 

use warehouse ETL;
use role accountadmin;

create warehouse transforming;
create database raw;
create database analytics;
create schema raw.jaffle_shop;
create schema raw.stripe;


-- create the customers, orders, and payment tables 
create table raw.jaffle_shop.customers ( 
    id integer,
    first_name varchar,
    last_name varchar
);

copy into raw.jaffle_shop.customers (id, first_name, last_name)
from 's3://dbt-tutorial-public/jaffle_shop_customers.csv'
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
);


-- orders
create table raw.jaffle_shop.orders( 
    id integer,
    user_id integer,
    order_date date,
    status varchar,
    _etl_loaded_at timestamp default current_timestamp
);

copy into raw.jaffle_shop.orders (id, user_id, order_date, status)
from 's3://dbt-tutorial-public/jaffle_shop_orders.csv'
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
);

-- payment
create table raw.stripe.payment ( 
    id integer,
    orderid integer,
    paymentmethod varchar,
    status varchar,
    amount integer,
    created date,
    _batched_at timestamp default current_timestamp
);

copy into raw.stripe.payment (id, orderid, paymentmethod, status, amount, created)
from 's3://dbt-tutorial-public/stripe_payments.csv'
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
);


-- check the data 
select * from raw.jaffle_shop.customers;
select * from raw.jaffle_shop.orders;
select * from raw.stripe.payment;

```

<br/>

# Find the sources
Find the sources in the code above and place the sources in a sources config.yml file.


# Refactoring Legacy Code, dbt Style
- Step 1: Migrating Legacy Code 1:1
  In this stage, we just copy and paste his code into `legacy/customers_orders.sql`. Then we do a `dbt-run` to make sure it works as expected.

<br/>

- Step 2: Translate hard coded table references 
  Create sources and translate the hard coded table references. Create a folder for each source, for e.g. `raw.jaffle_shop.{{ table_name }}` should be stored in `models/jaffle_shop`. Create a `source.yml` config for each source.

<br/>

- Step 3: Choose a refactoring strategy
  Create a new copy of the slightly modified query in `models/marts/fct_customer_orders.sql`. Refactoring can now begin

<br/>

- Step 4: CTE Groupings and Cosmetic Cleanups 
  Cosmetic cleanups means implementing best practices and coding conventions and really just making the code more inherent if you understand so that way you don't get lost in the code when while you refactor. the more important piece here is going to be the CTE groupings.

