create table customers (
RowNumber INT,
    CustomerId INT PRIMARY KEY,
    Surname VARCHAR(50),
    CreditScore INT,
    Geography VARCHAR(50),
    Gender VARCHAR(10),
    Age INT,
    Tenure INT,
    Balance DECIMAL(15, 2),
    NumOfProducts INT,
    HasCrCard BOOLEAN,
    IsActiveMember BOOLEAN,
    EstimatedSalary DECIMAL(15, 2),
    Exited BOOLEAN
);

select * from customers;
--1)Customer Segmentation by Geography
--How many customers are there from each geography?
SELECT geography, COUNT(*) AS customercount
FROM customers
GROUP BY geography;

--2)Gender Distribution
--What is the distribution of customers by gender?
SELECT gender, COUNT(*) AS customercount
FROM customers
GROUP BY gender;

--3)Average Credit Score
--What is the average credit score of customers, 
--who have exited the bank versus those who have not?
SELECT 
    AVG(CASE WHEN exited = true THEN creditscore END) AS avgcreditscore_exited,
    AVG(CASE WHEN exited = false THEN creditscore END) AS avgcreditscore_notexited
FROM customers;

--4)High Balance Customers
-- Retrieve the details of customers who have a balance greater than 100,000.
SELECT *
FROM customers
WHERE balance > 100000;

--using subquery
SELECT *
FROM customers
WHERE customerid IN (SELECT customerid FROM customers WHERE balance > 100000);

--5)Active Member Count
--How many active members (IsActiveMember = 1) are there in the bank, 
--and what is the average balance for them?
SELECT COUNT(*) AS isactivemembercount,
AVG(balance) AS averagebalance
FROM customers
WHERE isactivemember = true

--using cte
WITH ActiveMembers AS (
    SELECT Balance
    FROM Customers
    WHERE IsActiveMember = TRUE
)
SELECT 
    COUNT(*) AS ActiveMemberCount,
    AVG(Balance) AS AvgBalance
FROM ActiveMembers;

--6)Churn by Products Owned
--How many customers who have exited (Exited = 1) have 2 or more bank products?
SELECT COUNT(*) AS excitedcustomercount
FROM customers 
WHERE numofproducts > 2 
AND isactivemember = true;

--using cte
WITH excitedcustomers AS (
SELECT *
FROM customers
WHERE isactivemember = true
)
SELECT COUNT(*) AS excitedcustomercount
FROM excitedcustomers
WHERE numofproducts > 2;

--7)Age and Churn Analysis
--What is the average age of customers who have exited the bank,
--and how does it compare to customers who are still with the bank?
SELECT 
    AVG(CASE WHEN exited = true THEN age END) AS avgage_exited,
    AVG(CASE WHEN exited = false THEN age END) AS avgage_notexited
FROM customers;
-----
WITH customerstatus AS (
    SELECT age, exited
    FROM customers
)
SELECT 
    AVG(CASE WHEN exited = true THEN age END) AS avgage_exited,
    AVG(CASE WHEN exited = false THEN age END) AS avgage_notexited
FROM customerstatus;

--8)Group customers into credit score ranges (e.g., 300-400, 400-500, etc.), 
--and find the number of churned customers in each range.
SELECT
CASE
 WHEN creditscore BETWEEN 300 AND 399 THEN '300-399'
 WHEN creditscore BETWEEN 400 AND 499 THEN '400-499'
 WHEN creditscore BETWEEN 500 AND 599 THEN '500-599'
 WHEN creditscore BETWEEN 600 AND 699 THEN '600-699'
 WHEN creditscore BETWEEN 700 AND 799 THEN '700-799'
 WHEN creditscore BETWEEN 800 AND 899 THEN '800-899'
ELSE 'Unknown'
END AS creditscorerange,
COUNT(*) AS churnedcustomerscount
FROM customers
WHERE exited = true
GROUP BY creditscorerange
ORDER BY creditscorerange;

--9)Churn by Geography
--What is the percentage of customers who have exited the bank by geography?
SELECT 
    geography,
    COUNT(CASE WHEN exited = true THEN 1 END) * 100.0 / COUNT(*) AS exitpercentage
FROM customers
GROUP BY geography
ORDER BY exitpercentage DESC;

--10)Average Salary by Tenure
--What is the average estimated salary for customers 
--who have been with the bank for 5 or more years (Tenure >= 5)?
SELECT AVG(estimatedsalary) AS avgestimatedsalary
FROM customers
WHERE tenure >=5

--11)Credit Card Usage Analysis
--What percentage of customers with a credit card (HasCrCard = 1) 
--have exited the bank compared to those without a credit card?
SELECT 
    hascrcard,
    (SELECT COUNT(*) 
     FROM customers AS sub 
     WHERE sub.hascrcard = customers.hascrcard AND exited = true) * 100.0 / COUNT(*) AS exitpercentage
FROM customers
GROUP BY hascrcard
ORDER BY hascrcard;

--12. Churn Prediction by Tenure
-- How does the number of churned customers vary by the tenure of customers? 
(--Group customers by tenure and count exits)
 SELECT tenure,
 SUM(CASE WHEN exited = true THEN 1 ELSE 0 END) AS churnedcustomers
 FROM customers 
 GROUP BY tenure
 ORDER BY tenure
 --CTE
 WITH churncount AS (
 SELECT tenure,
 COUNT(CASE WHEN exited = true THEN 1 END ) AS churnedcustomers
 FROM customers
 GROUP BY tenure
 )
 SELECT tenure,churnedcustomers
 FROM churncount
 ORDER BY tenure

 --13)Top 5 Customers by Balance
-- Retrieve the details of the top 5 customers with the highest account balance.
 SELECT *
FROM customers 
 ORDER BY balance DESC
 LIMIT 5;

 --14)Gender and Product Count
--What is the average number of products owned by male vs. female customers?
SELECT gender, AVG(numofproducts) AS avgproductcount
FROM customers 
GROUP BY gender 

--15)High Salary, Low Churn Customers
--Retrieve the details of customers who earn more than 80,000 
--but have not exited the bank.
SELECT *
FROM customers
WHERE estimatedsalary > 80000
  AND exited = false;
  
--16)Customers with High Balance and Low Credit Score
--Retrieve customers who have a high account balance 
--(greater than 100,000) but a low credit score (less than 400).
SELECT *
FROM customers
WHERE balance > 100000
  AND creditscore < 400;
  
--17)Churned customers with maximum tenure
--Retrieve the details of churned customers (Exited = TRUE)
--who have the maximum tenure in the bank.
SELECT *
FROM customers
WHERE exited = true
  AND tenure = (SELECT MAX(tenure) FROM customers WHERE exited = true);