use pizza_sales_analysis;


select * from orders;
select * from order_details;
select * from pizzas;
select * from pizza_types;

-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;


-- Calculate the total revenue generated from pizza sales.

select round(sum(oi.quantity * p.price),2) as total_revenu from pizzas as p
join order_details as oi
on p.pizza_id =oi.pizza_id;

-- Identify the highest-priced pizza.

select pt.name,p.price  from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
order by price desc;

-- Identify the most common pizza size ordered.

select p.size,count(o.order_id ) As total_count from pizzas as p 
join order_details as  o
 on p.pizza_id = o.pizza_id
 group by p.size
 order by total_count desc;
 
-- List the top 5 most ordered pizza types along with their quantities. 

select pt.name ,sum(oi.quantity) as sum_quantity from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as oi
on p.pizza_id = oi.pizza_id 
group by name
order by sum_quantity desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category,sum(oi.quantity) as sum_quantity from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as oi
on p.pizza_id = oi.pizza_id
group by category;

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as time,count(order_id) as orders_count from orders
group by time ;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category ,count(name) as name_count from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) as avg_pizza_order from
(select o.order_date,sum(oi.quantity) as quantity from orders as o
join order_details as oi
on o.order_id=oi.order_id
group by order_date) as order_quantity ;

-- Determine the top 3 most ordered pizza types based on revenue.

select pt.name ,sum(p.price*oi.quantity )as revenu from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as oi
on p.pizza_id = oi.pizza_id 
group by name
order by revenu desc
limit 3;

--  Calculate the percentage contribution of each pizza type to total revenue.

select pt.category ,round(sum(p.price*oi.quantity )/ (select round(sum(oi.quantity * p.price),2) as total_revenu from pizzas as p
join order_details as oi
on p.pizza_id =oi.pizza_id)*100,2) as revenu from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as oi
on p.pizza_id = oi.pizza_id 
group by category
order by revenu desc;

-- Analyze the cumulative revenue generated over time.\

select order_date,
sum(revenue) over(order by order_date) as cum_rev
from
(
   select o.order_date,
   sum(oi.quantity * p.price) as revenue
   from order_details as oi
   join pizzas as p
       on oi.pizza_id = p.pizza_id
   join orders as o
       on o.order_id = oi.order_id
   group by o.order_date
) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue
FROM
(
    SELECT category,
           name,
           revenue,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM
    (
        SELECT pt.category,
               pt.name,
               SUM(oi.quantity * p.price) AS revenue
        FROM pizza_types as pt
        JOIN pizzas as p
            ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details as oi
            ON oi.pizza_id = p.pizza_id
        GROUP BY pt.category, pt.name
    ) AS a
) AS b
WHERE rn <= 3;
