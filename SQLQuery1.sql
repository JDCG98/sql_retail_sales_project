-- SQL retail Sales Analysis -p1

CREATE DATABASE sql_project_p2;

-- create Table

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

SELECT * FROM retail_sales
LIMIT 10

BULK INSERT retail_sales
FROM 'D:\Documents\COMPUTER SCIENCE\SQL_Projects\retail_sales_sql\SQL - Retail Sales Analysis_utf .csv'
WITH (
    FIELDTERMINATOR = ',',  -- Define el delimitador de campo, por ejemplo, una coma
    ROWTERMINATOR = '\n',   -- Define el delimitador de fila, usualmente una nueva línea
    FIRSTROW = 2            -- Omite la fila de encabezado del CSV (si tiene encabezados)
);


SELECT * FROM retail_sales

-- how many rows are there?
SELECT
	COUNT(*)
FROM retail_sales


--nulls
SELECT * FROM retail_sales
WHERE transaction_id IS NULL

SELECT * FROM retail_sales
WHERE sale_date IS NULL

SELECT * FROM retail_sales
WHERE customer_id IS NULL

SELECT * FROM retail_sales
WHERE gender IS NULL

SELECT * FROM retail_sales
WHERE age IS NULL

SELECT * FROM retail_sales
WHERE category IS NULL

SELECT * FROM retail_sales
WHERE quantity IS NULL

SELECT * FROM retail_sales
WHERE price_per_unit IS NULL

SELECT * FROM retail_sales
WHERE cogs IS NULL

SELECT * FROM retail_sales
WHERE total_sale IS NULL

--mejor rmanera null intersectando
SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

--ahora elimina datos null

DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

--data exploration

-- how many sales we have?

SELECT COUNT(*) as total_sales_qty FROM retail_sales

-- how much sales we have?

SELECT SUM(total_sale) 
FROM retail_sales;

-- how many custumers we have?

SELECT COUNT(DISTINCT customer_id) as total_customers FROM retail_sales

-- compras promedio por customer

SELECT
	(SELECT COUNT(*) FROM retail_sales) / 
	(SELECT COUNT(DISTINCT customer_id) FROM retail_sales) AS sales_per_customer


-- categorias unicas de venta

SELECT DISTINCT category FROM retail_sales


-- Data analysis & business problems

select * from retail_sales
-- 1 qrite a query to know the sales of specific day 2022-11-05

SELECT *
from retail_sales
WHERE sale_date = '2022-11-05'

-- query all tarsnations where category = clothing , quantity sold > 10 and month = nov-2022

SELECT * 
FROM retail_sales
WHERE category = 'Clothing' 
  AND quantity > 10 
  AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
GROUP BY category


SELECT *
FROM retail_sales
WHERE category = 'Clothing'
    AND FORMAT(sale_date, 'yyyy-MM') = '2022-11'





SELECT * FROM retail_sales


-- what is the total sales for each category?

SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;

SELECT category, FORMAT(SUM(total_sale), 'N0') AS Net_Sale
FROM retail_sales
GROUP BY category;

SELECT 
    category, 
    FORMAT(CAST(SUM(total_sale) AS money), 'N0') AS total_sales,
    FORMAT(CAST(COUNT(transaction_id) AS money), 'N0') AS total_orders
FROM retail_sales
GROUP BY category;


-- What is the average age of cutomers thahth purchased items from beauty category?

SELECT
	AVG(age)  AS Avg_age_beauty
	FROM retail_sales
	WHERE category = 'Beauty'

-- seach all transactions where the total sale y greater than 1000

SELECT * 
	FROM retail_sales
	WHERE total_sale > 1000


--find the total number of tarnsctions made by each gender in each category (malo mi intento)

SELECT COUNT(*) 
	FROM retail_sales
	GROUP BY gender,category

-- Encuentra el número total de transacciones realizadas por cada género en cada categoría  
SELECT gender, category, COUNT(*) AS total_transactions  
FROM retail_sales  
GROUP BY gender, category
ORDER BY category;


-- calculate average sale for each month and find best selling month in each year


SELECT 
    YEAR(sale_date) AS Year_date,
    MONTH(sale_date) AS Month_date,
    AVG(total_sale) AS avg_total_sale
FROM retail_sales
GROUP BY 
    YEAR(sale_date), 
    MONTH(sale_date)
ORDER BY 
	YEAR(sale_date), 
    AVG(total_sale) DESC

--misma anterior

SELECT 
    year,
    month,
    avg_sale
FROM 
(
    SELECT 
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
) AS t1
WHERE rank = 1;

-- viendo t1
SELECT * 
FROM (
    SELECT 
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
) AS t1;


--TOP 5 customers bases on the highest total sales

--SELECT * FROm retail_sales
SELECT TOP 5 customer_id, SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent DESC;



--find the number of unique customers who purchased items from each category

SELECT
	category,
	customer_id
FROM retail_sales


SELECT 
    category, 
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;


-- Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Betwwen 12 & 17, Evening > 17)

SELECT * FROM retail_sales

--//

WITH hourly_sale AS (
    SELECT 
        *,
        CASE 
            WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
            WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;
