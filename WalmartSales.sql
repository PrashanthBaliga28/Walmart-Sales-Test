SELECT * FROM walmart;

Select count (*) from walmart;

	Select count (distinct branch)
from walmart;

select max(quantity)
from walmart;

-- Business Problems 

-- Q1. Find the Different payment methods and number of transactions, Number of quantity sold

SELECT 
	payment_method,
	COUNT(*) as no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--Q2. Identify the highest-rated category in each branch, displaying the branch, category,avg rating

SELECT *
FROM 
(SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2)
WHERE RANK = 1 
;
-- Q3. Identify the busiest day for each branch based on the number of transactions 

SELECT * 
FROM 
	(SELECT
		branch, 
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT (*) AS no_transactions, 
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2 
	) 
WHERE RANK = 1;

-- Q4.Calculate the Total Quantity of items sold per transaction method. List payment_method and total_quantity.

 SELECT 
	payment_method,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--Q5. Determine the average, minimum and maximum rating of products for each city.
-- List the city, average_rating, min_rating and max_rating.

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2;

--Q6. Calculate the total profit for each category by considering total_profit as 
--(unit_price * quantity * profit_margin). List category and total_profit, order from highest to lowest profit

SELECT 
	category,
SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart 
GROUP BY 1 ;

--Q7.Determine the most common payment method for each Branch.
-- Display Branch and the preffered_payment_method.

WITH cte
as 
(SELECT
	branch,
	payment_method,
	COUNT(*) as total_transaction,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT (*) DESC) as rank 
	FROM walmart
	GROUP BY 1, 2
	)
	SELECT *
	FROM cte
	WHERE RANK = 1;

--Q8. Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out which of the shift and number of invoices

SELECT 
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart 
GROUP BY 1, 2
ORDER BY 1, 3 DESC

--Q9. Identify 5 Branches with the highest decrease ratio in revenue compared to last year (current year 2023 and last year 2022)

--rdr == last_rev-cr_rev/ls_rev*100

SELECT *, 
EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart 

--2022 Sales 
WITH revenue_2022
AS 
(
	SELECT	
		branch,
		SUM(total) as revenue 
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
),

revenue_2023
AS
(

SELECT	
	branch,
	SUM(total) as revenue 
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND((ls.revenue - cs.revenue)::numeric/
	ls.revenue::numeric * 100,2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN 
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC 
LIMIT 5