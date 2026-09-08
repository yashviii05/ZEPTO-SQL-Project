drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) not null,
mrp NUMERIC(8,2),
avl_quantity INTEGER,
disc_sellingprice NUMERIC,
weightingrams INTEGER,
outofStock BOOLEAN,
quantity INTEGER
);
-- data exploration

-- to see the no. of rows
SELECT COUNT(*) FROM zepto;

--sample data
SELECT * FROM zepto LIMIT 10;

--null values
SELECT * FROM zepto 
WHERE name is NULL
OR category is NULL
OR mrp is NULL
OR discount_percent is NULL
OR disc_sellingprice is NULL
OR outofstock is NULL
OR quantity is NULL;

-- different product categories 
SELECT DISTINCT category FROM zepto ORDER BY category;

--products in stock vs outofstock
SELECT outofstock, COUNT(sku_id) FROM zepto GROUP BY outofstock;

--product names present multiple times
SELECT name, COUNT(sku_id) as "Number of SKUs" FROM zepto
GROUP BY name HAVING count(sku_id)>1 
ORDER BY count(sku_id) DESC;

-- data cleaning

-- checking for products with price = 0
SELECT * FROM zepto WHERE mrp=0 OR disc_sellingprice = 0;

DELETE FROM zepto where mrp=0;

-- converting paise to rupees for mrp
UPDATE zepto 
SET mrp = mrp/100.0,
disc_sellingprice = disc_sellingprice/100.0;

SELECT mrp, disc_sellingprice FROM zepto;

--updating datatype constraints 
ALTER TABLE zepto 
ALTER COLUMN disc_sellingprice TYPE numeric(8,2);

--tackling business insights
--Q1. Find the top 10 best value products based
-- on the discount percentage

SELECT DISTINCT name, mrp, discount_percent 
FROM zepto ORDER BY discount_percent DESC LIMIT 10;

--Q2. what are the products with high MRP but outofstock
SELECT DISTINCT name, mrp FROM zepto WHERE outofstock = True and mrp>300
ORDER BY mrp DESC;

--Q3. calculate estimated revenue for each category
SELECT category, sum(disc_sellingprice*avl_quantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

--Q4. finding products that have high price but discount price is very low
SELECT DISTINCT name, mrp, discount_percent
FROM zepto
WHERE mrp>500 AND discount_percent<10
ORDER BY mrp DESC, discount_percent DESC;

--Q5. Identify the top 5 categories offering the highest average discount percentage
SELECT category,
ROUND(AVG(discount_percent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC LIMIT 5;

--Q6. Find the price per grame for products above 100g and sort by best value.
SELECT DISTINCT name, weightingrams, disc_sellingprice,
ROUND(disc_sellingprice/weightingrams,2) AS price_per_gram
FROM zepto
WHERE weightingrams>=100 
ORDER BY price_per_gram;

--Q7. Group the products into categories like low, medium, bulk.
SELECT DISTINCT name, weightingrams,
CASE WHEN weightingrams< 1000 THEN 'Low'
	WHEN weightingrams< 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

--Q8. What is the total inventory weight per category
SELECT category,
SUM(weightingrams * avl_quantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;
