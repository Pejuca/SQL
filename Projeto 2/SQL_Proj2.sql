-- (Query 1) Gênero dos leads
-- Colunas: gênero, leads(#)

select gen.gender, count(gen.gender) as gender_count
from sales.customers as cus
left join temp_tables.ibge_genders as gen
	on initcap(cus.first_name)=initcap(gen.first_name)
group by gen.gender
order by gender_count


-- (Query 2) Status profissional dos leads
-- Colunas: status profissional, leads (%)


select
	cus.professional_status, (count(fun.visit_page_date)::float)/
							  (select count(visit_page_date) from sales.funnel) as "leads %"

from sales.customers as cus
left join sales.funnel as fun
on cus.customer_id=fun.customer_id
group by cus.professional_status
order by "leads %" desc

-- A instrutora tinha feito somente usando customer_id mas quis modificar para considerar como lead
-- somente quem visitava o site.

-- (Query 3) Faixa etária dos leads
-- Colunas: faixa etária, leads (%)

select
	case
	when (current_date-cus.birth_date)/365<=20 then '0 a 20'
	when (current_date-cus.birth_date)/365>20 and (current_date-cus.birth_date)/365<=40 then '21 a 40'
	when (current_date-cus.birth_date)/365>40 and (current_date-cus.birth_date)/365<=60 then '41 a 60'
	when (current_date-cus.birth_date)/365>60 and (current_date-cus.birth_date)/365<=80 then '61 a 80'
	else '80+'
	end as faixa_etaria,
	(count(fun.visit_page_date)::float)/(select count(visit_page_date) from sales.funnel) as "leads %",
		case
	when (current_date-cus.birth_date)/365<=20 then '1'
	when (current_date-cus.birth_date)/365>20 and (current_date-cus.birth_date)/365<=40 then '2'
	when (current_date-cus.birth_date)/365>40 and (current_date-cus.birth_date)/365<=60 then '3'
	when (current_date-cus.birth_date)/365>60 and (current_date-cus.birth_date)/365<=80 then '4'
	else '5'
	end as indexacao

from sales.customers as cus
left join sales.funnel as fun
on cus.customer_id=fun.customer_id
group by faixa_etaria, indexacao
order by indexacao 


-- (Query 4) Faixa salarial dos leads
-- Colunas: faixa salarial, leads (%), ordem

select
	case
	when cus.income<=5000 then '0 a 5000'
	when cus.income>5000 and cus.income<=10000 then '5001 a 10000'
	when cus.income>10000 and cus.income<=15000 then '10001 a 15000'
	when cus.income>15000 and cus.income<=20000 then '15001 a 20000'
	else '20001+'
	end as faixa_salarial,
	(count(fun.visit_page_date)::float)/(select count(visit_page_date) from sales.funnel) as "leads %",
	case
	when cus.income<=5000 then '1'
	when cus.income>5000 and cus.income<=10000 then '2'
	when cus.income>10000 and cus.income<=15000 then '3'
	when cus.income>15000 and cus.income<=20000 then '4'
	else '5'
	end as indexacao

from sales.customers as cus
left join sales.funnel as fun
on cus.customer_id=fun.customer_id
group by faixa_salarial,indexacao
order by indexacao 


-- (Query 5) Classificação dos veículos visitados
-- Colunas: classificação do veículo, veículos visitados (#)
-- Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos

select 
	case
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>2 then 'seminovos'
	else 'novos'
	end as classificacao,
	count(funn.visit_page_date) as visitas
from sales.funnel as funn
left join sales.products as prod
on funn.product_id=prod.product_id
group by classificacao
order by visitas

select * from sales.products

-- (Query 6) Idade dos veículos visitados
-- Colunas: Idade do veículo, veículos visitados (%), ordem

select 
	case
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=2 then 'Até 2'
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>2 
		and (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=4 then '2 a 4'
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>4 
		and (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=6 then '4 a 6'
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>6 
		and (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=8 then '6 a 8'
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>8 
		and (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=10 then '8 a 10'	
	else 'Mais que 10'
	end as vehicle_age,
	(count(funn.visit_page_date)::float)/(select count(visit_page_date) from sales.funnel) as visitas,
	case
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=2 then '1'
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>2 
		and (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=4 then '2'
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>4 
		and (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=6 then '3'
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>6 
		and (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=8 then '4'
	when (extract('year' from funn.visit_page_date)::int-prod.model_year::int)>8 
		and (extract('year' from funn.visit_page_date)::int-prod.model_year::int)<=10 then '5'	
	else '6'
	end as indexacao
from sales.funnel as funn
left join sales.products as prod
on funn.product_id=prod.product_id
group by vehicle_age, indexacao
order by indexacao



-- (Query 7) Veículos mais visitados por marca
-- Colunas: brand, model, visitas (#)

select prod.brand,prod.model,count(funn.visit_page_date) as visitas

from sales.funnel as funn
left join sales.products as prod
on funn.product_id=prod.product_id
group by prod.brand,prod.model
order by prod.brand,prod.model,visitas desc







