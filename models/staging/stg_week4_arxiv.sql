select
    date_trunc(published_date, month) as published_month,
    regexp_replace(id, r'^\w+-', "https://arxiv.org/abs/") as url,

    json_query_array(authors) as json_authors,

    split(regexp_replace(authors, r"\'|\[|\]", ""), ', ') as split_authors,
*
from {{ source('ymala', 'week3_arxiv')}} limit 1000