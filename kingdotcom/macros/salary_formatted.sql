{% macro salary_formatted(column_name, show_cents) %}

	{% if show_cents == true %}
		to_varchar({{ column_name }}, '$99999.00')
	{% else %}
		to_varchar({{ column_name }}, '$99999') 
	{% endif %}

{% endmacro %}
