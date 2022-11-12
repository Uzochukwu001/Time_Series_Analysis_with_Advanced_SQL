/** The Superstore Dataset was first cleaned in Microsoft Excel and unnecessary columns removed and some columns renamed. It was then imported into the Microsoft SSMS for further exploration. 
	Feel free to copy the codes but please ensure matching column names before use. It has 13 columns and 1993 rows **/

--To view the dataset

SELECT *
FROM dbo.Superstore$


--Use the LEAD window function to create a new column, which displays the sales on the next row for each customer in the dataset.
--You can replace the Lead function with Lag function to display the previous sales for each customer in a new column, given similar order.

SELECT Order_id, Order_Date, Customer_id, Product_id, Quantity, Sales,
		LEAD(Sales,1) OVER (PARTITION BY Customer_id ORDER BY Order_Date) AS "Next_Sales_Row"
FROM Superstore$
ORDER BY Customer_id, Order_Date ASC;


--Use the cube function to get the total sales for each product category, bought by each customer 

SELECT Customer_id, category, SUM(Sales) AS "total_sales"
FROM Superstore$
GROUP BY CUBE (Customer_id, category)
ORDER BY Customer_id,category ASC;


----Find out highest Sales made by the store as well as the customer, region, quantity purchased and date sold using rank(use rank function) (Using Aggregate Functions). Rank the dataset based on the sales in descending order, using the RANK function.

SELECT Order_Date, Customer_id, Region, Quantity, Sales,
		RANK() OVER (ORDER BY Sales) AS "sales_ranking"
FROM Superstore$
ORDER BY sales_ranking DESC;


--Show the monthly and daily sales averages from the start date till end date. Also feel free to use common SQL aggregate functions to perform this task as separate individual tasks.

SELECT MONTH(Order_Date) AS "month_num", DAY(Order_Date) AS "day_num", AVG(Sales) AS Sales
FROM Superstore$
GROUP BY CUBE(DAY(Order_Date), MONTH(Order_Date));


--Evaluate the Running Total for sales per product category. Also find the moving average on sales.

SELECT Category, Sales,
		SUM(Sales) OVER (PARTITION BY Category ORDER BY Order_id) AS 'Running_Sales_Total'
FROM Superstore$
ORDER BY Category;

SELECT Order_Date, Sales,
		AVG(Sales) OVER (ORDER BY Order_Date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS '3_period_Moving_Averages'
FROM Superstore$
ORDER BY Order_Date;