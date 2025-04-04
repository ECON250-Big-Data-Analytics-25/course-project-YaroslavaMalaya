{{ config(materialized='view') }}

with cte_both_tables as (
    select 
        datehour, 
        title, 
        views,
        'desktop' as src,
    from {{ source('test_dataset', 'assignment3_input_uk')}}
    union all 
    select
        datehour, 
        title, 
        views,
        'mobile' as src,
    from {{ source('test_dataset', 'assignment3_input_uk_m')}}
)

select 
    datehour,
    title,
    views,
    src,
    date(datehour) as date,
    case 
      when extract(dayofweek from datehour) - 1 = 0 then 7
      else extract(dayofweek from datehour) - 1 
    end as day_of_week,
    extract(hour from datehour) as hour_of_day
from cte_both_tables
