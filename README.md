Welcome to your new dbt project!

# Installation

The following tutorial assumes you're already familiar with git and command line usage.

## Getting the code to your local machine
1. Fork this github repository into your local account

2. Copy it to your local machine: `git clone https://github.com/your_account_name/econ250_2025.git`



## gcloud authentication

To run queries from your command line, you'll first need to install `gcloud` utility.

Follow the instructions here: https://cloud.google.com/sdk/docs/install. After installation you should have `gcloud` command available for running in the terminal.

Now, try to authenticate with your **kse email** using the following command: 

```bash
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/bigquery,\
https://www.googleapis.com/auth/drive.readonly,\
https://www.googleapis.com/auth/iam.test,\
https://www.googleapis.com/auth/cloud-platform
```

Now, when you run the following commands something similar should be response: 

```bash
$ gcloud auth list

     Credentialed Accounts
ACTIVE  ACCOUNT
*       o_omelchenko@kse.org.ua

```
To set the active project, run the following: 

```bash
gcloud config set project econ250-2025
```


## venv and libraries
Prerequisites: having Python installed on your machine. 
Following instructions are for Linux or WSL; if you'd like to run Windows - please refer to the documentation below.

```bash

# change directory to the one you just copied from github
cd econ250_2025 

# create and activate venv
python3 -m venv env 
source env/bin/activate

pip install -r requirements.txt

```

If everything is installed correctly, you should run the following commands successfully: 


```
$ dbt --version

Core:
  - installed: 1.9.3
  - latest:    1.9.3 - Up to date!

Plugins:
  - bigquery: 1.9.1 - Up to date!
```


For more detailed reference, refer to the official documentation here: 
- https://docs.getdbt.com/docs/core/pip-install
- https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup#local-oauth-gcloud-setup

## Adjusting the configuration

You'll need to specify your own dataset to save your models to. To do so, navigate to the `profiles.yml` in the root directory of the project, and replace `o_omelchenko` with your bigquery dataset name with which you have been working previously.




## Final check

Try running the following command:
- dbt run

If everything is set up well, you will see similar output: 

```log
❯ dbt run
01:18:56  Running with dbt=1.9.3
01:18:57  Registered adapter: bigquery=1.9.1
01:18:57  Found 2 models, 4 data tests, 491 macros
01:18:57  
01:18:57  Concurrency: 2 threads (target='dev')
01:18:57  
01:19:00  1 of 2 START sql table model o_omelchenko.my_first_dbt_model ................... [RUN]
01:19:04  1 of 2 OK created sql table model o_omelchenko.my_first_dbt_model .............. [CREATE TABLE (2.0 rows, 0 processed) in 4.44s]
01:19:04  2 of 2 START sql view model o_omelchenko.my_second_dbt_model ................... [RUN]
01:19:06  2 of 2 OK created sql view model o_omelchenko.my_second_dbt_model .............. [CREATE VIEW (0 processed) in 2.13s]
01:19:06  
01:19:06  Finished running 1 table model, 1 view model in 0 hours 0 minutes and 9.64 seconds (9.64s).
```

If you have any troubles with installation, please contact the course instructor (Oleh Omelchenko) in slack for assist.

# Final Project Overview

## Part 1: Data Importing to Google BigQuery

For this part, I downloaded all the necessary data files from the https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce.  
Then, I uploaded the CSV files into my BigQuery dataset `ymala` as separate tables:
- fp_customers
- fp_order_items
- fp_order_payments
- fp_orders
- fp_products
- fp_sellers
- fp_product_category_name_translation

For most of the files I used auto detect schema. However, for `product_category_name_translation.csv` the auto-detected schema was incorrect, so I manually defined the schema and set **Header rows to skip = 1** to exclude the header row.  
As a result, all source tables were successfully added.

## Part 2: Source Definitions in dbt

For this part, I created `fp_sources.yml` and added all source tables. I provided comprehensive documentation for each table and key columns using descriptions from the Kaggle website. Also, for some fields I use such data_tests:
- `not_null` - for all primary key and foreign key
- `unique` - for unique identifiers
- `relationships:  to: source(...)  field: ...` - to  test foreign key relationships
- `config: where: ... > 0` - for numerical fields where values should be positive (since the dataset represents sales, those filds are **payment_value** and **price**)

## Part 3: Staging models in dbt

For this part, to implement appropriate data cleaning logic, firslty I analyzed columns for each table in Kaggle. I noticied that we have missing values in tables `fp_orders` and `fp_products`. Also, since for us is important to handle also categorical columns, I decided that they also need to be cleaned. I implemented the following stg models:

1. **stg_fp_customer**  
   Applied `coalesce(..., 'missing')` to or customer_city and customer_state

2. **stg_fp_order_item**  
   Applied `cast(... as datetime)` to shipping_limit_date and `coalesce(..., 0)` for price

