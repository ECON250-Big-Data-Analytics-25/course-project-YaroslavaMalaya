{{
  config(
    materialized = 'table'
    )
}}

with cte_orders as (
    select visitId, hitNumber, transaction, product
    from {{ source('test_dataset', 'week5_web_transactions') }}
    where transaction.transactionRevenue is not null
),
cte_visits as (
    select date, fullvisitorId, visitId, operatingSystem, deviceCategory
    from {{ source('test_dataset', 'week5_web_visits') }} 
    where visitId in (select visitid, from cte_orders)
),
cte_hits as (
    select
    date,
    visitId,
    array_agg(struct( hitNumber,
    page.pagePath,
    eventInfo,
    TRANSACTION,
    cte_orders.product )
    order by hitNumber) as hit_info
    from {{ source('test_dataset', 'week5_hits') }}
    left join cte_orders using(visitId, hitNumber)
    group by date, visitId
)

select * from cte_visits
left join cte_hits using(date, visitId)