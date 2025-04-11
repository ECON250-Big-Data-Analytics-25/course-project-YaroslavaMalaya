{{ config(materialized='table') }}

with cte_unnest_payments as (
  select 
    order_id,
    order_purchase_at,
    customer_unique_id,
    payment.payment_value
  from {{ ref('int_fp_sales_full') }},
  unnest(payments) as payment
  where order_status != 'canceled'
),

cte_customer as (
  select 
    customer_unique_id,
    round(sum(payment_value), 2) as total_revenue,
    if(count(distinct order_id) = 1, true, false) as new_customer,
    count(distinct order_id) as purchase_frequency,
    max(order_purchase_at) as last_purchase_at
  from cte_unnest_payments
  group by customer_unique_id
  order by purchase_frequency desc
)

select * from cte_customer