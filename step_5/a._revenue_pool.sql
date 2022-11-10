-- create revenue pool and insert
  -- fire tv and roku
  insert into rev_pool(revenue, department_id, year_month_day, quarter, year, month, viewership_type)
  select sum(tot_revenue), department_id, year_month_day, quarter, year, month, 'VOD'
  from monthly_revenue 
  where department_id in (2, 5) and year = 2022 and quarter = 'q2'
  group by department_id, year_month_day, quarter, year, month
  
  -- non fire tv and roku (Mobile/Web)
  insert into rev_pool(revenue, department_id, year_month_day, quarter, year, month, viewership_type)
  select sum(tot_revenue), 6, year_month_day, quarter, year, month, 'VOD'
  from monthly_revenue 
  where department_id not in (2, 5) and year = 2022 and quarter = 'q2'
  group by year_month_day, quarter, year, month


-- REVENUE SHARE UPDATE on POWR

    -- roku and firetv update
    update powr_viewership  p
    set p.rev_share = q.rev_share
    from(
        select p.id as id, p.year_month_Day, p.dept_share * r.revenue as rev_share, p.content_provider from powr_viewership p
        join rev_pool r on (p.year_month_day = r.year_month_day and p.department_id = r.department_id) 
        where r.department_id != 6 and p.year = 2022 and p.quarter = 'q2' and p.platform != 'undefined'
    ) q 
    where p.id = q.id 

    -- mobile/web update
    update powr_viewership  p
    set p.rev_share = q.rev_share
    from(
        select p.id as id, p.year_month_Day, p.dept_share * r.revenue as rev_share, p.content_provider from powr_viewership p
        join rev_pool r on (p.year_month_day = r.year_month_day and p.department_id in (1,3,4)) 
        where r.department_id = 6 and p.year = 2022 and p.quarter = 'q2'
    ) q 
    where p.id = q.id

-- Check REV_SHARE (Topline Total)
select sum(rev_share) from powr_viewership where year = 2021 and quarter = 'q1'

-- Check MONTHLY_REVENUE Topline Total
select sum(tot_revenue) from monthly_revenue where year = 2021 and quarter = 'q1' 
