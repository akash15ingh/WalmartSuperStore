SELECT * FROM ksr.orders;
-- Retrieve all columns from the dataset.
select * from orders;
-- Display only the Order_ID, Order_Date, and Customer_Name columns.
select order_id,order_date,customer_name
from orders;
-- List all unique Ship_Mode values.
select distinct ship_mode
from orders;
-- Find the total number of orders in the dataset.
select count(*) from orders;
-- Retrieve all orders placed in the year 2023.
select * 
from orders
where year(Order_Date)="2021";
-- Show all orders where the Sales amount is greater than $500.
select * 
from orders
where sales>500;
-- Display orders with a discount greater than 20%
select *
from orders
where discount>(20/100);
-- Retrieve all orders shipped using "Standard Class.
select *
from orders
where ship_mode="standard class";
-- List the cities and states from which orders originated, ensuring no duplicates.
select distinct *
from orders
where city is not null and state is not null;
-- Display orders where the profit is negative.
select * 
from orders
where profit<0;
-- Find orders placed in the "Consumer" segment.
select *
from orders
where segment="consumer";
-- Retrieve all products in the "Technology" category.
select * 
from orders
where category="technology";
-- Find orders shipped to the "West" region.
select *
from orders
where region="west";
-- Display all orders with a quantity greater than or equal to 5.
select *
from orders 
where quantity>=5;
-- Retrieve orders placed by a specific customer
select *
from orders
where customer_name="Ken Black";
-- Calculate the total sales for each Category.
select category
,sum(sales) as Total_sales
from orders
group by 1;
-- Find the total profit for each Sub_Category.
select sub_category,
sum(profit) as Total_Profit
from orders
group by 1;
-- Display the total quantity of products sold by Region.
select region,
sum(quantity) as Total_Quantity
from orders
group by 1;
-- Find the average discount applied across all orders.
select category,
avg(discount) as Avg_discount
from orders
group by 1;
-- Retrieve the top 5 most profitable products.
select product_name,
profit
from orders
order by profit desc 
limit 5;
-- Find the top 5 cities by total sales.
select city,
sum(sales) as Total_sales
from orders
group by 1
order by total_sales desc
limit 5;
-- Calculate the total number of orders placed by each Customer_ID.
select customer_id,
count(*) as Total_orders
from orders
group by 1;
-- Display orders with a shipping delay (i.e., Ship_Date > Order_Date).
select *
from orders
where ship_date>order_date;
-- Retrieve orders placed in the last 30 days.
SELECT *
FROM orders
WHERE ship_date >= DATE_SUB('2021-12-31', INTERVAL 30 DAY);
-- Find the most frequently purchased Product_Name.
select Product_name,
count(*) as Most_Purchased
from orders
group by product_name
order by Most_purchased desc
limit 1;
-- Calculate the average sales for each Ship_Mode
select ship_mode,
avg(sales) as avg_sales
from orders
group by 1;
-- List customers who placed more than 10 orders.
select customer_name,
count(*) as Total_Orders
from orders
group by 1
having count(*)>10
order by total_orders desc;
-- Find the order with the maximum profit.
select order_id,
profit
from orders
order by profit desc
limit 1;
-- Identify all products with an average discount greater than 15%.
select product_name,
avg(Discount) as Avg_discount
from orders
group by product_name
having avg(discount)>(15/100);
-- Calculate the profit margin (Profit/Sales) for each order.
select *,
(Profit/Sales) as Sales_margin
from orders;
-- Retrieve all orders with a profit margin less than 10%.
select Order_id,
(profit/sales)*100 as Profit_Margin
from orders
where (profit/sales)*100>15;
-- Find customers who purchased products from multiple Categories.
select customer_name,
count(distinct category) as count_of_Categories
from orders
group by 1
having count(category)>1;
-- Display the Order_ID and total sales for orders exceeding $1,000 in total sales.
select order_id,
sum(sales) as total_sales
from orders
group by 1
having sum(sales)>1000;
-- Count the number of unique customers in each Segment.
select segment,
count(distinct customer_name) as Unique_customers_count
from orders
group by 1;
-- Retrieve orders where the sales-to-profit ratio is less than 1.
select order_id,
(sales/profit) as Sales_margin
from orders
where (sales/profit)<1;
-- Write a query to rank products by total sales within each Category using a window function.
select category,
product_name,
sum(sales) as Total_sales,
dense_rank() over(partition by category order by sum(sales) desc) as ranks
from orders
group by category,product_name
order by category,ranks;
-- Identify the top 3 customers by total sales in each Region.
with CTE as (select customer_name,
region,
sum(sales) as total_sales,
dense_rank() over(partition by region order by sum(sales) desc) as rank_in_region
from orders
group by 1,2)
select * from cte 
where rank_in_region<=3
order by region,rank_in_region;
-- Find the percentage contribution of each Category to the total sales.
select category,
sum(sales) as total_Sales,
(sum(sales)/(select sum(sales) as grand_total_sales from orders)*100) as percentage_contri
from orders
group by category;
-- Identify orders that contribute to the top 10% of total sales (using NTILE or ranking).