3. **stg_fp_oder_payments**  
   Applied `coalesce(..., 'missing')` to payment_type and `coalesce(..., 0)` to payment_value

4. **stg_fp_oders**  
   Applied `coalesce(..., 'missing')` to order_status  
   Cast all timestamps to datetime as `cast(... as datetime)` for order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date and order_estimated_delivery_date  
   Also used`coalesce(..., ...)` for order_approved_at, order_delivered_carrier_date and order_delivered_customer_date to fill missing timestamp fields with fallback values
   Also added 2 derived columns as **is_delivered** with booleans values, **approve_time_days** - days between purchase and approval **delivery_time_days** - dys between purchase and actual delivery

5. **stg_fp_product_category_name_translation**  
   Renamed product_category_name to product_category_name_portuguese

6. **stg_fp_products**  
   Applied `coalesce(..., 'missing')` to payproduct_category_name and `coalesce(..., 0)` to product_name_length, product_description_length, product_photos_quantity, product_weight_g, product_length_cm, product_height_cm and product_width_cm

7. **stg_fp_sellers**  
   Applied `coalesce(..., 'missing')` for seller_city and seller_state

## Part 4: Integrated Data Model

For this part, to combine the information from all separate source tables into a single model I decide to use cte. In that way I can combine all tables step by step and avoid comprehensive query with sub-selects and joins

Overview of each cte:

1. **cte_order_customer**  
   Firstly, `left join` information about customer to order table. As a result in each order we have customer information such as *customer_unique_id*, *customer_city* and *customer_state*

2. **cte_order_item_full**  
   Here `left join` information from 4 tables. For each item in order added:
   - information regarding seller such as *seller_city* and *seller_state*
   - information about product such as *product_category_name*, *product_weight_g* and *product_volume_cm3*
   - transaltion to english as *product_category_name_english*

3. **cte_order_items**  
   Here I aggregated data of iteam for each order_id using `array_agg` and `struct` and ordering items based on their *order_item_position*

4. **cte_order_payment**  
   Here I aggregated data of payment for each order_id using `array_agg` and `struct` and ordering payment based on their *payment_sequential*

5. **cte_order_full**  
   The last `left join` of **cte_order_customer**, **cte_order_payment** and **cte_order_items**

In result, we have data granularity: order-level that contains all information about order.  
For partitioning I decided to use `order_purchase_at` field to improve query for time-based sorting/filtering.   
For clustering I decided to select `order_id`, `customer_id`, `is_delivered`. These fields are mostly used in joins, filters and aggregations.

## Part 5: Analytical Mart Models

For this part, I implemented the following analytical models:

**fct_fp_order_performance_analysis** - provides monthly order metrics, including the number of orders and total revenue, grouped by product category name
- in `cte_unnest_items`firstly I unnested items array and extracted the month from **order_purchase_at** using `date_trunc`. I also excluded orders with `canceled` status
- in `cte_order_performance` I calculated: 
   - total_orders as `count(distinct order_id)`
   - total_revenu as `sum(price + freight_value)`
   - and grouped by **order_month** and **product_category_name**

**fct_fp_customer_behaviour_analysis** - show new vs. returning customers, their purchase frequency, customer lifetime value, and the last purchase date
- in `cte_unnest_payments` firstly I unnested payments array and excluded `canceled` orders
- in `cte_customer` I calculated:
   - total_revenu as `sum(payment_value)``
   - checked new_customer if they have one order such as `if(count(distinct order_id) = 1, true, false)` 
   - purchase_frequency as `count(distinct order_id)` 
   - last purchase as `max(order_purchase_at)`
   - and grouped by **customer_unique_id** and ordered by **purchase_frequency**

**fct_fp_product_performance** - shows the top 10 products per month based on the number of orders.
- in `cte_unnest_items` firstly I unnested items array and extracted the month from **order_purchase_at** using `date_trunc`. I also excluded orders with `canceled` status
- in `cte_top_products_month` I calculated:
   - total_orders as `count(distinct order_id)`
   - total_revenu as `sum(pric)` 
   - position in top by total_orders as `row_number() over (partition by order_month order by count(order_id) desc)`
   - and grouped by **order_month**, **product_id** and **product_category_name**, **seller_id**
   - filtered to keep only top 10 products per month using `where top_number <= 10`

## Part 6: Testing and Documentation

For this part, I created two custom tests:

**test_fp_total_orders**  
Validates that the total number of orders (excluding canceled) in the `int_fp_sales_full` model is equal to the total number of purchases aggregated in the `fct_fp_customer_behaviour_analysis` model

**test_fp_total_revene**  
Validates that the total revenue calculated in `int_fp_sales_full` (by summing all payment_value fields) matches the total revenue calculated in `fct_fp_order_performance_analysis`

