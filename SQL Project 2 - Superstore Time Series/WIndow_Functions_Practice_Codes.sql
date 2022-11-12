USE [FIRSTDB]
GO

/****** CREATE OBJECT:  TABLE [dbo].[Superstore$]    Script Date: 10/26/2022 3:46:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Superstore$](
	[Order_id] [nvarchar](255) NULL,
	[Order_Date] [datetime] NULL,
	[Customer_id] [nvarchar](255) NULL,
	[Segment] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Postal_Code] [float] NULL,
	[Region] [nvarchar](255) NULL,
	[Product_id] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Sub-Category] [nvarchar](255) NULL,
	[Sales] [float] NULL,
	[Quantity] [float] NULL,
	[Discount] [float] NULL
) ON [PRIMARY]
GO


/*** ALL RECORDS IN THE SUPERSTORE TABLE ***/

SELECT *
FROM dbo.Superstore$


/*** Implement COUNT, MAX, MIN, ROUND(AVERAGE), 
STANDARD DEVIATION and VARIANCE FUNCTIONS to the Distribution ***/

SELECT dbo.Superstore$.[Sub-Category],
		Superstore$.Region,
		COUNT(Superstore$.Quantity) AS num_of_products,
		MAX(Superstore$.Quantity) AS highest_quantity,
		MIN(Superstore$.Quantity) AS lowest_quantity,
		ROUND(AVG(Superstore$.Sales),4) AS average_sales,
		STDEVP(Superstore$.Sales) AS Pop_Sales_Deviation,
		VARP(Superstore$.Sales) AS Pop_Sales_Variation
FROM dbo.Superstore$
GROUP BY dbo.Superstore$.[Sub-Category], Superstore$.Region;


/*** INCLUDE ROLLUP AND CUBE FUNCTION TO THE ABOVE QUERY ***/

/* ROLLUP gets subtotals and totals for categories*/

SELECT Superstore$.Region,
		Superstore$.[Sub-Category],
		COUNT(Superstore$.Quantity) AS num_of_products,
		MAX(Superstore$.Quantity) AS highest_quantity,
		MIN(Superstore$.Quantity) AS lowest_quantity,
		ROUND(AVG(Superstore$.Sales),4) AS average_sales,
		STDEVP(Superstore$.Sales) AS Pop_Sales_Deviation,
		VARP(Superstore$.Sales) AS Pop_Sales_Variation
FROM dbo.Superstore$
GROUP BY ROLLUP(Superstore$.Region, Superstore$.[Sub-Category])

/* CUBE gets subtotals and totals for categories and subcategories*/

SELECT Superstore$.Region,
		Superstore$.[Sub-Category],
		COUNT(Superstore$.Quantity) AS num_of_products,
		MAX(Superstore$.Quantity) AS highest_quantity,
		MIN(Superstore$.Quantity) AS lowest_quantity,
		ROUND(AVG(Superstore$.Sales),4) AS average_sales,
		STDEVP(Superstore$.Sales) AS Pop_Sales_Deviation,
		VARP(Superstore$.Sales) AS Pop_Sales_Variation
FROM Superstore$
GROUP BY CUBE(Superstore$.Region, Superstore$.[Sub-Category])


/*** USING GROUP BY AND FILTER FUNCTIONS TO CREATE A PIVOT TABLE, Figure it out on another DBMS ***/

SELECT Customer_id,
		COUNT (Order_id) FILTER WHERE Order_Date BETWEEN '2014-01-01' AND '2014-12-31',
		COUNT Order_id FILTER WHERE Order_Date BETWEEN '2015-01-01' AND '2015-12-31',
		COUNT Order_id FILTER WHERE Order_Date BETWEEN '2016-01-01' AND '2016-12-31',
		COUNT Order_id FILTER WHERE Order_Date BETWEEN '2017-01-01' AND '2017-12-31'
FROM dbo.Superstore$
GROUP BY Superstore$.Customer_id


/*** INTRODUCING WINDOW FUNCTIONS WITH GROUPING AND PARTITIONING***/
--Finds the average quantity for each customer per region they're involved in.

SELECT Customer_id, AVG(Quantity)
FROM Superstore$
GROUP BY Customer_id

SELECT Customer_id, Region, Quantity,
		AVG(Quantity) OVER(PARTITION BY Customer_id) AS 'Average_Quantity_per_customer'
FROM Superstore$
ORDER BY Customer_id


--Note that you can alias a window partition for repetitive usecase scenarios as shown below. Figure out on other DBMS

SELECT Superstore$.Customer_id, 
		Region, 
		AVG(Quantity) OVER (aboki)
FROM Superstore$
WINDOW aboki AS (PARTITION BY Customer_id)
ORDER BY Customer_id;


--Including Order by in the partitioning

SELECT Customer_id, Region, Quantity,
		AVG(Quantity) OVER(PARTITION BY Customer_id) AS 'Average_Quantity_per_customer',
		AVG(Quantity) OVER(PARTITION BY Customer_id ORDER BY Region) AS 'AverageQuantitypercustomer'
FROM Superstore$
ORDER BY Customer_id


/*** To get the Moving Average ***/

