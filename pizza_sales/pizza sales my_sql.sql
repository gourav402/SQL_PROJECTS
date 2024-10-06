-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price)) AS Total_Revenue_Generated
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS Total_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_Quantity DESC
LIMIT 5;


-- Identify the highest prized pizza. 

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1; 


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Total_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_Quantity DESC;


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Total_Orders
FROM
    orders
GROUP BY Hour;


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS Total_Pizzas
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS Avg_Sales_Per_Day
FROM
    (SELECT 
        orders.order_date AS Day,
            SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY Day) AS Order_per_day;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price)) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price))
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS Revenue_Percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue_Percentage DESC;


-- Analyze the cumulative revenue generated over time. 

 select order_date, round(sum(Revenue) over(order by order_date),2) as  Cum_Revenue 
 from (select orders.order_date,sum(order_details.quantity * pizzas.price) as Revenue 
 from orders join order_details on orders.order_id = order_details.order_id 
 join pizzas on pizzas.pizza_id = order_details.pizza_id 
 group by orders.order_date) as sales ;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,Revenue from
(select category,name,Revenue , rank() over(partition by category order by revenue desc ) as rn from 
(select pizza_types.category , pizza_types.name , sum(order_details.quantity * pizzas.price ) as Revenue from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.name,pizza_types.category) as table_a) as table_b 
where rn <= 3 ;
 
