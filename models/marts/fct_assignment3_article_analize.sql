{{ config(materialized='table') }}

select
    title,
    hour_of_day,
    sum(views) as total_views,
    sum(case 
            when src = 'mobile' then views
            else 0 
        end) as total_mobile_views
from {{ ref("int_assignment3_uk_wiki")}}
where title = 'AWStats'
group by hour_of_day, title
order by hour_of_day
