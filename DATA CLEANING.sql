-- DATA CLEANING

--Handling Missing Values
ALTER TABLE shippings ADD COLUMN returned_status VARCHAR(30);

UPDATE shippings 
SET returned_status = CASE 
    WHEN return_date IS NOT NULL THEN TO_CHAR(return_date, 'YYYY-MM-DD')  
    ELSE 'Not Returned' 
END;

--Removing Orphaned Data

DELETE FROM orders 
WHERE customer_id NOT IN (SELECT customer_id FROM customers);

DELETE FROM orders 
WHERE seller_id NOT IN (SELECT seller_id FROM sellers);

--Removing duplicate Data
  --reassign the orders to the lowest customer_id and then delete the duplicate customers:
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

--After updating orders, delete the duplicate customers:
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
