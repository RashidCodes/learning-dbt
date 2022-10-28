{{
    config(
        materialized='table',
        database='hr',
        schema='model',
	post_hook="COPY INTO @PAYROLL.UTIL.S3_PAYROLL_CSV FROM {{ this }}"
    )
}}


with agg as (
	select 
		min(salary) as lowest_salary,
		date_part(year, from_date) salary_year 
	from 
		payroll.source.salaries 
	group by
		salary_year 
)

select 
	lowest_salary,
	{{ salary_formatted('lowest_salary', true) }} as salary_show_cents,
	{{ salary_formatted('lowest_salary', false) }} as salary_no_cents,
	salary_year 
from agg
	
