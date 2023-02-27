-- *FINAL-COURSE PROJECT*

-- 1.(ASSGM) finding overall session and order volume by quarters for whole life of business
select
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qtr,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
group by 1, 2
order by 1, 2;

-- 2. (ASSGM) finding quarterly improvements like session-to-order cr, revenue per order and revenue per session
select
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qtr,
-- count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_to_orders_cvrt,
sum(orders.price_usd)/count(distinct orders.order_id) as revenue_per_order,
sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as revenue_per_session
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
group by 1, 2
order by 1, 2;

-- 3. (ASSGM) quarterly views of oreders from gsearch-nonbrand, bsearch-nonbrand, brand-search overall, organic-search and direct-type-in. 
-- STEP 1.
select
utm_source,
utm_campaign,
http_referer
from website_sessions
group by 1, 2, 3;

-- STEP 2. 
select
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qtr,
count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end) as gsearch_nonbrand_orders,
count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end) as bsearch_nonbrand_orders,
count(distinct case when utm_campaign = 'brand' then orders.order_id else null end) as brand_search_order,
count(distinct case when utm_source is null and http_referer is not null then orders.order_id else null end) as organic_order,
count(distinct case when utm_source is null and http_referer is null then orders.order_id else null end) as direct_typein_order
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id 
group by 1, 2
order by 1, 2;

-- 4. (ASSGM) finding sessions-to-order-conversion-rate for ASSGM-3. 
select
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qtr,
count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end)/
count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as gsearch_nonbrand_cvrt,
count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end)/
count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as bsearch_nonbrand_cvrt,
count(distinct case when utm_campaign = 'brand' then orders.order_id else null end)/
count(distinct case when utm_campaign = 'brand' then website_sessions.website_session_id else null end) as brand_search_cvrt,
count(distinct case when utm_source is null and http_referer is not null then orders.order_id else null end)/
count(distinct case when utm_source is null and http_referer is not null then website_sessions.website_session_id else null end) as organic_cvrt,
count(distinct case when utm_source is null and http_referer is null then orders.order_id else null end)/
count(distinct case when utm_source is null and http_referer is null then website_sessions.website_session_id else null end) as direct_typein_cvrt
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id 
group by 1, 2
order by 1, 2;

-- 5. (ASSGM) finding monthly trending for revenue and margin by product along with total sales and revenue.
-- STEP 1.
select*from order_items;

-- STEP 2.
select
year(created_at) as yr,
month(created_at) as mo,
sum(case when product_id = 1 then price_usd else null end) as mrfuzzy_rev,
sum(case when product_id = 1 then price_usd - cogs_usd else null end) as mrfuzzy_marg,
sum(case when product_id = 2 then price_usd else null end) as lovebear_rev,
sum(case when product_id = 2 then price_usd - cogs_usd else null end) as lovebear_marg,
sum(case when product_id = 3 then price_usd else null end) as birthdaybear_rev,
sum(case when product_id = 3 then price_usd - cogs_usd else null end) as birthdaybear_marg,
sum(case when product_id = 4 then price_usd else null end) as minibear_rev,
sum(case when product_id = 4 then price_usd - cogs_usd else null end) as minibear_marg,
sum(price_usd) as total_rev,
sum(price_usd-cogs_usd) as total_marg
from order_items
group by 1, 2;

-- 6. (ASSGM) 
-- STEP 1. 
create temporary table product_pageviews
SELECT
website_session_id,
website_pageview_id,
created_at as saw_product_page_at
from website_pageviews
where pageview_url = '/products';

-- STEP 2.
select
year(saw_product_page_at) as yr,
month(saw_product_page_at) as mo,
count(distinct product_pageviews.website_session_id) as sessions_to_product_page,
count(distinct website_pageviews.website_session_id) as clicked_to_next_page,
count(distinct website_pageviews.website_session_id)/count(distinct product_pageviews.website_session_id) as click_through_rate,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct product_pageviews.website_session_id) as product_to_order_rate
from product_pageviews
left join website_pageviews
on product_pageviews.website_session_id = website_pageviews.website_session_id
and website_pageviews.website_pageview_id > product_pageviews.website_pageview_id
left join orders
on product_pageviews.website_session_id = orders.website_session_id
group by 1, 2; 

-- 7 (ASSGM)
-- STEP 1. 
create temporary table primary_product
select 
order_id,
primary_product_id,
created_at as ordered_at
from orders
where created_at > '2014-12-05';

-- STEP 2. 
select
primary_product_id,
count(distinct order_id) as orders,
count(distinct case when cross_sell_product_id = 1 then order_id else null end) as cross_sold_p1,
count(distinct case when cross_sell_product_id = 2 then order_id else null end) as cross_sold_p2,
count(distinct case when cross_sell_product_id = 3 then order_id else null end) as cross_sold_p3,
count(distinct case when cross_sell_product_id = 4 then order_id else null end) as cross_sold_p4,
count(distinct case when cross_sell_product_id = 1 then order_id else null end)/count(distinct order_id) as p1cross_sold_rt,
count(distinct case when cross_sell_product_id = 2 then order_id else null end)/count(distinct order_id) as p2cross_sold_rt,
count(distinct case when cross_sell_product_id = 3 then order_id else null end)/count(distinct order_id) as p3cross_sold_rt,
count(distinct case when cross_sell_product_id = 4 then order_id else null end)/count(distinct order_id) as p4cross_sold_rt
from (select
primary_product.*,
order_items.product_id as cross_sell_product_id
from primary_product
left join order_items
on primary_product.order_id = order_items.order_id
and order_items.is_primary_item = 0
) as cross_sell_product
group by 1;