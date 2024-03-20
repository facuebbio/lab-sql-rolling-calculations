use sakila;

## 1. Get number of monthly active customers.
select  
    year(rental_date) as year, 
    month(rental_date) as month, 
    count(distinct customer_id) as monthly_active_customers
from rental
group by year(rental_date), month(rental_date)
order by year, month;

## 2. Active users in the previous month.
with monthly_active as (
    select 
        year(rental_date) as year, 
        month(rental_date) as month, 
        count(distinct customer_id) as active_customers
    from rental
    group by year, month
    order by year, month
)
select year, month, active_customers,
    lag(active_customers) over (order by year, month) as previous_month_customers,
    round(((active_customers - lag(active_customers) over (order by year, month)) / lag(active_customers) over (order by year, month)) * 100,1) as percentage
from 
    monthly_active;

## 3. Percentage change in the number of active customers.
with monthly_active as (
    select 
        year(rental_date) as year, 
        month(rental_date) as month, 
        count(distinct customer_id) as active_customers
    from rental
    group by year, month
    order by year, month
)
select year, month, active_customers,
    lag(active_customers) over (order by year, month) as previous_month_customers,
    round(((active_customers - lag(active_customers) over (order by year, month)) / lag(active_customers) over (order by year, month)) * 100,1) as percentage
from 
    monthly_active;



## 4. Retained customers every month.
with monthly_customers as (
    select
        customer_id,
        year(rental_date) as year,
        month(rental_date) as month
    from 
        rental
    group by 
        customer_id, year, month
),
customer_activity as (
    select
        customer_id,
        year,
        month,
        lead(year) over(partition by customer_id order by year, month) as next_year,
        lead(month) over(partition by customer_id order by year, month) as next_month
    from 
        monthly_customers
)
select
    year,
    month,
    count(customer_id) as Retained_Customers
from 
    customer_activity
where 
    (next_year = year and next_month = month + 1) 
    or (next_year = year + 1 and month = 12 AND next_month = 1)
group by 
    year, month
order by 
    year, month;