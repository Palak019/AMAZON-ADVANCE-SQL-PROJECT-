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
