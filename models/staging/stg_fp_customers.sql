select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix as customer_zip_prefix,
    coalesce(customer_city, 'missing') as customer_city,
    coalesce(customer_state, 'missing') as customer_state
from {{ source('ymala', 'fp_customers')}}
