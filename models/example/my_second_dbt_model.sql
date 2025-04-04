
-- Use the `ref` function to select from other models

select *,
"test value" as new_columne
from {{ ref('my_first_dbt_model') }}
where id = 1
