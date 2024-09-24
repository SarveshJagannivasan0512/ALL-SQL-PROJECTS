use casestudy;
select * from address;
select * from carton;
select * from online_customer;
select * from order_header;
select * from order_items;
select * from product;
select * from product_class;
select * from shipper;

-- 1. Display the product details as per the following criteria and sort them in descending order of category:
   #a.  If the category is 2050, increase the price by 2000
   #b.  If the category is 2051, increase the price by 500
   #c.  If the category is 2052, increase the price by 600
select * ,
case
when product_class_code=2050 then (2000+product_price)
when product_class_code=2051 then (500+product_price)
when product_class_code=2052 then (600+product_price)
else (0+product_price)
end as categorical_price
from product;

-- 2. List the product description, class description and price of all products which are shipped. 
select * from product;
select * from product_class;
select * from shipper;
select * from order_header;

select product_id,product_desc,product_class_desc,product_price from order_header oh join order_items oi using(order_id)
join product p using(product_id) 
join product_class pc using(product_class_code)
where order_status="Shipped";

-- 3. Show inventory status of products as below as per their available quantity:
#a. For Electronics and Computer categories, if available quantity is < 10, show 'Low stock', 11 < qty < 30, show 'In stock', > 31, show 'Enough stock'
#b. For Stationery and Clothes categories, if qty < 20, show 'Low stock', 21 < qty < 80, show 'In stock', > 81, show 'Enough stock'
#c. Rest of the categories, if qty < 15 – 'Low Stock', 16 < qty < 50 – 'In Stock', > 51 – 'Enough stock'
#For all categories, if available quantity is 0, show 'Out of stock'.

select product_id,p.product_class_code,product_class_desc,product_quantity_avail,
case
when product_desc="Electronics" and product_quantity_avail <10 then "Low stock"
when product_desc="Electronics" and 11<product_quantity_avail<30 then "In stock"
when product_desc="Electronics" and product_quantity_avail>31 then "Enough stock"
when product_desc="Stationery" and product_quantity_avail <20 then "Low stock"
when product_desc="Stationery" and 21<product_quantity_avail<80 then "In stock"
when product_desc="Stationery" and product_quantity_avail>81 then " Enough stock"
when product_desc="Clothes" and product_quantity_avail <20 then "Low stock"
when product_desc="Clothes" and 21<product_quantity_avail<80 then "In stock"
when product_desc="Clothes" and product_quantity_avail>81 then " Enough stock"
when product_desc not in ("Electronics","stationery","clothes") and product_quantity_avail <15 then "Low stock"
when product_desc not in ("Electronics","stationery","clothes") and 16<product_quantity_avail <50 then "In stock"
when product_desc not in ("Electronics","stationery","clothes") and product_quantity_avail>51 then "Enough stock"
else " Out of stock"
end as inventory_status
from product p join product_class pc using(product_class_code)
group by product_id,p.product_class_code,product_class_desc,product_quantity_avail;


-- 4. List customers from outside Karnataka who haven’t bought any toys or books
select customer_id,concat(customer_fname, " ",customer_lname) as customer_name,state,product_class_desc
from address a join online_customer oc using(address_id)
join order_header oh using(customer_id)
join order_items oi using(order_id)
join product p using(product_id)
join product_class pc using(product_class_code)
where state="Karnataka" and product_class_desc not in ("Toys","books");

-- (15th question is incomplete)
create database bank_project;
use bank_project;
create table bank_mstr
(branch_no int not null,
name char(50) not null,
primary key(branch_no));

create table employee
(emp_no int not null,
branch_no int,
fname char(20),
mname char(20),
lname char(20),
dept char(20),
desig char(10),
manager_no int not null,
primary key(emp_no),
foreign key(branch_no) references bank_mstr(branch_no));

create table customer 
(cust_id int not null,
fname char(30),
mname char(30),
lname char(30),
occupation char(10),
dob date,
primary key(cust_id));

create table Account
( acnumber int not null,
cust_id int not null,
branch_id int not null,
curbal int,
acc_type char(20),
open_date date,
ac_status char(20),
primary key(acnumber),
foreign key(cust_id) references customer(cust_id),
foreign key(branch_id) references bank_mstr(branch_no));

insert into bank_mstr values(1,"Delhi"),(2,"Mumbai");
insert into customer values(1,"Ramesh","chandra","sharma","service","1976-12-06"),(2,"Avinash","sundar","minha","business","1974-10-16");
insert into account values(1,1,1,10000,"saving","2012-12-15","active"),(2,2,2,5000,"saving","2012-06-12","active");
insert into employee values(1,1,"Mark","steve","lara","account","accountant",2),(2,2,"bella","james","ronald","loan","manager",1);

select * from bank_mstr;
select * from customer;
select * from account;
select * from employee;

-- 3.	Select unique occupation from customer table
select distinct(occupation) from customer;

-- 4.	Sort accounts according to current balance 
select * from account
order by curbal desc;

-- 5.	Find the Date of Birth of customer name ‘Ramesh’
select concat(fname," ",mname," ",lname) as cust_name ,dob from customer 
where fname="Ramesh";

-- 6.	Add column city to branch table 
alter table bank_mstr add column city char(20);

-- 7.	Update the mname and lname of employee ‘Bella’ and set to ‘Karan’, ‘Singh’ 
update employee
set mname="Karan",lname="singh"
where fname="bella";

-- 8.	Select accounts opened between '2012-07-01' AND '2013-01-01'
select * from account 
where open_date between "2012-07-01" and "2013-01-01";

-- 9.	List the names of customers having ‘a’ as the second letter in their names 
select * from customer
where lname like "_a%";

-- 10.	Find the lowest balance from customer and account table
select min(curbal) as lowest_balance from customer c join account a using(cust_id);

-- 11.	Give the count of customer for each occupation
select occupation,count(*) as cnt_of_cust from customer 
group by occupation;

-- 12.	Write a query to find the name (first_name, last_name) of the employees who are managers.
select concat(fname," ",mname," ",lname) from employee
where desig="manager";

-- 13.	List name of all employees whose name ends with a
select * from employee 
where lname like "%a";

-- 14.	Select the details of the employee who work either for department ‘loan’ or ‘credit’
select * from employee
where dept="loan" or dept="credit";

-- 15.	Write a query to display the customer number, customer firstname, account number for the
-- 16.	Write a query to display the customer’s number, customer’s firstname, branch id and balance amount for people using JOIN.
alter table account rename column branch_id to branch_no;
select cust_id,fname,branch_no,curbal
from customer c join account a using(cust_id)
join bank_mstr b using(branch_no);

-- 17.	Create a virtual table to store the customers who are having the accounts in the same city as they live
-- 18.	A. Create a transaction table with following details 
-- TID – transaction ID – Primary key with autoincrement 
-- Custid – customer id (reference from customer table
-- account no – acoount number (references account table)
-- bid – Branch id – references branch table
-- amount – amount in numbers
-- type – type of transaction (Withdraw or deposit)
-- DOT -  date of transaction
create table transaction
(TID int not null auto_increment,
cust_id int,
acnumber int,
branch_no int,
amount int ,
Type char(20),
DOT date,
primary key(TID));


-- 19.	Write a query to display the details of customer with second highest balance 
select cust_id,fname,branch_no,curbal
from customer c join account a using(cust_id)
join bank_mstr b using(branch_no)
limit 1,2;

-- a. Write trigger to update balance in account table on Deposit or Withdraw in transaction table
-- b. Insert values in transaction table to show trigger success
-- (triggers not taught)
-- 20.	Take backup of the databse created in this case study



