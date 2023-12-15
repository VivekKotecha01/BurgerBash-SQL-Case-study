CREATE TABLE 
burger_names(
   burger_id   INTEGER  NOT NULL PRIMARY KEY,
   burger_name VARCHAR(10) NOT NULL
);
INSERT INTO burger_names(burger_id,burger_name) VALUES (1,'Meatlovers');
INSERT INTO burger_names(burger_id,burger_name) VALUES (2,'Vegetarian');

CREATE TABLE runner_orders(
   order_id     INTEGER  NOT NULL PRIMARY KEY 
  ,runner_id    INTEGER  NOT NULL
  ,pickup_time  timestamp
  ,distance     VARCHAR(7)
  ,duration     VARCHAR(10)
  ,cancellation VARCHAR(23)
);
INSERT INTO runner_orders VALUES (1,1,'2021-01-01 18:15:34','20km','32 minutes',NULL);
INSERT INTO runner_orders VALUES (2,1,'2021-01-01 19:10:54','20km','27 minutes',NULL);
INSERT INTO runner_orders VALUES (3,1,'2021-01-03 00:12:37','13.4km','20 mins',NULL);
INSERT INTO runner_orders VALUES (4,2,'2021-01-04 13:53:03','23.4','40',NULL);
INSERT INTO runner_orders VALUES (5,3,'2021-01-08 21:10:57','10','15',NULL);
INSERT INTO runner_orders VALUES (6,3,NULL,NULL,NULL,'Restaurant Cancellation');
INSERT INTO runner_orders VALUES (7,2,'2021-01-08 21:30:45','25km','25mins',NULL);
INSERT INTO runner_orders VALUES (8,2,'2021-01-10 00:15:02','23.4 km','15 minute',NULL);
INSERT INTO runner_orders VALUES (9,2,NULL,NULL,NULL,'Customer Cancellation');
INSERT INTO runner_orders VALUES (10,1,'2021-01-11 18:50:20','10km','10minutes',NULL);


CREATE TABLE burger_runner(
   runner_id   INTEGER  NOT NULL PRIMARY KEY 
  ,registration_date date NOT NULL
);
INSERT INTO burger_runner VALUES (1,'2021-01-01');
INSERT INTO burger_runner VALUES (2,'2021-01-03');
INSERT INTO burger_runner VALUES (3,'2021-01-08');
INSERT INTO burger_runner VALUES (4,'2021-01-15');


CREATE TABLE customer_orders(
   order_id    INTEGER  NOT NULL 
  ,customer_id INTEGER  NOT NULL
  ,burger_id    INTEGER  NOT NULL
  ,exclusions  VARCHAR(4)
  ,extras      VARCHAR(4)
  ,order_time  timestamp NOT NULL
);
INSERT INTO customer_orders VALUES (1,101,1,NULL,NULL,'2021-01-01 18:05:02');
INSERT INTO customer_orders VALUES (2,101,1,NULL,NULL,'2021-01-01 19:00:52');
INSERT INTO customer_orders VALUES (3,102,1,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (3,102,2,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,2,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (5,104,1,NULL,'1','2021-01-08 21:00:29');
INSERT INTO customer_orders VALUES (6,101,2,NULL,NULL,'2021-01-08 21:03:13');
INSERT INTO customer_orders VALUES (7,105,2,NULL,'1','2021-01-08 21:20:29');
INSERT INTO customer_orders VALUES (8,102,1,NULL,NULL,'2021-01-09 23:54:33');
INSERT INTO customer_orders VALUES (9,103,1,'4','1, 5','2021-01-10 11:22:59');
INSERT INTO customer_orders VALUES (10,104,1,NULL,NULL,'2021-01-11 18:34:49');
INSERT INTO customer_orders VALUES (10,104,1,'2, 6','1, 4','2021-01-11 18:34:49');


## Data Analysis

## Question:1 How Many burgers were ordered? ##

SELECT COUNT(*) AS 'No. of orders'
FROM runner_orders;

## Question:2 How many unique customers ordered were made? ##

SELECT COUNT(DISTINCT order_id) AS UniqueOrders
FROM customer_orders;

## Question:3 How many successful orders were delivered by each runner? ##

SELECT runner_id, COUNT(DISTINCT order_id) AS SuccessfulOrders
FROM runner_orders
WHERE cancellation is NULL
GROUP BY runner_id
ORDER BY runner_id 

## Question:4 How many of each type of burger was delivered? ##

SELECT burger_names.burger_name, COUNT(customer_orders.burger_id) AS DeliveredBurgers
FROM customer_orders 
JOIN runner_orders 
ON customer_orders.order_id = runner_orders.order_id
JOIN burger_names 
ON customer_orders.burger_id = burger_names.burger_id
WHERE distance != 0
GROUP BY burger_name;

## Question:5 How many veg and meat were ordered by each customers? ##

SELECT customer_orders.customer_id, burger_names.burger_name, COUNT(burger_names.burger_name) AS OrderCount
FROM customer_orders
JOIN burger_names
ON customer_orders.burger_id = burger_names.burger_id
GROUP BY customer_orders.customer_id, burger_names.burger_name
ORDER BY customer_orders.customer_id

## Question:6 What was the maximum number of burgers delivered in a single order? ##

WITH BurgerCount_CTE AS
( SELECT customer_orders.order_id, COUNT(customer_orders.burger_id) AS BurgersPerOrder
FROM customer_orders
JOIN runner_orders
ON customer_orders.order_id = runner_orders.order_id
WHERE distance != 0
GROUP BY customer_orders.order_id
)
SELECT MAX(BurgersPerOrder)
FROM BurgerCount_CTE;

## Question:7 For each customer how many delivered burgers had at least 1 change and how many had no changes? ##

SELECT customer_orders.customer_id, SUM(CASE 
                            WHEN customer_orders.exclusions <> '   ' OR
                                 customer_orders.extras <> '  ' THEN 1  ELSE 0
                            END) AS Atleast1Change,
						SUM(CASE 
                            WHEN customer_orders.exclusions = '  ' AND 
                            customer_orders.extras = '  '  THEN 1 ELSE 0
                            END) AS NoChange
FROM customer_orders
JOIN runner_orders
ON customer_orders.order_id = runner_orders.order_id
WHERE distance != 0
GROUP BY customer_orders.customer_id
ORDER BY customer_orders.customer_id

## Question:8 How was thr total volune of burgers ordered for each hour of the day? ##



## Question:9 How many runners signed up for each 1 week period? ##

SELECT EXTRACT(WEEK FROM registration_date) AS RegistrationWeek, COUNT(runner_id) AS RunnerSignUp
FROM burger_runner
GROUP BY EXTRACT(WEEK FROM registration_date)

## Question:10 What was the avg distance travelled for each customer? ##

SELECT customer_orders.customer_id, AVG(runner_orders.distance) AvgDistanceTravelled
FROM customer_orders
JOIN runner_orders
ON customer_orders.order_id = runner_orders.order_id
GROUP BY customer_orders.customer_id