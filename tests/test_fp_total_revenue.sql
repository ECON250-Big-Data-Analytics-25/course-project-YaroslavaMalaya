with cte_actual as (
    select 
        round(sum(item.price + item.freight_value), 2) as total_revenue
    from `ymala.int_fp_sales_full`,
    unnest(items) as item
    where order_status != 'canceled'
),

cte_compare as (
    select 
        round(sum(total_revenue), 2) as total_revenue
    from `ymala.fct_fp_order_performance_analysis`
)

select * from cte_actual
except distinct
select * from cte_compare
