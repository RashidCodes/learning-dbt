# Refactoring SQL for Modularity 

## Sample Data

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

# Sample Code 
Let's say the head of finance reaches out to you to put this code in a dbt project. How do you go about it? 

```sql 

select 
    orders.id as order_id,
    orders.user_id as customer_id,
    last_name as surname,
    first_name as givenname,
    first_order_date,
    order_count,
    total_lifetime_value,
    round(amount/100.0,2) as order_value_dollars,
    orders.status as order_status,
    payments.status as payment_status
from {{ source('jaffle_shop', 'orders') }} as orders

join (
      select 
        first_name || ' ' || last_name as name, 
        * 
      from {{ source('jaffle_shop', 'customers') }}
) customers
on orders.user_id = customers.id

join (

    select 
        b.id as customer_id,
        b.name as full_name,
        b.last_name as surname,
        b.first_name as givenname,
        min(order_date) as first_order_date,
        min(case when a.status NOT IN ('returned','return_pending') then order_date end) as first_non_returned_order_date,
        max(case when a.status NOT IN ('returned','return_pending') then order_date end) as most_recent_non_returned_order_date,
        COALESCE(max(user_order_seq),0) as order_count,
        COALESCE(count(case when a.status != 'returned' then 1 end),0) as non_returned_order_count,
        sum(case when a.status NOT IN ('returned','return_pending') then ROUND(c.amount/100.0,2) else 0 end) as total_lifetime_value,
        sum(case when a.status NOT IN ('returned','return_pending') then ROUND(c.amount/100.0,2) else 0 end)/NULLIF(count(case when a.status NOT IN ('returned','return_pending') then 1 end),0) as avg_non_returned_order_value,
        array_agg(distinct a.id) as order_ids

    from (
      select 
        row_number() over (partition by user_id order by order_date, id) as user_order_seq,
        *
      from {{ source('jaffle_shop', 'orders') }}
    ) a

    join ( 
      select 
        first_name || ' ' || last_name as name, 
        * 
      from {{ source('jaffle_shop', 'customers') }}
    ) b
    on a.user_id = b.id

    left outer join {{ source('stripe', 'payment') }} c
    on a.id = c.orderid

    where a.status NOT IN ('pending') and c.status != 'fail'

    group by b.id, b.name, b.last_name, b.first_name

) customer_order_history
on orders.user_id = customer_order_history.customer_id

left outer join {{ source('stripe', 'payment') }} payments
on orders.id = payments.orderid

where payments.status != 'fail'
```

<br/>


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

