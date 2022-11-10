-- content provider share is determined by total viewership 
insert into content_provider_share (content_provider, department_id, year_month_day, total_viewership, year, quarter, month)
select p.content_provider, p.department_id, p.year_month_day, sum(watch_time_seconds),  p.year, p.quarter, p.month from powr_viewership p
where year = 2022 and quarter = 'q2' and content_provider is not null
group by p.content_provider, p.department_id, p.year_month_day, p.year, p.quarter, p.month, p.powr_share
order by p.year_month_day, p.department_id

select p.content_provider, p.department_id, p.year_month_day, sum(watch_time_seconds) from powr_viewership p
where year = 2022 and quarter = 'q2' and content_provider is not null and department_id is not null
group by p.content_provider, p.department_id, p.year_month_day
order by p.year_month_day, p.department_id


--content_provider_share check
select * from content_provider_share where year = 2022 and quarter = 'q2'

-- monthly viewership - sum viewership minutes, grouped by department and year_month_day
-- content provider viewership - sum viewership minutes grouped by content_provider,  year_month_day and department
-- content provider share is determined by content provider viewership / monthly_viewership 


--different cp query
insert into content_provider_share (content_provider, department_id, year_month_day, total_viewership, year, quarter, month)
select content_provider, department_id, year_month_day, sum(watch_time_seconds), year, quarter, month from powr_viewership p
where year = 2022 and quarter = 'q2' and content_provider is not null and department_id is not null
group by content_provider, department_id, year_month_day, year, quarter, month
order by year_month_day, department_id



-- insert viewership by dept and month (used for 1,3,4 departments...)
    insert into  monthly_viewership(tot_viewership, department_id, department_name, year_month_day, usage, quarter, month, year)
    select sum(watch_time_seconds), d.id, d.name, year_month_day, 'powr viewership share' as usage, 'q2', month, year from powr_viewership p
    join dictionary.public.temp_departments d on (d.id = p.department_id)
    where quarter = 'q2' and year = 2022 and p.department_id not in (2,5)
    group by d.name, p.year_month_day, d.id, p.month, p.year


--CONTENT_PROVIDER_SHARE table
select * from content_provider_share where year = 2022 and quarter = 'q2'

-- set the share of the content provider so that we can multiply by revenue to get rev_share (firetv/roku)
update content_provider_share c
set c.cp_share = q.cp_share
from (
  select c.id as id, c.year_month_day,c.department_id,c.content_provider, c.total_viewership / mv.tot_viewership as cp_share  from content_provider_share c
  join monthly_viewership mv on (mv.department_id = c.department_id and mv.year_month_day = c.year_month_day)
  where mv.usage = 'powr viewership share' and mv.department_id is not null and c.year = 2022 and c.quarter = 'q2' and c.department_id in (2,5)
) q
where c.id = q.id

-- set the share of the content provider so that we can multiply by revenue to get rev_share (web/mobile)
update content_provider_share c
set c.cp_share = q.cp_share
from (
  select c.id as id, c.year_month_day,c.department_id,c.content_provider, c.total_viewership / mv.tot_viewership as cp_share  from content_provider_share c
  join monthly_viewership mv on (mv.year_month_day = c.year_month_day)
  where mv.usage = 'powr viewership share' and mv.department_id is not null and c.year = 2022 and c.quarter = 'q2' and c.department_id in (1,3,4) and mv.department_id = 6
) q
where c.id = q.id

-- set the share of the content provider so that we can multiply by revenue to get rev_share #2 (This is the one used where it calculates for all depts)
update content_provider_share c
set c.cp_share = q.cp_share
from (
  select c.id as id, c.year_month_day,c.department_id,c.content_provider, c.total_viewership / mv.tot_viewership as cp_share  from content_provider_share c
  join monthly_viewership mv on (mv.department_id = c.department_id and mv.year_month_day = c.year_month_day)
  where mv.usage = 'powr viewership share' and mv.department_id is not null and c.year = 2022 and c.quarter = 'q2' 
) q
where c.id = q.id

select * from monthly_viewership where year = 2022 and quarter = 'q1'

-- should roughly equal 1 (FireTV and Roku CTV App) - This can be deprecated? - Not used when MONTHLY_VIEWERSHIP is inserted by all individual depts
select sum(cp_share) from content_provider_share
where year = 2022 and quarter = 'q2' and department_id in (2,5)
group by year_month_day, department_id

-- should roughly equal 1 (Mobile/Web) - This can be deprecated? - Not used when MONTHLY_VIEWERSHIP is inserted by all individual depts
select sum(cp_share) from content_provider_share
where year = 2022 and quarter = 'q2' and department_id in (1,3,4)
group by year_month_day

-- should roughly equal 1 (ALL departments) - USED
select sum(cp_share) from content_provider_share
where year = 2022 and quarter = 'q2'
group by year_month_day, department_id


-- revenue query
select c.id as id, c.year_month_day,c.department_id,c.content_provider, c.cp_share * mr.tot_revenue as rev_share, cp_share, partner from content_provider_share c
join monthly_revenue mr on (mr.department_id = c.department_id and mr.year_month_day = c.year_month_day)
where  mr.department_id is not null and c.year = 2022 and c.quarter = 'q2' 


-- insert into register (revenue)
insert into register (
    year_month_day,
    department_id, 
    content_provider, 
    amount, 
    description,
    title,
    year,
    month,
    quarter,
    label,
    type
)
select c.year_month_day, c.department_id, c.content_provider, c.cp_share * mr.tot_revenue as amount, mr.description, title, c.year, c.month, c.quarter, 'Revenue' as label, type from content_provider_share c
join monthly_revenue mr on (mr.department_id = c.department_id and mr.year_month_day = c.year_month_day)
where  mr.department_id is not null and c.year = 2022 and c.quarter = 'q2' 

----- EXPENSES REGISTER

select * from powr_viewership where year = 2022 and quarter = 'q2'


--cp share expenses
insert into cp_share_expense (content_provider, year_month_day, quarter, year, month, powr_share)
select content_provider, year_month_day, quarter, year, month, sum(powr_share) from powr_viewership
where year = 2022 and quarter = 'q2' and ref_id is not null and department_id is not null
group by content_provider, year_month_day, quarter, year, month

select * from cp_share_expense where year = 2022 and quarter = 'q2'

--to insert into register (expenses)
insert into register (year_month_day, year, quarter, month, content_provider, amount, partner, department_id, label, type)
select c.year_month_day, c.year, c.quarter, c.month, c.content_provider, c.powr_share * -me.amount, me.title, me.department_id, 'Expense' as Label, type from cp_share_expense c
join monthly_expenses me on (me.year_month_day = c.year_month_day)
where c.year = 2022 and c.quarter = 'q2' 

select * from monthly_expenses where year = 2022 and quarter = 'q2'

update monthly_expenses
set department = 'Mobile/Web/Fire', department_id = 7
where year = 2022 and quarter = 'q2' and partner = 'powr'