(select sum(sales)as total_sales from orders);
select * from orders;

select category,sum(sales) as Total_sales,
(sum(sales)/(select sum(sales) as grand_total_sales from orders)*100) as Contribution
from orders
group by 1;


-- Identify orders that contribute to the top 10% of total sales (using NTILE or ranking).
-- select order_id,sum(sales) as total_Sales,
-- (select *,ntile(10) over(partition by order_id order by sales desc) as top_10 from orders) as topsy
-- from orders
-- group by order_id,topsy
-- order by total_sales desc;

with CTE as (select order_id,
sum(sales) as total_sales,
-- ntile(10) over(order by sum(sales) desc) as ntile_10
dense_rank() over(order by sum(sales) desc) as top_10
 from orders
group by order_id)
select order_id,
total_sales
from cte
-- where top_10=1
order by total_sales desc;


-- Create a query to determine the cumulative sales for each Region.
select region,
sum(sales) as total_sales,
sum(sum(sales)) over(order by sum(sales) rows between unbounded preceding and current row) as cumulative
from orders
where year(order_date) in ("2020","2019")
group by 1
order by sum(sales) desc;


-- Identify customers who have placed no orders in the last 6 months.
select o1.customer_id
from orders o1
left join orders o2
on o1.customer_id=o2.customer_id
and o2.order_date between "2021-06-30" and "2021-12-31"
where o2.customer_id is null;


-- Write a query to calculate the year-over-year growth in total sales.
select year(order_date) as sales_year,
sum(sales) as total_sales,
lag(sum(sales)) over(order by year(Order_Date)) as previous_sales,
concat(round((sum(sales)-lag(sum(sales)) over(order by year(order_date)))/
lag(sum(sales)) over(order by year(order_date))*100,0),"%") as YOY_percent_growth
from orders
group by 1;


-- Determine the first order placed by each customer.
select distinct customer_id,
min(order_date)
from orders
group by 1;



-- Write a query to find the product with the highest profit margin in each Sub_Category.
with cte as (select product_name,
sub_category,
profit,
row_number() over(partition by sub_category order by profit desc) as rn
from orders)
select product_name,
profit as Highest_profit
from cte
where rn=1;


-- Identify customers who have purchased products from all available Categories.
with cte as  (select customer_id,
          category,
		count(customer_id)
        from orders
		group by 1,2
		order by customer_id)
select customer_id,
count(customer_id) as kitne_baar
from cte
group by customer_id
having count(customer_id)<3;




-- Identify customers who have purchased products from all available Categories.
-- with cte as (select customer_id,
-- category,
-- count(customer_id) as logaa
-- from orders
-- group by 1,2
-- order by customer_id)
-- select customer_id,
-- count(customer_id) as kitne_baar_andar_bahar
-- from cte
-- group by 1
-- having count(customer_id)= (select count(*) from (select count(category) 
-- from orders
-- group by (category)) as tabbbb);


with cte as (select customer_id,
category,
count(customer_id) as logaa
from orders
group by 1,2
order by customer_id)
select customer_id,
count(customer_id) as kitne_baar_andar_bahar
from cte
group by 1
having count(customer_id)= (select count(distinct category) from orders);


-- Find the month with the highest total sales for each Region.
-- with cte as (select region,
-- month(order_date) as monthly_sale,
-- sum(sales) as total_sales
-- from orders
-- group by 1,2
-- order by region,total_sales desc)
--  monthly_sale = (select 
--  region,
--  max(total_Sales)
-- from cte
-- group by 1)

-- Find the month with the highest total sales for each Region.
with cte as (select region,
month(order_date) as mahina,
sum(sales) as highest_sales,
dense_rank() over(partition by region order by sum(sales) desc) as ranked
from orders
group by 1,2
order by region,highest_sales desc)
 select region,
 mahina,
