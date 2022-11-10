-- Notes: POWR_SHARE uses grouped_viewership while DEPT_SHARE uses monthly_viewership

-- insert viewership by dept and month (firetv & roku)
    insert into  monthly_viewership(tot_viewership, department_id, department_name, year_month_day, usage, quarter, month, year)
    select sum(watch_time_seconds), d.id, d.name, year_month_day, 'powr viewership share' as usage, quarter, month, year from powr_viewership p
    join dictionary.public.temp_departments d on (d.id = p.department_id)
    where quarter = 'q2' and year = 2022 and p.department_id in (2,5)
    group by d.name, p.year_month_day, d.id, p.month, p.year, p.quarter

-- insert viewership by dept and month (mobile/web)
    insert into  monthly_viewership(tot_viewership, department_id, department_name, year_month_day, usage, quarter, month, year)
    select sum(watch_time_seconds), 6, 'mobile/web', year_month_day, 'powr viewership share' as usage, quarter, month, year from powr_viewership p
    where quarter = 'q2' and year = 2022 and department_id in (1,3,4) 
    group by year_month_day, month, year, quarter

-- update share on records (Roku & FireTV)
    update powr_viewership p
    set p.dept_share = q.dept_share
    from
    (
    select p.id as id, ref_id, WATCH_TIME_SECONDS / mv.TOT_VIEWERSHIP as dept_share, p.year_month_day, d.name from powr_viewership p
    join monthly_viewership mv on (mv.year_month_day = p.year_month_day and mv.department_id  = p.department_id)
    join dictionary.public.temp_departments d on (d.id = p.department_id)
    where mv.usage = 'powr viewership share' and p.year = 2022 and p.quarter = 'q2' and p.department_id in (2, 5)
    ) q
    where p.id = q.id
    
    --dept share for mobile/web
    update powr_viewership p
    set p.dept_share = q.dept_share
    from
    (
    select p.id as id, ref_id, WATCH_TIME_SECONDS / mv.TOT_VIEWERSHIP as dept_share, p.year_month_day from powr_viewership p
    join monthly_viewership mv on (mv.year_month_day = p.year_month_day)
    where mv.usage = 'powr viewership share' and p.year = 2022 and p.quarter = 'q2' and p.department_id in (1,3,4) and mv.department_id = 6
    ) q
    where p.id = q.id

--Check POWR Record #
select * from powr_viewership where year = 2022 and quarter = 'q2' and department_id in (1,3,4)

--Check POWR Undefined & Generic
select * from powr_viewership where year = 2022 and quarter = 'q2' and platform in ('undefined', 'generic')

-- Check MONTHLY VIEWERSHIP
select * from monthly_viewership where year = 2022 and quarter = 'q2'

--- BELOW IS FOR POWR_SHARE UPDATES --- 

-- Insert - Group Viewership
insert into grouped_viewership (tot_viewership, year_month_day, year, month, quarter, partner, viewership_type)
select sum(tot_viewership), year_month_day, year, month, quarter, 'powr' as partner, 'VOD' as viewership_type from monthly_viewership
where year = 2022 and quarter = 'q2'
group by year_month_day, year, month, quarter

-- Check Grouped Viewership
select * from grouped_viewership where year = 2022 and quarter = 'q2'

-- update share on records
    update powr_viewership p
    set p.powr_share = q.powr_share
    from
    (
    select p.id as id, p.WATCH_TIME_SECONDS / gv.tot_viewership as powr_share, p.year_month_day from powr_viewership p
    join grouped_viewership gv on (gv.year_month_day = p.year_month_day)
    where p.year = 2022 and p.quarter = 'q2' 
    ) q
    where p.id = q.id

-- REV_PER_HOUR
update powr_viewership
        set rev_per_hov = rev_share / tot_hov
        where year = 2021 and quarter ='q4' and rev_share != 0
        
        update powr_viewership
        set rev_per_mov = rev_per_hov * 60
        where year = 2021 and quarter ='q4' and rev_share != 0
        
        
        update powr_viewership
        set rev_per_hov = 0
        where year = 2021 and quarter ='q4' and rev_share = 0 and rev_per_hov is null
        
        update powr_viewership
        set rev_per_mov = 0
        where year = 2021 and quarter ='q4' and rev_share = 0 and rev_per_mov is null