SELECT Sales, Region,
		SUM(Sales) OVER (ORDER BY Region ROWS BETWEEN 0 PRECEDING AND 2 FOLLOWING) AS '3 period Leading Sum',
		SUM(Sales) OVER (ORDER BY Region ROWS BETWEEN 2 PRECEDING AND 0 FOLLOWING) AS '3 period Trailing Sum',
		AVG(Sales) OVER (ORDER BY Region ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS '3 period Moving Average'
FROM Superstore$


/*** USING FIRST_VALUE, LAST_VALUE AND NTH VALUE ***/


--Find the first date and last date a customer placed orders. Nth-value isn't recognised yet by MSSQL Server.

SELECT DISTINCT Customer_id, Order_Date,
		FIRST_VALUE(Order_Date) OVER (PARTITION BY Customer_id ORDER BY Order_Date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
		LAST_VALUE(Order_Date) OVER (PARTITION BY Customer_id ORDER BY Order_Date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM Superstore$


/*** FINDING THE MEDIAN, QUARTILES, MODE, RANGE OF A DISTRIBUTION. ***/

--Getting a Median Value of Quantity in all regions. Query below can work with a group by instead of the OVER clause in PostgreSQL.
--Discrete Median Value picks the first value if there's an even distribution
--Continuous Median Value takes the average value of the two middle values if there's an even distribution. 

SELECT Region,
		PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Quantity) OVER (PARTITION BY Region) AS 'discrete_median',
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Quantity) OVER (PARTITION BY Region) AS 'continuous_median'
FROM Superstore$

--In an even distribution, to get the percent division in a group as well as number out subsets of a group equally, use percentile and ntile.

SELECT Region,
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Quantity) OVER (PARTITION BY Region) AS 'First_quartile',
		PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY Quantity) OVER (PARTITION BY Region) AS 'third_pentile or sixth decile',
		PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY Quantity) OVER (PARTITION BY Region) AS 'seventh_decile',
		NTILE(10) OVER (ORDER BY Quantity) AS 'Groups of ten'
FROM Superstore$

--To get mode, use MODE clause which isn't recognised by MSSQL Server to get just a single value. or Choose the second query which is better.
--FInd the frequencies for each quantity for each region
SELECT Region,
		MODE() WITHIN GROUP (ORDER BY Quantity) OVER (PARTITION BY Quantity)
FROM Superstore$

--OR

SELECT Region, Quantity, COUNT(*) AS 'frequency'
FROM Superstore$
GROUP BY Quantity, Region
ORDER BY COUNT(*) DESC

--To get the range of a distribution, simply subtract the minimum value from the maximum value.


/*** USING RANK AND DENSE-RANK FUNCTIONS ***/

--Dense-rank function numbers items uniquely in a list, unlike Rank function.
-- Rank Customers in different regions according to Quantities bought. Show difference between rank and dense-rank

SELECT Region, Customer_id, Quantity,
		RANK() OVER (PARTITION BY Region ORDER BY Quantity DESC) AS 'numbering',
		DENSE_RANK() OVER(PARTITION BY Region ORDER BY Quantity DESC) AS 'unique_numbering'
FROM Superstore$
ORDER BY Region, Quantity DESC

--To check the position of a specific value in a distribution present/absent in the given dataset, for a certain category too.
--What position will someone who ordered product quantity of 10 fall in each region. Figure out if it runs in postgreSQL

SELECT Region, RANK(10) WITHIN GROUP (ORDER BY Quantity DESC), DENSE_RANK(10) WITHIN GROUP (ORDER BY Quantity DESC)
FROM Superstore$
GROUP BY Region


/*** CASE, COALESCE AND NULLIF STATEMENTS ***/

--CASE STATEMENT: What discount type are operational for each customer's order.
SELECT Customer_id, Discount,
		CASE 
			WHEN Discount BETWEEN 0.1 AND 0.2 THEN 'Basic'
			WHEN Discount BETWEEN 0.3 AND 0.45 THEN 'Custom'
			WHEN Discount BETWEEN 0.5 AND 0.8 THEN 'Classic'
			ELSE 'Unknown'
		END AS 'Discount Type'
FROM Superstore$
ORDER BY Discount

--COALESCE FUNCTION: Use it to find and/or replace null values in a column with value from another column.

SELECT Order_id, Sales,
		COALESCE (Sales, Quantity) AS 'better', Quantity
FROM Superstore$

--NULLIF FUNCTION: Replace a non-null value with null value in a canary data anomaly

SELECT DISTINCT Quantity, NULLIF(Quantity,14) AS 'Cleaned_Quantity'
FROM Superstore$
ORDER BY Quantity


/*** LEAD AND LAG FUNCTIONS ***/

--Find the previous and next days of orders for each customer.

SELECT Order_id, Customer_id, Order_Date,
		LEAD(Order_Date,1) OVER (PARTITION BY Customer_id ORDER BY Order_Date) AS 'next_order',
		LAG(Order_Date,1) OVER (PARTITION BY Customer_id ORDER BY Order_Date) AS 'previuos_order'
FROM Superstore$









/*** OTHER FUNCTIONS: CTEs(WITH & WITH RECURSIVE STATEMENT); (WIDTH_BUCKET, NTH_VALUE, PERCENT_RANK & CUME_DIST); FUZZY STRING MATCH(SOUNDEX, DIFFERENCE, AND LEVENSHTEIN); CAST< EXTRACT FUNCTIONS, STRING & DATE FUNCTIONS ***/