highest_sales 
 from cte
 where ranked=1;
 
 
 -- Write a recursive query to identify all orders with shipping delays longer than 7 days.
 select order_id,
 order_date,
 ship_date,
 datediff(ship_date,order_date) as days_diff
 from orders
 order by days_diff desc;
-- where datediff(ship_date,order_date)>7;

-- Calculate the moving average of sales over the last 3 months for each Region
with cte as (select region,
order_date,
avg(sales) as avg_sales
from orders
group by 1,2),

last_3mnth_sales as (select region,
order_date,
avg(avg_sales) over(partition by region order by order_date rows between 2 preceding and current row) as moving_sales
from cte 
where order_date>=(select max(order_date) from orders) -interval 3 month)
select region,
order_date,
moving_sales
from last_3mnth_sales
order by region,order_date;

-- Find all orders where the profit margin is in the bottom 10% of all orders.
with cte as (select order_id,
(profit/sales)*100 as profit_margin,
ntile(10) over(order by (profit/sales)) as bottom_10
-- dense_rank() over(order by (profit/sales)) as bottom_10
from orders)
select order_id,
profit_margin
 from cte
where bottom_10=1;




WITH cte AS (
    SELECT 
        order_id,
        (profit / sales) * 100 AS profit_margin,
        DENSE_RANK() OVER (ORDER BY (profit / sales)) AS rank_order,
        COUNT(*) OVER () AS total_rows
    FROM orders
)
SELECT * 
FROM cte
WHERE rank_order <= (total_rows * 0.1); -- Bottom 10%


-- Identify the most profitable shipping mode for each Region.
with cte as (select region,
profit,
ship_mode,
dense_rank() over(partition by region order by profit desc) as profit_rank
from orders)
select region,
ship_mode,
profit
from cte
where profit_rank=1
order by profit desc;

-- Write a query to calculate the lifetime value of each customer (total profit by Customer_ID).
select customer_id,
sum(profit)/count(customer_id) as lifetime_value
from orders
group by 1
order by lifetime_value desc; 

-- Identify Customaries that have placed orders in every year available in the dataset.
with cte as (select customer_id,
year(order_date),
count(order_date),
count(customer_id) as no_ofyears
from orders
group by 1,2
order by customer_id)
select customer_id
from cte
where customer_id=4
order by customer_id;


-- Calculate the average time (in days) between order placement and shipping for each Customer_ID.
with cte as (select day(ship_date) as shipped_day,
day(order_date) as Ordered_day,
abs(datediff(ship_date,order_date)) as days_btwn,
customer_id
from orders)
select customer_id,
round(avg(days_btwn),0) as avg_days
from cte
group by 1;


-- Identify orders where sales exceeded $500 and the shipping delay was greater than 5 days.
select order_id,
sales,
datediff(Ship_Date,order_date) as shipping_delay
from orders
where sales>500 and datediff(Ship_Date,order_date)>5;


-- Write a query to classify orders into "High Profit," "Moderate Profit," and "Low Profit" based on profit margins.
select order_id,
case
when (profit/sales)<0.1 then "Low Profit"
when  (profit/sales)<0.3 then "Moderate Profit"
else "High Profit"
end as Orders_classified
from orders;


-- Identify the top 3 most profitable products in each Region.
with cte as (select region,
profit,
dense_rank() over(partition by region order by profit desc) as Max_Profit
from orders)
select region,
profit,
Max_Profit
from cte
limit 3;


-- Calculate the average order value (AOV) for each Ship_Mode.
select ship_mode,
sum(sales) as Total_sales,
count(Order_ID) as Total_orders,
(sum(sales)/count(order_id)) as AOV
from orders
group by 1;


-- Find customers who purchased products in both "Furniture" and "Technology" categories.
with cte as (select customer_id,category
from orders
order by customer_id)
select customer_id,
category
from cte
where category in ("Furniture","Technology");



with cte as (select customer_id,
category
from orders
where category in ("Furniture","Technology")
)
select count(customer_id) as orders_in_both ,customer_id
from cte
group by 2
having count(customer_id)=2
order by customer_id;



-- Write a query to create a pivot table summarizing total sales for each Category by Region.
select category,
sum(case when region="east" then sales else 0 end)  as "East Sales",
sum(case when region="West" then sales else 0 end)  as "West Sales",
sum(case when region="Central" then sales else 0 end) as "Central Sales",
sum(case when region="South" then sales else 0 end)  as "South Sales"
from 
orders
group by 1;


