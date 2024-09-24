create database Sales_delivery;          
select * from cust_dimen;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select * from shipping_dimen;

--      Question 1: Find the top 3 customers who have the maximum number of orders
select cust_id,customer_name from cust_dimen where cust_id in 
(select cust_id from
(select cust_id,dense_rank()over(order by cnt desc) rank_no from
(select cust_id,count(order_quantity) as cnt from market_fact
group by cust_id) as t) as tt
where rank_no <=3 );

-- 2. Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.

select order_Date, ship_date, (ship_date-order_date) as daystakenfordelivery from orders_dimen o
join shipping_dimen s on o.order_id=s.order_id;

-- Question 3: Find the customer whose order took the maximum time to get delivered.
   select c.cust_id,c.customer_name,order_Date,ship_date, (ship_date-order_date) as daystakenfordelivery from orders_dimen o
   join shipping_dimen s on o.order_id=s.order_id
   join market_fact m on s.ship_id=m.ship_id
   join cust_dimen c on m.Cust_id=c.Cust_id
   group by c.cust_id,c.customer_name,order_Date,ship_date
   order by daystakenfordelivery desc;
   
   -- Question 4: Retrieve total sales made by each product from the data (use Windows function)
   select distinct prod_id,sales,sum(sales)over(partition by prod_id) as tot_sales
   from market_fact;
   
   --        Question 5: Retrieve the total profit made from each product from the data (use windows function)
   select distinct prod_id,profit,sum(profit)over(partition by prod_id) as tot_profit
   from market_fact;
   
   --     Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
   
create view combined as
(select m.ord_id,m.prod_id,m.ship_id,m.cust_id,m.sales,m.discount,m.order_quantity,m.profit,m.shipping_cost,m.product_base_margin,
c.Customer_Name,c.province,c.region,c.customer_segment,
o.order_id,o.order_date,o.order_priority,p.product_category,p.product_sub_category,
s.ship_mode,s.ship_date
from market_fact m left join cust_dimen c using(cust_id)
left join orders_dimen o using(ord_id)
left join prod_dimen p using(prod_id)
left join shipping_dimen s using(ship_id));
select * from combined;

select cust_id,customer_name, count(order_id)over(partition by cust_id) as jancustomers from combined
where date_format(order_date,"%m")="January"
order by jancustomers desc;

with nt as
(select distinct cust_id,customer_name , count(order_date)over(partition by cust_id) jancustomerno from 
combined where date_format(order_date,"%M")='january' order by jancustomerno desc )

select * from nt where cust_id in 
(select cust_id from combined where date_format(order_date ,"%Y")=2011
and cust_id in
( select  cust_id from combined where date_format(order_date,"%m") in (1 and 2 and 3 and 4 and 5 and 6 and 7 and 8 and 9 and 10 and 11 and 12)));


select cust_id,count(cust_id) from combined
where date_format(order_date,"%m") = all (1,2,3,4,5,6,7,8,9,10,11,12) ;
-- select  cust_id from combined where  ( date_format(order_date,"%m")=1 and  date_format(order_date,"%m")=2) and  date_format(order_date,"%m")=3;# and  date_format(order_date,"%m")=4 and date_format(order_date,"%m")= 5 and  date_format(order_date,"%m")= 6and  date_format(order_date,"%m")=7and  date_format(order_date,"%m")= 8 and  date_format(order_date,"%m")=9 and  date_format(order_date,"%m")=10 and  date_format(order_date,"%m")=11 and  date_format(order_date,"%m")= 12);


-- RESTAURANT DATABASE QUESTIONS


create database restaurant_db;

-- Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
select * from chefmozaccepts;
select * from chefmozcuisine;
select * from chefmozhours4;
select * from chefmozparking;
select * from geoplaces2;
select * from rating_final;
select * from usercuisine;
select * from userpayment;
select * from userprofile;

-- 2.Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.

select r.placeid,rating,avg(rating) as avg_rating ,g.price from rating_final r join geoplaces2 g
on r.placeID=g.placeID
where alcohol!="No_alcohol_served"
group by r.placeid,g.price,rating;

-- Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol 
-- categories along with the total number of restaurants.

select g.placeid,parking_lot,g.alcohol,count(g.placeid) as tot_no_of_restaurants
from chefmozparking cp join geoplaces2 g 
on cp.placeID=g.placeID
group by g.placeid,g.alcohol,parking_lot;

-- Question 4: -Also take out the percentage of different cuisine in each alcohol type.
select cc.Rcuisine,concat(round((count(cc.Rcuisine)/(select count(Rcuisine) from chefmozcuisine))*100,2),"%") as percentage_of_cuisines,alcohol
 from chefmozcuisine cc
join geoplaces2 g on cc.placeID=g.placeID
group by alcohol,cc.rcuisine;

-- Questions 5: - let’s take out the average rating of each state.
#select avg(rating),place_id from rating_final where placeID in


select avg(rating) as avg_rating ,state from rating_final r join geoplaces2 g
on r.placeID=g.placeID 
group by state;

-- Questions 6: -' Tamaulipas' Is the lowest average rated state. 
-- Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.
select distinct(alcohol),count(c.rcuisine) as tot_no_of_cuisine,c.rcuisine from geoplaces2 g
join chefmozcuisine c using(placeid)
where state="Tamaulipas"
group by c.rcuisine,alcohol;
# tamaulipas has only 16 franchises in tamaulipas state,
# predominantly most of the areas are closed, alcohol is not served in any restaurants 

select * from geoplaces2
where state="tamaulipas";

-- Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of cuisine, 
-- and also their budget level is low.
-- We encourage you to give it a try by not using joins.

select name from geoplaces2 where placeID in 
(select placeID from chefmozcuisine
where Rcuisine="mexican" or Rcuisine="Italian");


select up.userID,avg(weight) as avg_weight, avg(food_rating) as avg_food_rat,avg(service_rating) as avg_ser_rat 
from userprofile up join rating_final rf on up.userID=rf.userID
join usercuisine uc on uc.userID=rf.userID
join geoplaces2 g on g.placeID=rf.placeID
where name="KFC" and Rcuisine="Italian" and budget="low"
group by up.userid;

select * from userprofile where userid="U1008"






# (triggers not taught)