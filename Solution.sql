SET GLOBAL sql_mode = 'ONLY_FULL_GROUP_BY';

select @@GLOBAL.sql_mode;

/*
Task 1: Understanding the data in hand
A. Describe the data in hand in your own words. (Word Limit is 500)
	1. cust_dimen: information about the customers of the superstore
		
        Customer_Name (TEXT): Name of the customer
        Province (TEXT): Province of the customer
        Region (TEXT): Region of the customer
        Customer_Segment (TEXT): Segment of the customer
        Cust_id (TEXT): Unique Customer ID
	
    2. market_fact: market facts for all the products customers and orders
		
        Ord_id (TEXT): Order ID
        Prod_id (TEXT): Prod ID
        Ship_id (TEXT): Shipment ID
        Cust_id (TEXT): Customer ID
        Sales (DOUBLE): Sales from the Item sold
        Discount (DOUBLE): Discount on the Item sold
        Order_Quantity (INT): Order Quantity of the Item sold
        Profit (DOUBLE): Profit from the Item sold
        Shipping_Cost (DOUBLE): Shipping Cost of the Item sold
        Product_Base_Margin (DOUBLE): Product Base Margin on the Item sold
        
    3. orders_dimen: all the details of orders
		
        Order_ID (INT): Order ID
        Order_Date (TEXT): Order Date
        Order_Priority (TEXT): Priority of the Order
        Ord_id (TEXT): Unique Order ID
	
    4. prod_dimen: details about all the products available in the superstore
		
        Product_Category (TEXT): Product Category
        Product_Sub_Category (TEXT): Product Sub Category
        Prod_id (TEXT): Unique Product ID
	
    5. shipping_dimen: shipping details
		
        Order_ID (INT): Order ID
        Ship_Mode (TEXT): Shipping Mode
        Ship_Date (TEXT): Shipping Date
        Ship_id (TEXT): Unique Shipment ID


*/


-- B. Identify and list the Primary Keys and Foreign Keys for this dataset

-- 1. cust_dimen - Cust_id as Primary Key, no foreign key
-- 2. prod_dimen - Prod_id as Primary Key, no foreign key 
-- 3. orders_dimen - Ord_id as Primary Key, no foreign key
-- 4. shipping_dimen - Shipping id as primary key and Order_ID as foreign key.
-- 5. market_fact - Ord_id, Prod_id, Ship_id and Cust_id as foreign key. No Primary Key.

-- Task 2: Basic Analysis

-- A. Find the total and the average sales (display total_sales and avg_sales)

select sum(Sales) as total_sales, avg(Sales) as avg_sales
from market_fact;

-- B. Display the number of customers in each region in decreasing order of no_of_customers. The result should contain columns Region, no_of_customers

select Region , count(*) as no_of_customers
from cust_dimen
group by Region
order by no_of_customers desc;

-- C. Find the region having maximum customers (display the region name and max(no_of_customers)

select Region , count(*) as no_of_customers
from cust_dimen
group by Region
order by no_of_customers desc
LIMIT 1;

-- D. Find the number and id of products sold in decreasing order of products sold (display product id, no_of_products sold)

select Prod_id as product_id, sum(Order_Quantity) as no_of_products_sold
from market_fact
group by Prod_id
order by no_of_products_sold DESC;

-- E. Find all the customers from Atlantic region who have ever purchased ‘TABLES’ and the number of tables purchased (display the customer name, no_of_tables purchased)

select c.Customer_Name as customer_name, sum(m.Order_Quantity) as no_of_tables_purchased
from market_fact m join cust_dimen c on m.Cust_id = c.Cust_id join prod_dimen p on m.Prod_id = p.Prod_id
where c.Region = "ATLANTIC" and p.Product_Sub_Category = "TABLES"
group by c.Customer_Name
Order by sum(m.Order_Quantity) DESC;


-- Task 3: Advanced Analysis

-- A. Display the product categories in descending order of profits (display the product category wise profits i.e. product_category, profits)

select p.Product_Category as product_category , sum(m.Profit) as profits
from market_fact m join prod_dimen p on m.Prod_id = p.Prod_id
group by p.Product_Category
order by sum(m.Profit) desc;

-- B. Display the product category, product sub-category and the profit within each subcategory in three columns.

select p.Product_Category, p.Product_Sub_Category , sum(m.Profit) as Profit
from market_fact m join prod_dimen p on m.Prod_id = p.Prod_id
group by p.Product_category,p.Product_Sub_Category
order by sum(m.Profit) desc;

--  C.Where is the least profitable product subcategory shipped the most? For the least
--  profitable product sub-category, display the region-wise no_of_shipments and the
--  profit made in each region in decreasing order of profits (i.e. region,
--  no_of_shipments, profit_in_each_region)

select c.Region as region, count(m.Ship_id) as no_of_shipments, 
		sum(m.Profit) as profit_in_each_region
from market_fact m 
		join cust_dimen c on m.Cust_id = c.Cust_id
        join prod_dimen p on m.Prod_id = p.Prod_id
Where Product_Sub_Category = (
				Select p.Product_Sub_Category 
				from market_fact m 
					join prod_dimen p on m.Prod_id = p.Prod_id
					group by Product_Sub_Category
					order by sum(m.Profit)
					LIMIT 1) 
group by c.Region
order by sum(m.Profit) desc;