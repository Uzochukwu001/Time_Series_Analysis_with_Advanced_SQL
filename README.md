# Time Series Analysis with Advanced SQL



## An Analytical look into a Superstore data  using Time Series Analysis approach with SQL windows functions.




Time series data analysis is an evaluation of variables whose values depend on time. Analyzing time-series data is trivial with Python, but with SQL, it becomes a pretty challenging task. I chose to work on this project to understand what difficulties one might encounter using SQL for time series data analysis. The SuperStore Time Series Dataset from Kaggle was used to run this project on MS SQL Server. The dataset intially contained 20 columns, namely, Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Customer Name, Segment, Country, and City. The utilised codes for exploration can be found in the .sql file attached. The data was first cleaned and transformed using the data preprocessing method and then made SQL-ready. Each task was spotlighted below with its appropriate image and the following data exploration steps were conducted using MS SQL Server: 




- Use the LEAD window function to create a new column, which displays the sales on the next row for each customer in the dataset. Also replace the Lead function with Lag function to display the previous sales for each customer in a new column, given similar order



![Screenshot (100)](https://user-images.githubusercontent.com/112668327/201500000-11db81f8-5049-48fb-ba8a-8fa6abf4030f.png)



- Use the cube function to get the total sales for each product category, bought by each customer 



![Screenshot (102)](https://user-images.githubusercontent.com/112668327/201500074-ad222663-33d1-4dc8-a3bc-e842b8d9f408.png)



- Find out highest Sales made by the store as well as the customer, region, quantity purchased and date sold using rank function. Also rank the dataset based on the sales in descending order, using the RANK function.



![Screenshot (105)](https://user-images.githubusercontent.com/112668327/201500218-3164a4e3-9527-4484-882b-70d9d9744f75.png)



- Show the monthly and daily sales averages from the start date till end date. Also feel free to use common SQL aggregate functions to perform this task as separate individual tasks.



![Screenshot (107)](https://user-images.githubusercontent.com/112668327/201500275-79bdf156-b964-42cf-9bf7-6d87bec27a65.png)



- Evaluate the Running Total for sales per product category. Also find the moving average on sales.



![Screenshot (109)](https://user-images.githubusercontent.com/112668327/201500355-c82bb7f3-d8e9-45f1-98a8-8892627c1f45.png)



- Find the first date and last date a customer placed orders. Nth-value isn't recognised yet by MSSQL Server.



![Screenshot (111)](https://user-images.githubusercontent.com/112668327/201500454-fc0590dc-6a73-4380-b04e-8ff5fec66688.png)



