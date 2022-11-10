-- insert viewership by dept and month (firetv & roku)
    insert into  monthly_viewership(tot_viewership, department_id, department_name, year_month_day, usage, quarter, month, year)
    select sum(watch_time_seconds), d.id, d.name, year_month_day, 'powr viewership share' as usage, quarter, month, year from powr_viewership p
    join dictionary.public.temp_departments d on (d.id = p.department_id)
    where quarter = 'q1' and year = 2021 and p.department_id in (2,5)
    group by d.name, p.year_month_day, d.id, p.month, p.year, p.quarter


-- insert viewership by dept and month (firetv & roku)
    insert into  monthly_viewership(tot_viewership, department_id, department_name, year_month_day, usage, quarter, month, year)
    select sum(watch_time_seconds), 6, 'mobile/web', year_month_day, 'powr viewership share' as usage, quarter, month, year from powr_viewership p
    where quarter = 'q1' and year = 2021 and department_id in (1,3,4) 
    group by year_month_day, month, year, quarter
    
    
-- update share on records (roku & Firetv)
    update powr_viewership p
    set p.dept_share = q.dept_share
    from
    (
    select p.id as id, ref_id, WATCH_TIME_SECONDS / mv.TOT_VIEWERSHIP as dept_share, p.year_month_day, d.name from powr_viewership p
    join monthly_viewership mv on (mv.year_month_day = p.year_month_day and mv.department_id  = p.department_id)
    join dictionary.public.temp_departments d on (d.id = p.department_id)
    where mv.usage = 'powr viewership share' and p.year = 2021 and p.quarter = 'q1' and p.department_id in (2, 5)
    ) q
    where p.id = q.id
    
    --dept share for mobile/web
    update powr_viewership p
    set p.dept_share = q.dept_share
    from
    (
    select p.id as id, ref_id, WATCH_TIME_SECONDS / mv.TOT_VIEWERSHIP as dept_share, p.year_month_day from powr_viewership p
    join monthly_viewership mv on (mv.year_month_day = p.year_month_day)
    where mv.usage = 'powr viewership share' and p.year = 2021 and p.quarter = 'q1' and p.department_id in (1,3,4) and mv.department_id = 6
    ) q
    where p.id = q.id
   

-- create revenue pool and insert
  -- fire tv and roku
  insert into rev_pool(revenue, department_id, year_month_day, quarter, year, month, viewership_type)
  select sum(tot_revenue), department_id, year_month_day, quarter, year, month, 'VOD'
  from monthly_revenue 
  where department_id in (2, 5) and year = 2021 and quarter = 'q1'
  group by department_id, year_month_day, quarter, year, month
  
  -- non fire tv and roku (updated 9/6/22 - Mobile/Web)
  insert into rev_pool(revenue, department_id, year_month_day, quarter, year, month, viewership_type)
  select sum(tot_revenue), 6, year_month_day, quarter, year, month, 'VOD'
  from monthly_revenue 
  where department_id not in (2, 5) and year = 2021 and quarter = 'q1'
  group by year_month_day, quarter, year, month

select sum(revenue) from rev_pool where year = 2021 and quarter = 'q1'

-- roku and firetv update
update powr_viewership  p
set p.rev_share = q.rev_share
from(
    select p.id as id, p.year_month_Day, p.dept_share * r.revenue as rev_share, p.content_provider from powr_viewership p
    join rev_pool r on (p.year_month_day = r.year_month_day and p.department_id = r.department_id) 
    where r.department_id != 6 and p.year = 2021 and p.quarter = 'q1' and p.platform != 'undefined'
) q 
where p.id = q.id 


-- mobile/web update (updated 9/6/22)
update powr_viewership  p
set p.rev_share = q.rev_share
from(
    select p.id as id, p.year_month_Day, p.dept_share * r.revenue as rev_share, p.content_provider from powr_viewership p
    join rev_pool r on (p.year_month_day = r.year_month_day and p.department_id in (1,3,4)) 
    where r.department_id = 6 and p.year = 2021 and p.quarter = 'q1'
) q 
where p.id = q.id