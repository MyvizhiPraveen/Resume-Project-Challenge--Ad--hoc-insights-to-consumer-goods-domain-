select * from dim_customer;
select * from fact_gross_price;
select * from fact_pre_invoice_deductions;

select count(customer_code) from dim_customer;
/* ad-hoc request 1*/
select distinct(market) from dim_customer where customer = "Atliq Exclusive" and region ="APAC";

select * from dim_product;
select * from fact_manufacturing_cost;
select * from fact_sales_monthly
fact_manufacturing_cost/* ad-hoc request 2*/
WITH products_2020 as 
(select count(distinct product_code) as unique_products_2020
from fact_sales_monthly where fiscal_year = 2020),
products_2021 as 
(select count(distinct product_code) as unique_products_2021
from fact_sales_monthly where fiscal_year = 2021)

select unique_products_2020,unique_products_2021,
 round(((unique_products_2021-unique_products_2020)/unique_products_2020)*100,2)
as percentage_chg from products_2020,products_2021;

/*ad-hoc request 3*/
select segment,count(distinct product_code)as product_count from dim_product
group by segment order by product_count desc;

/*ad-hoc request 4*/
WITH unique_products as
(select segment,count(distinct case when fiscal_year=2020 then a.product_code end)as product_count_2020,
count(distinct case when fiscal_year=2021 then a.product_code end)as product_count_2021
from dim_product a 
join fact_gross_price b on a.product_code=b.product_code
group by segment)
select segment,product_count_2020,product_count_2021,(product_count_2021-product_count_2020)
as difference from unique_products group by segment order by difference desc;

/*ad-hoc request 5*/
select a.product_code,product,manufacturing_cost
from dim_product a right join fact_manufacturing_cost b
on a.product_code=b.product_code 
where manufacturing_cost in 
(select max(manufacturing_cost) from fact_manufacturing_cost) or
manufacturing_cost in (select min(manufacturing_cost) from fact_manufacturing_cost);

/*ad-hoc request 6*/
select a.customer_code,b.customer,avg(distinct pre_invoice_discount_pct) as average_discount_percentage
from dim_customer a join fact_pre_invoice_deductions b
on a.customer_code = b.customer_code and fiscal_year = 2021 
group by b.customer
order by customer desc limit 5;