-- Identify regions where more than 50% of orders resulted in negative profit.
select region,
count(case when profit<0 then 1 end) as negt_profit,
count(*) as total_orders,
(count(case when profit<0 then 1 end)/count(*))*100 as neg_pro_perc
from orders
group by region
having (count(case when profit<0 then 1 end)/count(*))*100 >30;



-- Write a query to calculate the repeat purchase rate for each customer (Customer_ID).
with cte as (select customer_id,
count(order_id) as total_purchases,
count(distinct order_date) as dstct_purchase_days
from orders
group by 1),

repeat_purchase_rate as (
select customer_id,
case when  total_purchases>1 then 1*( total_purchases-1)/ total_purchases else 0 end as repeat_rate
from cte)

select customer_id,
repeat_rate
from repeat_purchase_rate;

-- Identify customers with an average order value greater than $500.
select customer_id,
sum(sales) as total_sales,
count(order_id) as Total_orders,
sum(sales)/count(order_id) as AOV
from orders
group by 1
having sum(sales)/count(order_id)>500
order by customer_id,total_sales desc;


-- Calculate the total sales and total profit for each month across all years.
select month(order_date) as month_num,
monthName(order_date) as month_name,
year(order_date) as year_num,
sum(sales) as total_sales,
sum(profit) as total_profit
from orders
group by 1,2,3
order by year_num,month_num;



-- Find the top 10 customers with the highest average sales per order.
select customer_id,
avg(sales) as Avg_sales
from orders
group by 1
order by Avg_sales desc
limit 10;


-- Write a query to group orders into 3 price ranges: "Low Sales," "Medium Sales," and "High Sales."
select order_id,
sales,
case 
when sales<500 then "Low_sales"
when sales<1200 then "Medium_sales"
else "High_sales"
end as Sales_range
from orders
order by sales desc;


-- Identify all customers who have purchased products with a discount of 25% or more.
select customer_id,
sum(discount) as total_discount,
count(*) as total_orders,
round(concat((sum(discount)/count(*))*100,"%"),0) as discount_percent
from orders
group by 1
having discount_percent>=25;




create table f1(id int);
insert into f2 values(1),(1),(1);
create table f2(id int);
select f1.id from f1 left join f2 on f1.id=f2.id;
select * from f2;



-- Write a query to calculate the contribution of each Sub_Category to total profit.
with cte as(
select sub_category,
sum(profit) as profit_by_subcate,
(select sum(profit) from orders) as Total_profit
from orders
group by 1
order by profit_by_subcate desc
)
select sub_category,
profit_by_subcate,
Total_profit,
concat(round((profit_by_subcate/Total_profit)*100,2),"%") as Profit_contribution
from cte;



-- Create a query to calculate the reorder rate for each product.
with cte as (select 
product_name,
count(product_id) as num_of_products,
(select count(distinct order_id) from orders) as numberof_orders
from orders
group by 1)
select product_name,
concat(round((num_of_products*1/numberof_orders)*100,2),"%") as order_rate
from cte
order by order_rate desc;




-- Find the average profit margin by State.
select state,
concat(round((avg(profit/sales)*100),2),"%") as Profit_margin
from orders
group by 1
order by state;



-- Identify the shipping mode most frequently used for high-value orders (e.g., sales > $1,000).

with cte as (select ship_mode,
ship_date,
count(Ship_Mode) as Freq_used_mode
from orders
where sales>1000
group by 1,2)
select ship_mode,
Freq_used_mode
from cte 
where Freq_used_mode>1
order by Freq_used_mode desc;



-- Write a query to determine the least profitable product in each Category.
with cte as (select category,
product_name,
avg(profit) as avg_profit
from orders
group by 1,2),
ranked_least_profit as (
select category,
product_name,
dense_rank() over(partition by category order by avg_profit desc) as rnk
from cte)
select category,
product_name
from ranked_least_profit
where rnk=1;



-- Identify all customers who purchased a product in their home city (match City and shipping City).
select * from orders;

-- Write a query to calculate the overall discount percentage for each Region.
select region,
concat(round((sum(discount)/(select sum(discount) from orders)*100),2),"%") as Total_discount
from orders
group by 1;


