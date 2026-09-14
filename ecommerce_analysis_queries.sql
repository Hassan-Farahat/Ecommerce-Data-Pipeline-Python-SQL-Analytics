-- Switch database context to master 
--and retrieve all cataloged table names 
--from the system information schema views
use master
select TABLE_NAME
from INFORMATION_SCHEMA.TABLES





-- Switch context to the Ecommerce database
--and retrieve all table names 
--from the system information schema views
use Ecommerce
select table_name
from INFORMATION_SCHEMA.TABLES





-- Query and retrieve all records and columns 
--from the payments table 
--within the Ecommerce database dbo schema
select * from Ecommerce.dbo.payments


select top 5 * from payments
 
select top 5* from customers





-- List all unique cities where customers are located.

--First, take a look at the table columns.
select column_name
from information_schema.columns 
where table_name = 'customers'

--The answer.
select distinct customer_city from customers





--Count the number of orders placed in 2017.

--First, take a look at the table columns.
select column_name from information_schema.columns 
where table_name='orders'

--The answer.
select count(order_id) from orders 
where Year(order_purchase_timestamp)=2017





--Find the total sales per category.

--First, take a look at the tables i have.
select table_name from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE = 'base table'

--Take a look at the columns in products table.
select column_name from information_schema.columns
where table_name = 'products'

--Take a look at the columns in payments table.
select column_name from information_schema.columns
where table_name = 'payments'

--Take a look at the columns in order_items table.
select column_name from information_schema.columns
where table_name = 'order_items'

--The answer.
select upper(products.[product category]) Category,
round(sum(payments.payment_value),2) Sales 
from products
join
order_items
on 
products.product_id = order_items.product_id
join
payments
on
payments.order_id = order_items.order_id
group by 
products.[product category]
order by Sales desc




--Calculate the percentage of orders that were paid in installments.

--First, take a look at the table columns.
select column_name from information_schema.columns
where table_name = 'payments'
--The answer.
select 
(sum(case when payment_installments>=1 then 1 else 0 end)
/count(*))*100
from payments
--This returns 0 because of Integer Division in SQL Server. 
--In SQL Server, when i divide an integer by another integer,
--SQL Server truncates the result to an integer. 
--Since the numerator(count of installment payments)
--is smaller than the denominator(COUNT(*)), 
--the actual decimal result is rounded down to 0.
--Force decimal division by multiplying numerator by 1.0
select 
(sum(case when payment_installments >=1 then 1.0 else 0 end)
/count(*))*100
from payments





--Count the number of customers from each state.

--First, take a look at the customers table columns.
select column_name from INFORMATION_SCHEMA.columns
where TABLE_NAME='customers'

--The answer.
select customer_state as State,count(customer_id) as "Customer Count"
from customers
group by customer_state
order by [Customer Count] desc




--Calculate the number of orders per month in 2018.

--First, take a look at the orders table columns.
select column_name from INFORMATION_SCHEMA.columns
where TABLE_NAME='orders'

--The answer.
select datename(MONTH,order_purchase_timestamp) Months,count(order_id) "Order Count"
from orders
where YEAR(order_purchase_timestamp)=2018
group by datename (month,order_purchase_timestamp),
MONTH(order_purchase_timestamp)
order by MONTH(order_purchase_timestamp)




--Find the average number of products per order, 
--grouped by customer city.

--The answer.
with count_per_order as (
select orders.order_id,orders.customer_id,count(order_items.order_id)*1.0 oc
from orders join order_items
on orders.order_id = order_items.order_id
group by orders.order_id,orders.customer_id
)

select top 10 customers.customer_city,cast(AVG(count_per_order.oc) as decimal(10,2)) average_orders
from customers join count_per_order
on customers.customer_id = count_per_order.customer_id
group by customers.customer_city order by average_orders desc




--Calculate the percentage of total revenue
--contributed by each product category.

--First, take a look at the products table columns.
select column_name from information_schema.columns
where table_name = 'products'

