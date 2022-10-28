{% test year_greater_than(model, column_name, min_year) %}

	select * 
	from {{ model }}
	where {{ column_name }} < {{ min_year }}

{% endtest %}

