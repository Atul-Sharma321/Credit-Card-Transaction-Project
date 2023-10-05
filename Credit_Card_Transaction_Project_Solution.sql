


--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with cte as (
select sum(CAST(amount as bigint)) total_spend from credit_card_transaction )
select top 5 city, SUM(amount) expense,cast((sum(amount)*1.0 /total_spend) * 100 as decimal(5,2)) as 
percentage_contribution from credit_card_transaction , cte
group by city,cte.total_spend
 order by expense desc 


--2- write a query to print highest spend month and amount spent in that month for each card type
with cte as(
select DATEPART(YEAR,transaction_date) Years,DATEPART(MONTH,transaction_date) mom, card_type,sum(amount) spend_amount from credit_card_transaction
group by  DATEPART(YEAR,transaction_date),DATEPART(MONTH,transaction_date), card_type
 ),
 cte2 as (
select *,rank() over(partition by card_type order by spend_amount desc) as rn from cte)

select card_type,Years,mom,spend_amount,rn from cte2 
where rn=1





--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

with cte as(
select *, sum(amount)  over(partition by card_type order by transaction_id,transaction_date) rnw from credit_card_transaction )
,
cte2 as(select *,rank() over(partition by card_type order by rnw desc) rn from cte),cte3 as

(select * from cte2 where rnw>=1000000  )

select city,card_type,exp_type,gender,rnw from cte3 where rn=1





--4- write a query to find city which had lowest percentage spend for gold card type

--with cte as (
--select sum(CAST(amount as bigint)) total_spend from credit_card_transaction ),cte2 as(
--select  city, SUM(amount) expense,cast((sum(amount)*1.0 /total_spend) * 100 as decimal(5,2)) as 
--percentage_contribution from credit_card_transaction , cte
--where credit_card_transaction.card_type='Gold'
--group by city,cte.total_spend
--)



select city, sum(amount) total, sum(CASe when card_type='Gold' then amount else 0 end ) goldexpense,
sum(case when card_type='Gold' then amount else 0 end )*1.0/sum(amount)*100 goldpercentage from credit_card_transaction 
group by city having sum(case when card_type='Gold' then amount else 0 end )>0 order by goldpercentage


--5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with cte as (
select city,exp_type,sum(amount) totalspend from credit_card_transaction
group by city,exp_type),cte2 
as(select *,RANK() over(partition by city order by totalspend desc) higest,
RANK() over(partition by city order by totalspend ) lowest from cte)

select city, max(case when higest=1 then exp_type end ) highest,
max(case when lowest=1 then exp_type end ) lowest from cte2
group by city

--6- write a query to find percentage contribution of spends by females for each expense type


select exp_type,sum(amount) total,sum(case when gender='F' then amount else 0 end) as female_spend,
sum(case when gender='f' then amount else 0 end )*1.0/sum(amount)*100 Femaleexpense 
from credit_card_transaction

group by exp_type
order by Femaleexpense

--7- which card and expense type combination saw highest month over month growth in Jan-2014

with cte as (
select card_type,exp_type,datepart(year,transaction_date) yt
,datepart(month,transaction_date) mt,sum(amount) as total_spend
from credit_card_transaction
group by card_type,exp_type,datepart(year,transaction_date),datepart(month,transaction_date)
)
select  top 1 *, (total_spend-prev_mont_spend) as mom_growth
from (
select *
,lag(total_spend,1) over(partition by card_type,exp_type order by yt,mt) as prev_mont_spend
from cte) A
where prev_mont_spend is not null and yt=2014 and mt=1
order by mom_growth desc;


--8- during weekends which city has highest total spend to total no of transcations ratio 

select city,sum(amount)*1.0/count(*) ration from credit_card_transaction
where DATEPART(WEEKDAY,transaction_date) in(1,7)
group by city
order by ration desc
--9- which city took least number of days to reach its 500th transaction after the first transaction in that city

with cte as (

select *, ROW_NUMBER() over(partition by city  order by transaction_id,transaction_date) rn from credit_card_transaction 
)
select city, min(transaction_date) firstvalue, max(transaction_date) latestvalue, DATEDIFF(day,min(transaction_date),max(transaction_date)) as
days500,count(*) countof from cte

group by city
having count(*)=2
order by days500