--The answer.
select top 5 upper("product category") Category,
round((sum(payment_value)/(select sum(payment_value) from payments))*100,2) sales_percentage
from products join order_items
on products.product_id = order_items.product_id
join payments on payments.order_id = order_items.order_id
group by UPPER("product category")
order by sales_percentage desc,Category asc




--Identify the correlation between product price
--and the number of times a product has been purchased.
/*
STEP 1: Data Preparation (Matching the Python DataFrame)
i use a Common Table Expression (CTE) to aggregate the underlying 
transaction data up to the Category level before performing any math.
*/
with CategoryMetrics as (
select "product category",
-- Multiply by 1.0 to force the integer count into a decimal format. 
-- This prevents SQL Server from dropping decimal precision later.
count(products.product_id)*1.0 as order_count,
-- Cast price to FLOAT and round to 2 decimals to perfectly replicate 
-- the exact values generated by the Pandas DataFrame in Python.
round(avg(cast(order_items.price as float)),2) as price
from products
join order_items on products.product_id = order_items.product_id
group by "product category"
)
/* 
STEP 2: Statistical Calculation (Replacing np.corrcoef)
Since SQL Server lacks a native CORR() function, i derive the Pearson 
Correlation Coefficient using the standard statistical formula: 
Covariance(X,Y) / (StdDev(X) * StdDev(Y))
*/
select 
-- Numerator (Covariance): How the two variables move together
(AVG(order_count*price)-(AVG(order_count)*AVG(price)))
/
-- Denominator: The product of their Population Standard Deviations (STDEVP)
(STDEVP(order_count)*STDEVP(price)) correlation
from CategoryMetrics




--Calculate the total revenue generated by each seller, 
--and rank them by revenue.
select table_name from INFORMATION_SCHEMA.TABLES

select column_name from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='payments' --the column i want called "payment_value"

select column_name from INFORMATION_SCHEMA.columns
where TABLE_NAME='sellers' -- i will need seller_id column

select *,dense_rank() over(order by revenue desc) rn
from
(select seller_id, sum(payment_value) revenue
from order_items join payments
on order_items.order_id = payments.order_id
group by seller_id) a




--Calculate the moving average of order values 
--for each customer over their order history.
with customer_payments as(
select o.customer_id,
o.order_purchase_timestamp,
p.payment_value  payment
from orders o join payments p
on o.order_id = p.order_id
)
select customer_id, order_purchase_timestamp, payment,
AVG(payment) over(
partition by customer_id
order by order_purchase_timestamp
rows between 2 preceding and current row
)moving_average
from customer_payments
order by customer_id, order_purchase_timestamp




--Calculate the cumulative sales per month for each year.
with monthly_sales as(
select year(o.order_purchase_timestamp) years,
month(o.order_purchase_timestamp) months, 
round(sum(p.payment_value),2) payment
from
orders o join payments p
on
o.order_id = p.order_id
group by
year(o.order_purchase_timestamp),
month(o.order_purchase_timestamp)
)
select years,months,payment,
sum(payment) over(order by years,months)cumulative_sales
from monthly_sales
order by years,months


SELECT 
    years,
    ((payment - LAG(payment) OVER (ORDER BY years))
    / LAG(payment) OVER (ORDER BY years)) * 100 AS percentage_change
FROM (
    SELECT 
        YEAR(orders.order_purchase_timestamp) AS years,
        ROUND(SUM(payments.payment_value), 2) AS payment
    FROM orders
    JOIN payments
        ON orders.order_id = payments.order_id
    GROUP BY YEAR(orders.order_purchase_timestamp)
) AS a;

--Added indexes to reduce query execution time 
--create index ix_payments_order_id
--on
--payments(order_id)
--create index ix_orders_order_id
--on
--orders(order_id)
--This error occurs
--#because SQL Server cannot build an index on a VARCHAR(MAX) or NVARCHAR(MAX) column,
--#which is the default type Pandas uses when importing text columns into SQL Server.
--⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️



