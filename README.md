# "Amazon E-Commerce Data Optimization: Cleaning, Analysis & Insights"

![](https://github.com/Palak019/AMAZON-ADVANCE-SQL-PROJECT-/blob/main/logo.png)

## DATA CLEANING
📌 1. Handling Missing Values

      Replace missing return_date in shipping.csv with "Not Returned".

📌 2. Removing Orphaned Data

      Delete order_items where order_id does not exist in orders.
      
      Delete orders where seller_id does not exist in sellers.
      
📌 3. Removing Duplicates

      Normalize Customers & Maintain Order Integrity

## Handling Missing Values

```sql
ALTER TABLE shippings ADD COLUMN returned_status VARCHAR(30);

UPDATE shippings 
SET returned_status = CASE 
    WHEN return_date IS NOT NULL THEN TO_CHAR(return_date, 'YYYY-MM-DD')  
    ELSE 'Not Returned' 
END;
```

✅ Why?

Ensures consistency in the shippings table by filling missing values

Provides a clear return status for analysis and reporting.

Prevents errors when querying returned_status.

✅ What Do We Get?

A column (returned_status) that clearly indicates if an item was returned or not.

Better data quality for dashboards and reports.

## Removing Orphaned Data

```sql
DELETE FROM orders 
WHERE customer_id NOT IN (SELECT customer_id FROM customers);

DELETE FROM orders 
WHERE seller_id NOT IN (SELECT seller_id FROM sellers);
```

✅ Why?

Ensures referential integrity—every order must belong to a valid customer and seller.

Prevents errors in joins and incorrect reports.

Reduces unnecessary storage of invalid data.

✅ What Do We Get?

A clean, reliable orders table without missing references.

Ensures that all orders are linked to existing customers and sellers.

## Removing duplicate Data
Reassign the orders to the lowest customer_id and then delete the duplicate customers:
  
```sql
WITH duplicate_customers AS (
    SELECT customer_id, 
           MIN(customer_id) OVER (PARTITION BY first_name, last_name, state) AS kept_customer_id,
           ROW_NUMBER() OVER (PARTITION BY first_name, last_name, state ORDER BY customer_id) AS row_num
    FROM customers
)

UPDATE orders
SET customer_id = duplicate_customers.kept_customer_id
FROM duplicate_customers
WHERE orders.customer_id = duplicate_customers.customer_id
AND duplicate_customers.row_num > 1;
```

After updating orders, delete the duplicate customers:

```sql
WITH duplicate_customers AS (
    SELECT customer_id, 
           MIN(customer_id) OVER (PARTITION BY first_name, last_name, state) AS kept_customer_id,
           ROW_NUMBER() OVER (PARTITION BY first_name, last_name, state ORDER BY customer_id) AS row_num
    FROM customers
)
DELETE FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM duplicate_customers WHERE row_num > 1
);
```
✅ Why?

Removes unnecessary duplicate customer records after reassigning orders.

Ensures the database stays clean and optimized.

Prevents duplicate customer entries from affecting customer analytics.

✅ What Do We Get?

A deduplicated customers table, improving performance and data reliability.

More accurate customer data for business insights and marketing analysis.

