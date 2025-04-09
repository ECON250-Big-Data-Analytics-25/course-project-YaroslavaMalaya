{{ config(materialized='table') }}

with cte_unnest_items as (
    select 
        order_id,
        date_trunc(order_purchase_at, month) as order_month,
        item.product_category_name,
        item.price,
        item.freight_value
    from {{ ref('int_fp_sales_full') }},
    unnest(items) as item
    where order_status != 'canceled'
),

cte_order_performance as (
    select 
        order_month,
        product_category_name,
        count(order_id) as total_orders,
        round(sum(price + freight_value), 2) as total_revenue
    from cte_unnest_items
    group by order_month, product_category_name
    order by order_month asc
)

select * from cte_order_performance

