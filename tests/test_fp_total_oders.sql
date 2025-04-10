with cte_actual as (
    select 
        count(distinct customer_unique_id) as total_customers
    from {{ ref('int_fp_sales_full') }}
    where order_status != 'canceled' and array_length(payments) > 0
),

cte_compare as (
    select 
        count(customer_unique_id) as total_customers
    from {{ ref('fct_fp_customer_behaviour_analysis') }}
)

select * from cte_actual
except distinct
select * from cte_compare
