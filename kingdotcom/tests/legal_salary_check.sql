select * 
from {{ ref('minimum_legal_salaries') }}
where minimum_salary < 38000
