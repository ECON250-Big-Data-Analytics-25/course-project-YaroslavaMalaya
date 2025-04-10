
select  
* ,
concat( transaction.transactionId, cast(transaction.transactionRevenue as string))  as  _surrogate_key
from {{ source('test_dataset', 'week5_web_transactions')}}
where transaction.transactionRevenue is not null