-- Identify regions where the profit margin is below the overall average.
with cte as(select region,
profit/sales as margin,
(select avg(profit/sales) from orders) as avg_margin
from orders)
select region,
margin,
avg_margin
from cte 
where margin<avg_margin;



-- Rank customers based on total sales.
select customer_name,
sum(sales)  as total_sales,
dense_rank() over( order by sum(sales) desc) as Ranking
from orders
group by 1;


-- Rank products based on total quantity sold.
select product_name,
sum(quantity) as Total_quantity,
dense_rank() over(order by sum(quantity) desc) as ranked_products
from orders
group by 1;



-- Find the top 5 profitable products
with cte as (select product_name,
sum(profit) as total_profit,
dense_rank() over(order by sum(profit) desc) as Highest_profit
from orders
group by 1)
select product_name,
total_profit,
highest_profit
from cte 
where highest_profit<=5;


-- Find the bottom 5 customers by profit
select customer_name,Total_profit,ranked_products from (select customer_name,
sum(profit) as Total_profit,
dense_rank() over(order by sum(profit)) as ranked_products
from orders
group by 1) as calc
where ranked_products<=5;


-- Create a measure to identify the top-performing category by sales.
with cte as (select category,
sum(sales) as top_sales,
dense_rank() over(order by sum(sales) desc) as ranked_category
from orders
group by 1)
select * 
from cte
where ranked_category=1;


-- Rank shipping modes based on the number of orders.
select ship_mode,
count(order_id) as num_orders,
dense_rank() over(order by count(order_id)) as ranked_shipmode
from orders
group by 1;


-- Find the top 3 regions by profit.
select region,total_profit, ranked_region from (select region,
sum(profit) as total_profit,
dense_rank() over(order by sum(profit) desc) as ranked_region
from orders
group by 1) as ranked
where ranked_region<=3;



-- Identify the least profitable sub-category.
select sub_category,total_profit,ranked from (select sub_category,
sum(profit) as Total_profit,
dense_rank() over(order by sum(profit)) as ranked
from orders
group by 1) as rnk
where ranked<=1;


-- Rank states based on sales growth
with cte as (select state,
year(order_date) as yearOfSales,
sum(sales) as Total_sales,
lag(sum(sales)) over( partition by state order by sum(sales) desc) as YOY
from orders
group by 1,2),
ranked_sales as (select state,
yearOfSales,
Total_sales,
YOY,
concat(round(((YOY-Total_sales)/Total_sales)*100,2),"%") as YOY_Growth
from cte)
select state,
yearOfsales,
Total_sales as prev_year,
Yoy as currt_year,
yoy_growth as Sales_growth,
dense_rank() over(order by yoy_growth desc) as ranked
from ranked_sales
order by yearOfsales;



-- 
-- Rank states based on sales growth
with cte as (select state,
year(order_date) as sales_year,
sum(sales) as current_year_sales,
lag(sum(sales)) over() as Prev_sales
from orders
group by 1,2
order by 1,2)
select state,
sales_year,
current_year_sales,
Prev_sales,
concat(round(((current_year_sales-Prev_sales)/Prev_sales)*100,2),"%") as sales_growth,
dense_rank() over(order by (current_year_sales-Prev_sales)/Prev_sales desc) as growth
from cte
where Prev_sales
is not null;



-- Identify the top-selling product in each category.
with cte as (select category,
product_name,
sum(sales) as total_sales,
dense_rank() over(partition by category order by sum(sales) desc) as ranked
from orders
group by 1,2)
select category,
product_name,
total_sales
from cte 
where ranked=1
order by total_sales desc;



-- Calculate total sales for the same period last year (PY).
select year(order_date),
sum(sales) as currnt_yr,
lag(sum(sales)) over(order by year(order_date)) as prev_yr
from orders
group by 1;


-- 	52.	Calculate the profit growth percentage over the previous year.
with cte as (select year(order_date) as sale_year,
sum(profit) as profit_this_year,
lag(sum(sales)) over(order by year(order_date)) as profit_last_year
from orders
group by 1
order by year(order_date))
select sale_year,
profit_this_year,
profit_last_year,
 CONCAT(ROUND(((profit_this_year - profit_last_year) / profit_last_year) * 100, 2), '%') AS profit_growth_percentage
from cte
where profit_last_year is not null;



-- Calculate total sales for the last quarter.
select year(order_date) as sale_year,
quarter(order_date) as this_qtr,
sum(sales) as salethis_qtr,
lag(sum(sales)) over(partition by year(order_date) order by quarter(order_date)) as salelast_qtr
from orders
group by 1,2
order by sale_year;


