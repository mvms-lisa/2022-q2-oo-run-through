-- Notes: POWR_SHARE uses grouped_viewership while dept_share uses monthly_viewership

insert into grouped_viewership (tot_viewership, year_month_day)
select sum(tot_viewership), year_month_day from monthly_viewership
where year = 2022 and quarter = 'q2'
group by year_month_day

update grouped_viewership
set year = 2022, quarter = 'q2', partner = 'powr', viewership_type = 'VOD', month = 6
where year_month_day = 20220601

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