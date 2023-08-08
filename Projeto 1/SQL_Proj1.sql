-- (Query 1) Receita, leads, conversão e ticket médio mês a mês
-- Colunas: mês, leads (#), vendas (#), receita (k, R$), conversão (%), ticket médio (k, R$)
select * from sales.funnel
select * from sales.customers


with 
lead_counts as(
select
	date_trunc('month',visit_page_date)::date as date_month,
	count(visit_page_date) as leads
from sales.funnel
group by date_month
order by date_month
),
receitas as(
select 
	date_trunc('month', funn.paid_date)::date as date_month, 
	count(funn.paid_date) as vendas,
	round(avg(prod.price+(prod.price*funn.discount)),2) as ticket_medio, 
	sum(prod.price+(prod.price*funn.discount)) as receita
from sales.funnel as funn
left join sales.products as prod
on funn.product_id=prod.product_id
group by date_month
order by date_month
)

select
	leads.date_month, leads.leads, recs.vendas,
	recs.receita,
	round((recs.vendas*100.0/leads.leads),2) as conversao_percent,
	recs.ticket_medio
from lead_counts as leads
left join receitas as recs
	on leads.date_month=recs.date_month



-- (Query 2) Estados que mais venderam
-- Colunas: país, estado, vendas (#)
select * from sales.funnel
where visit_page_date is not null
order by visit_page_date desc


select
	'Brasil' as country, cus.state, count(fun.paid_date) as vendas
from sales.customers as cus
left join sales.funnel as fun
	on cus.customer_id=fun.customer_id
where fun.paid_date between '2021-08-01' and '2021-08-31'
group by country,cus.state
order by vendas desc

-- (Query 3) Marcas que mais venderam no mês
-- Colunas: marca, vendas (#)
select
	prod.brand, count(fun.paid_date) as vendas
from sales.funnel as fun
left join sales.products as prod
on fun.product_id=prod.product_id
where fun.paid_date between '2021-08-01' and '2021-08-31'
group by prod.brand
order by vendas desc

-- (Query 4) Lojas que mais venderam
-- Colunas: loja, vendas (#)
	select
		initcap(lower(sto.store_name)) as loja, count(fun.paid_date) as vendas
	from sales.funnel as fun
	left join sales.stores as sto
	on fun.store_id=sto.store_id
	where fun.paid_date between '2021-08-01' and '2021-08-31'
	group by loja
	order by vendas desc

-- (Query 5) Dias da semana com maior número de visitas ao site
-- Colunas: dia_semana, dia da semana, visitas (#)

select
	extract('dow' from visit_page_date) as dia_semana,
	case 
	when extract('dow' from visit_page_date)=1 then 'Segunda-feira'
	when extract('dow' from visit_page_date)=2 then 'Terça-feira'
	when extract('dow' from visit_page_date)=3 then 'Quarta-feira'
	when extract('dow' from visit_page_date)=4 then 'Quinta-feira'
	when extract('dow' from visit_page_date)=5 then 'Sexta-feira'
	when extract('dow' from visit_page_date)=6 then 'Sábado'
	when extract('dow' from visit_page_date)=0 then 'Domingo'
		end as "Dia da Semana",
	count(visit_page_date) as visitas
	from sales.funnel
	where visit_page_date between '2021-08-01' and '2021-08-31'
group by dia_semana,"Dia da Semana"
order by dia_semana
