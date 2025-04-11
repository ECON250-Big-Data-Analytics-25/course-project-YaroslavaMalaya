# Final Project Overview

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
