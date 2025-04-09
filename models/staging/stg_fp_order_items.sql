select
    order_id,
    order_item_id as order_item_position,
    product_id,
    seller_id,
    cast(shipping_limit_date as datetime) as shipping_limit_date,
    coalesce(price, 0) as price,
    freight_value
from {{ source('ymala', 'fp_order_items')}}