--Check maximum character length of order_id in both tables
--to select a safe size for VARCHAR before creating indexes.
select 'orders' as table_name, max(len(order_id)) max_char_length
from orders
union all
select 'payments' as table_name, max(len(order_id)) max_char_length
from payments
--Both tables max out at 32 characters


--Resize order_id columns to a fixed, indexable length
alter table orders alter column order_id varchar(50) not null
alter table payments alter column order_id varchar(50) not null
--Verify changes.
select column_name, data_type, character_maximum_length 
from INFORMATION_SCHEMA.COLUMNS
where COLUMN_NAME='order_id' and table_name in ('orders','payments')

--Create performance indexes
--create index ix_orders_order_id on orders(order_id)
--create index ix_payments_order_id on payments(order_id)


--Query SQL Server system catalog views (sys.indexes and sys.tables)
--to verify that the newly created non-clustered indexes exist
--on the 'orders' and 'payments' tables.
select 
t.name as table_name,
i.name as index_name,
i.type_desc as index_type
from sys.indexes i
join sys.tables t on i.object_id = t.object_id
where t.name in ('orders','payments') and i.name is not null




--Calculate Year-over-Year (YoY) revenue growth percentage by joining orders 
--and payments, using LAG window function to compare each year against the previous.
WITH yearly_payments AS (
    SELECT 
        YEAR(o.order_purchase_timestamp) AS years,
        SUM(p.payment_value) AS payment
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY YEAR(o.order_purchase_timestamp)
)
SELECT
    years,
    ((payment - LAG(payment, 1) OVER (ORDER BY years)) / LAG(payment, 1) OVER (ORDER BY years)) * 100.0 AS [yoy % growth]
FROM yearly_payments
ORDER BY years;




----Calculate the retention rate of customers, 
--defined as the percentage of customers
--who make another purchase within 6 months of their first purchase.

--Trying to find the solution.
select table_name from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE='base table'

select column_name from INFORMATION_SCHEMA.columns
where table_name='order_items'

select column_name from INFORMATION_SCHEMA.columns
where TABLE_NAME='customers'
select column_name from INFORMATION_SCHEMA.columns
where TABLE_NAME='orders'
select column_name from INFORMATION_SCHEMA.columns
where TABLE_NAME='order_items'
--Search metadata to return all table
--names that contain the 'customer_id' column
select table_name from INFORMATION_SCHEMA.COLUMNS
where COLUMN_NAME = 'customer_id'
order by TABLE_NAME

--Count orders per unique customer using customer_unique_id
select customers.customer_unique_id, count(order_id) "total orders"
from customers join orders
on customers.customer_id = orders.customer_id
group by customers.customer_unique_id
order by count(order_id) desc

--The solution.
WITH customer_first_orders AS (
    SELECT 
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
repeat_customers AS (
    SELECT 
        f.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS next_orders -- COUNT(o.order_id) gives the same result here; DISTINCT prevents fan-out if order_items is joined later
    FROM customer_first_orders f
    JOIN customers c ON f.customer_unique_id = c.customer_unique_id
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_purchase_timestamp > f.first_order
      AND o.order_purchase_timestamp < DATEADD(MONTH, 6, f.first_order)
    GROUP BY f.customer_unique_id
)
SELECT 
    100.0 * COUNT(DISTINCT r.customer_unique_id) / COUNT(DISTINCT f.customer_unique_id) AS retention_rate_pct
FROM customer_first_orders f
LEFT JOIN repeat_customers r ON f.customer_unique_id = r.customer_unique_id;




--Identify the top 3 customers who spent the most money in each year.
with customer_spending as(
select
YEAR(o.order_purchase_timestamp) as order_year,
o.customer_id,
SUM(p.payment_value) as total_payment,
DENSE_RANK() over(
partition by year(o.order_purchase_timestamp)
order by sum(p.payment_value) desc
)as spending_rank
from orders o
join payments p on o.order_id = p.order_id
group by YEAR(o.order_purchase_timestamp),o.customer_id
)
select 
order_year, customer_id, total_payment, spending_rank
from customer_spending
where spending_rank<=3
order by order_year asc, spending_rank asc