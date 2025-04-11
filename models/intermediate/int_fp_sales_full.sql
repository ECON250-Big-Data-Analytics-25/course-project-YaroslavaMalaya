{{ 
    config(
        materialized='table',
        partition_by = {
            "field": "order_purchase_at",
            "data_type": "datetime"
        },
        cluster_by=[ 'order_id', 'customer_id', 'is_delivered']
        ) 
}}

with cte_order_customer as (
    select 
        orders.order_id,
        orders.customer_id,
        customers.customer_unique_id,
        customers.customer_city,
        customers.customer_state,
        orders.order_status,
        orders.is_delivered,
        orders.order_purchase_at,
        orders.order_approved_at,
        orders.order_delivered_carrier_date,
        orders.order_delivered_customer_date,
        orders.order_estimated_delivery_date,
        orders.approve_time_days,
        orders.delivery_time_days
    from {{ ref("stg_fp_orders" )}} orders
    left join  {{ ref('stg_fp_customers') }} customers using(customer_id)
),

cte_order_item_full as (
    select
        items.order_id,
        items.order_item_position,
        items.product_id,
        products.product_category_name,
        translate.product_category_name_english,
        products.product_weight_g,
        items.seller_id,
        sellers.seller_city,
        sellers.seller_state,
        items.price,
        items.freight_value,
        items.shipping_limit_date
    from {{ ref('stg_fp_order_items') }} items
    left join {{ ref('stg_fp_sellers') }} sellers using(seller_id)
    left join {{ ref('stg_fp_products') }} products using(product_id)
    left join {{ ref('stg_fp_product_category_name_translation') }} translate
        on products.product_category_name = translate.product_category_name_portuguese
),

cte_order_items as (
    select 
        order_id,
        array_agg(
            struct(
                order_item_position,
                product_id,
                product_category_name,
                product_category_name_english,
                product_weight_g,
                seller_id,
                seller_city,
                seller_state,
                price,
                freight_value,
                shipping_limit_date
            ) order by order_item_position asc
        ) as items
    from cte_order_item_full
    group by order_id
),

cte_order_payment as (
    select 
        order_id,
        array_agg(
            struct(
                payment_sequential,
                payment_type,
                payment_installments,
                payment_value
            ) order by payment_sequential asc
        ) as payments
    from {{ ref('stg_fp_order_payments') }}
    group by order_id
),

cte_order_full as (
    select 
        orders.*,
        payments.payments,
        items.items,
    from cte_order_customer orders
    left join cte_order_payment payments using(order_id)
    left join cte_order_items items using(order_id)
)

select  * from cte_order_full
