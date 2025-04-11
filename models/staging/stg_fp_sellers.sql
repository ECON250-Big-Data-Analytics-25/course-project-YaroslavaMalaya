select
    seller_id,
    seller_zip_code_prefix as seller_zip_prefix,
    coalesce(seller_city, 'missing') as seller_city,
    coalesce(seller_state, 'missing') as seller_state
from {{ source('ymala', 'fp_sellers') }}
