{{ config(materialized='table') }}

with cte_unnest_items as (
  select 
    order_id,
    date_trunc(order_purchase_at, month) as order_month,
    item.product_id,
    item.product_category_name,
    item.seller_id,
    item.price
  from {{ ref('int_fp_sales_full') }},
  unnest(items) as item
  where order_status != 'canceled'
),

cte_top_products_month as (
  select 
    order_month,
    product_id, 
    product_category_name,
    seller_id,
    count(order_id) as total_orders,
    round(sum(price), 2) as total_revenue,
    row_number() over (partition by order_month order by count(order_id) desc) as top_number
  from cte_unnest_items
  group by order_month, product_id, product_category_name, seller_id
  order by order_month
)

select * from cte_top_products_month 
where top_number <= 10
