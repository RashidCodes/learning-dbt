{{
    config(
        materialized='table',
        database='hr',
        schema='model'
    )
}}

with junior_employees as (
    select
        emp_no,
        title,
        from_date
    from
        {{ source('hr', 'titles') }}
    where
        title in ('Assistant Engineer', 'Staff')
),
junior_starting_salary as (
    select
        sal.emp_no,
        emp.title,
        date_part(year, emp.from_date) as starting_year,
        sal.salary
    from
        {{ source('payroll', 'salaries') }} sal
        inner join junior_employees emp
        on emp.emp_no = sal.emp_no
        and emp.from_date between sal.from_date and sal.to_date
),
full_col as(
    select
        sal.emp_no,
        sal.title,
        emp.gender,
        sal.starting_year,
        sal.salary
    from
        junior_starting_salary sal
        inner join {{ source('hr', 'employees') }} emp
        on sal.emp_no = emp.emp_no
)
select
    title,
    gender,
    starting_year,
    median(salary) as median_starting_salary,
    current_timestamp(0) as inserted_at
from
    full_col
group by
    title,
    gender,
    starting_year
