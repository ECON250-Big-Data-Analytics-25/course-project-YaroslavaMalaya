select 
    distinct country_name, 
    region, 
    `sub-region`, 
    max(term) as max_term
from {{ source('google_trends', 'international_top_terms')}}
left join {{ ref('seed_country_info') }} on country_name = name
where refresh_date = "2025-03-13" and week = "2025-03-09"
group by 1,2,3
