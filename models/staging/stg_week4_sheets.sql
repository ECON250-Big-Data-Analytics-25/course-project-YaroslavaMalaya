select 
    upper(campaign_id) as campaign_upper,
    trim(regexp_replace(trim(initcap(influencer_name)),r"\W"," ")) name_fix,
    case 
        when platform in ('tiktok', 'TikTok','tik tok') then 'TikTok'
        when lower(platform) in ('instagram', 'ig') then 'Instagram'
        when lower(platform) in ('youtube','yt') then 'Youtube'
        else platform
    end platform_fix,
    safe_cast(regexp_replace(cost, r'\D', '') as int64) as cost_int,
    case 
        when 
            impressions like '%M'or impressions like '%m' then
            safe_cast(regexp_replace(impressions, r'\D', '') as int64) * 100000
        when 
            impressions like '%K'or impressions like '%k' then
            safe_cast(regexp_replace(impressions, r'\D', '') as int64) * 1000
        else
            safe_cast(regexp_replace(impressions, r'\D', '') as int64) 
    end as impr_int,
    case 
        when regexp_contains(date, r'^\d{2}/\d{2}/\d{2}$') then parse_date('%x', date) 
        when regexp_contains(date, r'^\d{2}/\d{2}/\d{4}$') then parse_date('%m/%d/%Y', date) 
        when regexp_contains(date, r'^\d{4}/\d{2}/\d{2}$') then parse_date('%Y/%m/%d', date)
        when regexp_contains(date, r'^\d{4}-\d{2}-\d{2}$') then parse_date('%Y-%m-%d', date)
        when regexp_contains(date, r'^\d{2}-\d{2}-\d{4}$') then safe.parse_date('%d-%m-%Y', date)
        else null
    end as parsed_date,
* from {{source('ymala', 'sheet_external')}}
qualify row_number() over(partition by campaign_upper) = 1

