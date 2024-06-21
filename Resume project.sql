
#1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region

SELECT
   customer,
   Market,
   sub_zone,
   Region
FROM gdb023.dim_customer
WHERE customer= "Atliq Exclusive" AND   region= "APAC";

#2.What is the percentage of unique product increase in 2021 vs. 2020?

WITH CTE1 AS 
(
Select 
count(distinct s.product_code) AS unique_product_2020
FROM fact_sales_monthly s
JOIN dim_product p
ON p.product_code = s.product_code
WHERE fiscal_year=2020
),
CTE2 AS(
Select 
count(distinct s.product_code) AS unique_product_2021
FROM fact_sales_monthly s
JOIN dim_product p
ON p.product_code = s.product_code
WHERE fiscal_year=2021
)
Select 
unique_product_2020,
unique_product_2021,
 Round(((unique_product_2021-unique_product_2020)/unique_product_2020) * 100,2) AS percentage_chng
 FROM CTE2, CTE1;
 
#3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. The final output contains 2 fields,

Select
Segment,
Count( distinct product) AS Product_count
From dim_product
Group by segment
Order by  Product_count DESC;

#4. Follow-up: Which segment had the most increase in unique products in  2021 vs 2020?

WITH CTE1 AS (Select
Segment,
Count( distinct product) AS Product_count_2020
From dim_product p
join fact_sales_monthly s
ON s.product_code=p.product_code
WHERE fiscal_year=2020
Group by segment
),
CTE2 AS (Select
Segment,
Count( distinct product) AS Product_count_2021
From dim_product p
join fact_sales_monthly s
ON s.product_code=p.product_code
WHERE fiscal_year=2021
Group by segment
)
Select
CTE1.CTE2.Segment,
product_count_2020,
product_count_2021,
(product_count_2021-product_count_2020)AS difference 
FROM CTE1,CTE2
Group by Segment;

#5. Get the products that have the highest and lowest manufacturing costs.

Select 
p.product,
p.product_code,
m.manufacturing_cost
FROM dim_product p
JOIN fact_manufacturing_cost m 
ON m.product_code= p.product_code
group by p.product
Order by manufacturing_cost desc;

#6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.

Select 
c.customer_code,
c.customer,
CONCAT(ROUND((d.pre_invoice_discount_pct)*100,2),"%") AS Pre_invoice_pct
FROM dim_customer c
JOIN fact_pre_invoice_deductions d
ON c.customer_code= d.customer_code
Where fiscal_year= 2021
Order by Customer desc
; 

#7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions.

WITH CTE1 AS
(Select
 s.date,
 s.Product_code,
 c.customer,
 s.sold_quantity,
 g.gross_price,
 CONCAT(ROUND(SUM(s.sold_quantity*g.gross_price)/1000000,2) , " mln") AS total_gross_sales
 FROM fact_sales_monthly s
     JOIN fact_gross_price g
        ON s.product_code=g.product_code
     JOIN dim_customer c
        ON c.customer_code =s.customer_code
     WHERE customer= "Atliq Exclusive"
     Group by date
)
SELECT
YEAR(date)As Year,
MONTHNAME(date) AS month,
Total_gross_sales
FROM CTE1
Group by month
Order by total_gross_sales DESC, Year;

#8. In which quarter of 2020, got the maximum total_sold_quantity?

SELECT 
     Get_fiscal_quaterly(date) AS quater,
    SUM(sold_quantity) AS total_sold_quantity
FROM 
    fact_sales_monthly
WHERE 
    YEAR(date) = 2020
GROUP BY 
    quater
ORDER BY 
    total_sold_quantity DESC ;
    
#9, Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?

WITH CTE1 AS (Select
 c.channel,
  CONCAT(ROUND(SUM(s.sold_quantity*g.gross_price)/1000000,2)," mln") AS total_gross_sales
 FROM fact_sales_monthly s
     JOIN fact_gross_price g
        ON s.product_code=g.product_code
     JOIN dim_customer c
        ON c.customer_code =s.customer_code
     Group by channel
)
SELECT *,
CONCAT(ROUND(total_gross_sales *100/SUM(total_gross_sales) OVER( ),2),"%") AS percentage
FROM CTE1
group by channel
Order by total_gross_sales DESC
;

#10 Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?

WITH CTE1 AS (Select
 p.division,
 p.product_code,
 P.product, 
  CONCAT(ROUND(SUM(s.sold_quantity*g.gross_price)/1000000,2)," mln") AS total_gross_sales
 FROM fact_sales_monthly s
     JOIN fact_gross_price g
        ON s.product_code=g.product_code
	JOIN dim_product p
	ON p.product_code= s.product_code
    Group by product
Order by total_gross_sales DESC
),
CTE2 AS (
SELECT *,
DENSE_RANK () OVER(Partition by division Order by total_gross_sales DESC ) AS RNK
FROM CTE1
)
Select *
FROM CTE2 
WHERE RNK<=3;


#============================================================

SELECT
date,
Get_fiscal_Year (date),
get_fiscal_quaterly(date)
FROM fact_sales_monthly


 

