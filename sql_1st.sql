CREATE TABLE sales_store (transaction_id	VARCHAR (25),
customer_id	VARCHAR (25),
customer_name	VARCHAR (25),
customer_age	INT,
gender	VARCHAR(15),
product_id	VARCHAR(15),
product_name	VARCHAR(15),
product_category	VARCHAR(15),
quantiy	INT,
prce	FLOAT,
payment_mode	VARCHAR(30),
purchase_date	DATE,
time_of_purchase	TIME,
status	VARCHAR(20)
);

select * from sales_store;

COPY sales_store
FROM 'C:\DATA1\sales_store_updated_allign_with_video.csv'
DELIMITER ','
CSV HEADER;
SELECT * INTO sales FROM sales_store;

--check dublicates in transactions_id

select transaction_id, count(*) as rep_count from sales_store
group by transaction_id
having count(transaction_id)>1;

select *, 
   row_number() over(partition by (transaction_id) order by transaction_id) as dublicate_count
from sales_store;
select * from cte 
where transaction_id in ('TXN240646',
'TXN342128',
'TXN855235',
'TXN981773') 

--delete dublicate
with cte as (
select *, 
   row_number() over(partition by (transaction_id) order by transaction_id) as dublicate_count
from sales_store
)

delete from sales_store
using cte
where sales_store.transaction_id = cte.transaction_id
and dublicate_count>1

--correction of headers
alter table sales_store
rename column prce to price;
select * from sales_store;

alter table sales_store
rename column quantiy to quantity;
select * from sales_store;

--check data type of the columns

select column_name, data_type
from information_schema.columns
where table_name='sales_store'

--to check null values

select * from sales_store
where transaction_id is null
or
customer_id is null
or
customer_name is null
or
customer_age is null
or
gender is null
or
product_id is null
or
product_name is null
or
product_category is null
or 
quantity is null
or
price is null
or
payment_mode is null
or
purchase_date is null
or
time_of_purchase is null
or 
status is null


select * from sales_store
where customer_id = 'CUST1003'

update sales_store 
set customer_id = 'CUST9494'
where customer_name = 'Ehsaan Ram'
and customer_id is null;



update sales_store 
set customer_id = 'CUST1401'
where customer_name = 'Damini Raju'
and customer_id is null;


update sales_store 
set customer_name = 'Mahika Saini', customer_age = 35, gender = 'Male'
where customer_id = 'CUST1003' ; 

update sales_store 
set gender = 'Male'
where gender = 'M' ;

update sales_store 
set gender = 'Female'
where gender = 'F' ;

select * from sales_store;

update sales_store 
set payment_mode = 'Credit Card'
where payment_mode = 'CC' ;

--Data Analysis
--@1. Whata are the top 5 most selling products by quantity.

select product_name, sum(quantity) as product_count from sales_store
where status = 'delivered'

update table 
group by product_name
order by product_count desc
limit 5;

--Business Impact : Helps in prioritize stock and boost sales through targeted promotions.

--@2. What time of the day has the highest number of purchase? 

alter table sales_store 
add column purchase_shift varchar(30);

update sales_store
set purchase_shift = case 
when time_of_purchase between '06:00:00' and '10:59:59' then 'Morning_time'
when time_of_purchase between '12:00:00' and '16:59:59' then 'Mid-day_time'
when time_of_purchase between '17:00:00' and '23:00:59' then 'Evening_time'
else 'Night_time'
end;

select purchase_shift, count(*) as MaxSale_Count
from sales_store 
Group by purchase_shift 
order by MaxSale_Count desc; 

--Business Impact: Optimize staffing, provide offers, Promotions


--Q 3. Who are the top high paying caustomers?

select customer_name,
         '₹' || to_char(sum (quantity*price),'fm999,999,999.00') as total_spend 
		 from sales_store
group by customer_name
order by sum (quantity*price) desc limit 5
; 

select * from sales_store;

--Business Impact: Provide offers to them and can be given some loyality award.

--Q 4. What is the return/cancellation rate per product category ?

select product_category, 
          to_char (sum (case when status = 'cancelled' then quantity else 0 end )*100/sum(quantity) ::numeric  ,
		  'fm999,999,999.00')|| '%'  as cancel_rate,
		  to_char (sum(case when status = 'returned' then quantity else 0 end )*100/sum(quantity)::numeric, 
		  'fm999,999,999.00') || '%' as return_rate
from sales_store
group by product_category  
order by (sum (case when status = 'cancelled' then quantity else 0 end )*100/sum(quantity)) ::numeric desc,  
       (sum (case when status = 'returned' then quantity else 0 end )*100/sum(quantity)) ::numeric desc
;

--@5. What is the monthly sales trend

select to_char(purchase_date,'yyyy-mm') as year_month, 
        '₹' || to_char(sum(quantity*price),'fm999,999,999.00') as total_sale,
		sum(quantity) as total_quantity
from sales_store
group by to_char(purchase_date,'yyyy-mm')
order by year_month;
---------------------------------------------------------
select extract (month from purchase_date) as months,
       '₹' || to_char(sum(quantity*price),'fm999,999,999.00') as total_sale,
	   sum(quantity) as total_quantity  
from sales_store
group by extract (month from purchase_date)
order by months ;
