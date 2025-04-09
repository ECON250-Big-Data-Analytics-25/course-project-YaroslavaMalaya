select
    order_id,
    payment_sequential,
    coalesce(payment_type, 'missing') as payment_type,
    payment_installments,
    coalesce(payment_value, 0) as payment_value
from {{ source('ymala', 'fp_order_payments')}}
