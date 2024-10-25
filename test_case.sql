-- NOTE : Transaksi berhasil kalau paid_at dan delivery_at not null -- 
-- 1. Calculate the sum of the user's 10 largest transactions 12476
select
	u.nama_user,
    o.buyer_id,
    sum(total) as total_transaction
from orders as o
left join users as u
on o.buyer_id = u.user_id
group by
	u.nama_user,
    o.buyer_id
order by total_transaction desc;

-- 2. What is the trend of the number of transactions and total transaction value per month since January 2020
with orders_monthly as (
select 
	*
	,CONCAT(YEAR(created_at), '-', LPAD(MONTH(created_at), 2, '0')) AS tahun_bulan
from orders
where 
	created_at >= '2020-01-01' 
	and paid_at <> 'NA'
    and delivery_at <> 'NA'
)
select 
	tahun_bulan
    ,count(order_id) as count_order
    ,sum(total) as total_transaction
from orders_monthly
group by tahun_bulan
order by tahun_bulan asc;

-- 3. Who are the buyers with the highest number of transactions in January 2020, and what is the average transaction value?
select
	u.nama_user,
    o.buyer_id,
    sum(total) as total_transaction,
    avg(total) as avg_transaction
from orders as o
left join users as u
on o.buyer_id = u.user_id
where o.created_at between '2020-01-01' and '2020-01-31'
group by
	u.nama_user,
    o.buyer_id
order by total_transaction desc;

-- 4. Show big transactions in December 2019 approximately transaction value >= 20 million
select *
from orders
where 
	created_at between '2019-12-01' and '2019-12-31'
	and total >= 20000000 
    and paid_at <> 'NA'
    and delivery_at <> 'NA'
order by total desc;

-- 5. Create a query based on Best Selling Product Category in 2020
with order_wiht_cat as (
select 
	o.order_id,
    od.product_id,
    p.category,
    od.quantity,
    od.price,
    o.created_at,
    o.total
from orders as o
left join order_details as od
on o.order_id = od.order_id
left join products as p
on od.product_id = p.product_id
where 
	o.created_at between '2020-01-01' and '2020-12-31'
	and o.paid_at <> 'NA'
    and o.delivery_at <> 'NA'
)
select 
    p.category,
    sum(cat.quantity) as total_quantity
from order_wiht_cat as cat
left join products as p
on cat.product_id = p.product_id
group by p.category
order by total_quantity desc;

-- 6. Create and search for buyers with high value
select 
    u.nama_user,
    o.buyer_id,
    sum(total) as total_buyer_transaction
from orders as o
left join users as u
on o.buyer_id = u.user_id
where
	o.paid_at <> 'NA'
    and o.delivery_at <> 'NA'
group by 
	u.nama_user,
    o.buyer_id
order by total_buyer_transaction desc;

-- 7. Who are the buyers who made at least 10 transactions with different zip codes in each transaction, and what is the total and average value of the transactions
select
	u.nama_user as nama_buyer,
    o.buyer_id,
    count(o.order_id) as cnt_transaction,
    sum(total) as total_transaction
from orders as o
left join users as u
on o.buyer_id = u.user_id
where 
	o.paid_at <> 'NA'
    and o.delivery_at <> 'NA'
group by
	u.nama_user,
    o.buyer_id
having count(distinct(o.order_id)) >= 8
order by cnt_transaction desc;

-- 8. Who are the users with at least 7 purchase transactions and how many purchase and sales transactions have they made?
select
	u.nama_user as nama_buyer,
    o.buyer_id,
    count(o.order_id) as cnt_transaction,
    sum(total) as total_transaction
from orders as o
left join users as u
on o.buyer_id = u.user_id
group by
	u.nama_user,
    o.buyer_id
having count(distinct(o.order_id)) >= 7
order by cnt_transaction desc;

-- 9. Who are the buyers With at least 8 transactions, an average quantity of items per transaction of more than 10,and the largest total transaction value?
select 
	o.order_id,
    o.buyer_id,
    u.nama_user,
    avg(od.quantity) as avg_quantity,
    o.total
from orders as o
left join order_details as od
on o.order_id = od.order_id
left join products as p
on od.product_id = p.product_id
left join users as u
on o.buyer_id = u.user_id
where 
	o.paid_at <> 'NA'
    and o.delivery_at <> 'NA'
group by 
	o.order_id,
    o.buyer_id,
    u.nama_user,
    o.total
having avg(od.quantity) > 10
order by total desc
limit 1;

-- 10. What is the average, minimum, and maximum time it takes to settle payments per month, and how many transactions are paid each month?
with orders_monthly as (
select 
	*
	,CONCAT(YEAR(created_at), '-', LPAD(MONTH(created_at), 2, '0')) AS tahun_bulan
    ,DATEDIFF(paid_at, created_at) AS date_diff
from orders
where 
	paid_at <> 'NA'
    and delivery_at <> 'NA'
)
select 
	tahun_bulan,
    avg(date_diff) as avg_date_diff,
    min(date_diff) as min_date_diff,
    max(date_diff) as max_date_diff,
    count(order_id) as cnt_total_transaction
from orders_monthly
group by tahun_bulan
order by tahun_bulan asc;