-- Calculate cumulative sales over time.
select order_date,
sales,
sum(sales) over(order by  order_date rows between unbounded preceding and current row) as cumulative_sale
from orders
order by order_date;


-- Create a rolling 3-month sales measure.
with yr_mnth_sale as (select year(order_date) as yr,
month(order_date) as mnth,
sum(sales) as sales
from orders
group by 1,2)
select *,
sum(sales) over(order by yr,mnth rows between 2 preceding and 0 preceding) as rolling3_sale,
avg(sales) over(order by yr,mnth rows between 2 preceding and 0 preceding) as rolling3_avg
 from yr_mnth_sale;


-- Calculate the difference in sales between the current month and the previous month.
select month(order_date),
sum(sales),
sum(sales)-lag(sum(sales)) over(order by month(order_date)) as sales_diff
from orders
where year(order_date)="2018"
group by month(order_date)
order by month(order_date);



-- Create a measure for year-over-year (YoY) profit growth.
with cte as (select year(order_date) as profitYr,
round(Sum(profit),2) as lastYr_profit,
round(lead(sum(profit)) over(order by year(order_date)),2) as this_year_profit
from orders
group by year(order_date))
select *,
concat(round(((this_year_profit-lastYr_profit)/lastYr_profit)*100,2),"%")
from cte;

-- 

WITH cte AS (
    SELECT 
        YEAR(order_date) AS profitYr,
        ROUND(SUM(profit), 2) AS lastYr_profit,
        ROUND(
            LEAD(SUM(profit)) OVER (ORDER BY YEAR(order_date)), 
            2
        ) AS this_year_profit
    FROM orders
    GROUP BY YEAR(order_date)
)
SELECT 
    profitYr,
    lastYr_profit,
    this_year_profit,
    CASE 
        WHEN lastYr_profit > 0 THEN 
            CONCAT(
                ROUND(((this_year_profit - lastYr_profit) / lastYr_profit) * 100, 2), 
                '%'
            )
        ELSE 
            'N/A'
    END AS YoY_Growth
FROM cte;


-- calculate business days btwn orderdate and shipdate.
select order_date,
ship_date,
datediff(ship_date,order_date) as actual_days,
datediff(ship_date,order_date)-(timestampdiff(week,order_date,ship_date)*2) as business_days
from orders;



-- Create a measure for year-over-year (YoY) profit growth.
select year(order_date) as year_profit,
sum(profit) as curr_yrprofit,
lag(sum(profit)) over(order by year(order_date)) as lst_yrprofit,
concat(round((sum(profit)-lag(sum(profit)) over(order by year(order_date)))/lag(sum(profit)) over(order by year(order_date))*100,2),"%") as YOY
from orders
group by 1;



WITH ProfitByYear AS (
    SELECT 
        YEAR(order_date) AS year_profit,
        SUM(profit) AS curr_yrprofit
    FROM orders
    GROUP BY YEAR(order_date)
)
SELECT 
    year_profit,
    curr_yrprofit,
    LAG(curr_yrprofit) OVER (ORDER BY year_profit) AS lst_yrprofit,
    CONCAT(
        ROUND(
            (curr_yrprofit - LAG(curr_yrprofit) OVER (ORDER BY year_profit)) 
            / NULLIF(LAG(curr_yrprofit) OVER (ORDER BY year_profit), 0) * 100, 2
        ), '%'
    ) AS YOY
FROM ProfitByYear;



-- Calculate month-over-month (MoM) sales growth
with cte as (select year(order_date) as sale_yr,
month(order_date) as sale_mnth,
sum(sales) as curr_mnthsale
from orders
group by 1,2
order by sale_yr)
select sale_yr,
sale_mnth,
curr_mnthsale,
lag(curr_mnthsale) over(order by sale_yr) as lst_mnthsale,
concat(round((curr_mnthsale-lag(curr_mnthsale) over(order by sale_yr))/lag(curr_mnthsale) over(order by sale_yr)*100,2),"%") as MoMSale
from cte;



-- Calculate total sales for the last fiscal year.
select year(order_date) as DateOrder,
sum(sales) as sales
from orders
where (order_date between "2020-04-1" and "2021-03-31")
group by year(order_date);

select case
when month(order_date)>=4 then year(order_date)
else year(order_date)-1
end as fiscal_year,
sum(sales)
from orders
group by fiscal_year
order by fiscal_year;


