select
    product_category_name as product_category_name_portuguese,
    product_category_name_english
from {{ source('ymala', 'fp_product_category_name_translation')}}
