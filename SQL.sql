CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);

select * from df_orders;

#top 10 revenue generating products
SELECT product_id, SUM(sale_price) AS Total_Sales
FROM df_orders
GROUP BY product_id
ORDER BY Total_Sales DESC
LIMIT 10;

#Top 5 highest selling products in each region
WITH cte AS (
    SELECT 
        region, 
        product_id, 
        SUM(sale_price) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rn
    FROM df_orders
    GROUP BY region, product_id
)
SELECT 
    region, 
    product_id, 
    total_sales
FROM cte
WHERE rn <= 5;

#Month over month comparision for growth for the year 2022 and 2023
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month, 
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022 ,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

#Highest category for each month
WITH cte AS (
SELECT category, format(order_date, 'yyyyMM') AS order_year_month, sum(sale_price) AS sales 
FROM df_orders
GROUP BY category, format(order_date, 'yyyyMM')
ORDER BY category, format(order_date, 'yyyyMM')
)
SELECT * FROM (
SELECT *,
row_number() OVER(partition by category ORDER BY sales DESC) AS rn
FROM cte
) a
WHERE rn=1;

#Highest growth in profit for a sub category for the year 2022 in comparision with 2023
WITH cte AS (
SELECT sub_category, year(order_date) AS order_year,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY sub_category, year(order_date)
)
, cte2 as (
SELECT sub_category,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT *, (sales_2023-sales_2022)*100/sales_2022
FROM cte2
ORDER BY (sales_2023-sales_2022)*100/sales_2022 DESC;