-- Calculate profit for the last completed month.
select year(order_date) as order_year,
month(order_date) as order_month,
sum(profit) 
from orders
where (year(order_date),month(order_date))=(select year(max(order_date)),month(max(order_date)) from orders)
group by year(order_date), month(order_date)
order by year(order_date),month(order_date);




SELECT 
    YEAR(order_date) AS orderyear,
    MONTH(order_date) AS ordermonth,
    SUM(profit)
FROM
    orders
WHERE
    YEAR(order_date) = YEAR(CURRENT_DATE - INTERVAL 1 MONTH)
        AND MONTH(order_date) = MONTH(CURRENT_DATE - INTERVAL 1 MONTH)
GROUP BY YEAR(order_date) , MONTH(order_date)
ORDER BY YEAR(order_date);



-- Create a measure for total sales where Customer Name starts with “A”.
select customer_name
,sum(sales)
from orders
where customer_name like "A%"
group by 1;



-- Identify the 3 products with the most consistent monthly sales.
with cte as (select month(order_date) as sale_month,
product_name,
sum(sales) as total_sale
from orders
group by 1,2),
stdv_data as (select product_name,
stddev(total_sale) as stdv
from cte
group by product_name)
select product_name,
stdv as consistent_sales
from stdv_data
order by consistent_sales desc
limit 3;



-- Calculate the percentage of orders that received a discount.
with cte as (select count(discount) as discnt
from orders
where order_id is not null)
select discnt*100 /(select count(*) from orders) as ratio
from cte;



-- Find the total number of products purchased by Region over time.
select order_date as purchase_date,
product_name,
region,
count(product_name) from orders
group by 1,2,3
order by purchase_date;


-- Determine the average shipping time (in days) by Ship_Mode.
select avg(ship_time) as days,Ship_Mode from( select order_date,
ship_Date,
ship_mode,
datediff(ship_Date,order_date) as ship_time
from orders) as dayscalc
group by ship_mode;


-- Write a query to identify customers whose total profit contribution is below the median
WITH profits AS (
    SELECT 
        customer_name,
        SUM(profit) AS total_profit,
        (SUM(profit) / (SELECT SUM(profit) FROM orders)) * 100 AS profit_contri
    FROM orders
    GROUP BY customer_name
),

ranked_profits AS (
    SELECT 
        total_profit,
        ROW_NUMBER() OVER (ORDER BY total_profit) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM profits
),

median_calc AS (
    -- If the number of rows is odd, pick the middle one
    SELECT total_profit AS median_profit 
    FROM ranked_profits
    WHERE row_num = CEIL(total_rows / 2)

    UNION ALL

    -- If even, take the average of the two middle values
    SELECT AVG(total_profit) AS median_profit
    FROM ranked_profits
    WHERE row_num IN (FLOOR(total_rows / 2), CEIL(total_rows / 2))
)

SELECT 
    p.customer_name,
    p.total_profit,
    p.profit_contri
FROM profits p
JOIN median_calc m 
ON p.total_profit < m.median_profit
ORDER BY p.total_profit;



-- Calculate the sales growth for each Region compared to the previous quarter.
with saleregion as (select region,
year(order_date) as saleyear,
quarter(order_date) as qtrs,
sum(sales) as sale
from orders
group by 1,2,3)
select region,
saleyear,
qtrs,
lag(sale) over(partition by region order by saleyear, qtrs) as lastQtr_sale,
sale as thisQtr_sale,
round((sale-lag(sale) over(partition by region order by saleyear, qtrs))/lag(sale) over(partition by region order by saleyear, qtrs)*100,2) as sales_growth
from saleregion
order by region,saleyear;



-- Find the product subcategories with the highest sales variability.
select sub_category,
stddev(sales) as Variablity 
from orders
group by 1
order by Variablity desc
limit 1;


-- Identify customers who have placed orders in at least 3 different segments.
SELECT customer_name, COUNT(DISTINCT segment) AS segment_count
FROM orders
GROUP BY customer_name
HAVING segment_count >= 3
ORDER BY segment_count DESC;


select * from employee e 
join dept d 
on e.dept_id=e.dept_id;


with cte as (select emp_name,salary,dep_name,
dense_rank() over(partition by dep_name order by salary desc) as rnk
from employee e
join dept d on e.dept_id=d.dept_id)
select * from cte
where rnk=2;




