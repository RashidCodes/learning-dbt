{{
    config(
        materialized='table',
        database='hr',
        schema='model'
    )
}}

with current_senior as (
    select
        emp_no,
        date_part(year, from_date) as year_became_senior
    from
        hr.source.titles
    where
        title like 'Senior%'
        and to_date = '9999-01-01'
),
current_salary as (
    select
        emp_no,
        salary
    from
        payroll.source.salaries
    where
        to_date = '9999-01-01'
)
select
    round(avg(sal.salary), 2) as average_salaries,
    emp.year_became_senior,
    count(1) as num_of_emp,
    current_timestamp(0) as inserted_at
from 
    current_senior emp    
left join current_salary sal
    on emp.emp_no = sal.emp_no
group by
    emp.year_became_senior
