{{
    config(
        materialized = 'incremental',
        unique_key = 'title'
    )
}}

select 
    title,
    min(datehour) as first_date,
    max(datehour) as last_date,
    sum(views) as total_views
from {{ source('test_dataset', 'assignment5_input')}}

{% if is_incremental() %}
    where datehour >= (select max(last_date) from {{ this }}) - interval 1 day
{% endif %}

group by title
