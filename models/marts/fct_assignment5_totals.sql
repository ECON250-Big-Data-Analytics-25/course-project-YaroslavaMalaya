{{
    config(
        materialized = 'incremental',
        incremental_strategy = "insert_overwrite",
        partition_by = {
            "field": "date_day",
            "data_type": "date"
        }
    )  
}}

select
    cast(datehour as date) as date_day,
    title,
    sum(views) as views_sum,
    current_timestamp() as insert_time
from {{ source('test_dataset', 'assignment5_input')}}

{% if is_incremental() %}
    where cast(datehour as date) >= _dbt_max_partition - 1
{% endif %}

group by date_day, title
