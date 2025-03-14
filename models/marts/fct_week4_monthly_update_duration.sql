{{ config(materialized='table') }}

select 
    published_month,
    round(avg(days_until_updated)) as avg_update_period_total,
    round(avg(if(is_updated = 1, days_until_updated, null))) as avg_update_period,
from {{ ref("int_week4_arxiv_duration_llm")}}
group by 1