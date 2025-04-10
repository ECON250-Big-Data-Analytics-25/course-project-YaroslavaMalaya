select
    order_id,
    customer_id,
    coalesce(order_status, 'missing') as order_status,
    if(lower(order_status) = 'delivered', true, false) as is_delivered,
    cast(order_purchase_timestamp as datetime) as order_purchase_at,
    coalesce(cast(order_approved_at as datetime), cast(order_purchase_timestamp as datetime)) as order_approved_at,
    coalesce(cast(order_delivered_carrier_date as datetime), cast(order_purchase_timestamp as datetime)) as order_delivered_carrier_date,
    coalesce(cast(order_delivered_customer_date as datetime), cast(order_estimated_delivery_date as datetime)) as order_delivered_customer_date,
    cast(order_estimated_delivery_date as datetime) as order_estimated_delivery_date,
    coalesce(datetime_diff(order_approved_at, order_purchase_timestamp, day), 0) as approve_time_days,
    coalesce(datetime_diff(order_delivered_customer_date, order_purchase_timestamp, day), 0) as delivery_time_days
from {{ source('ymala', 'fp_orders')}}
