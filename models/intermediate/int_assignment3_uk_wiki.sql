{{ config(materialized='view') }}

with cte_all_prefixs as (
    select
        *, 
        split(regexp_replace(title,'"', ''), ':')[offset (0)] as prefix
    from {{ ref("stg_assignment3_uk_wiki")}}
),

cte_is_meta_page as (
    select
        *,
        case 
            when lower(prefix) like '%обговорення%' 
                or lower(prefix) in ('категорія', 'файл', 'вікіпедія', 'шаблон', 'користувач', 'портал', 'спеціальна', 'довідка', 'модуль', 'користувачка')
            then true 
            else false 
        end as is_meta_page
    from cte_all_prefixs
)

select 
    datehour,
    title,
    views,
    src,
    date, 
    day_of_week,
    hour_of_day,
    is_meta_page,
    case 
        when is_meta_page is true then prefix 
        else null
    end as meta_page_type
from cte_is_meta_page
