{{ config(materialized='ephemeral') }}

SELECT 
*,
date_diff(updated_date, published_date, day) as days_until_updated,
if (published_date != updated_date, 1, 0) as is_updated,
if (
  summary like '%GPT%'
  or summary like '%LLM%',
  1, 0
) as is_llm_related
FROM {{ ref("stg_week4_arxiv") }}
order by id, published_date
