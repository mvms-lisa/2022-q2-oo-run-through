-- the first part of the o and o process is to upload the three main data sets: 
    -- powr_viewership
    -- gam_data
    -- spotx_data

        -- powr_viewership is the only pure viewership data that is in the o and o database. it is sent directly to our team
        -- gam_data is an ad partner
        -- spotx_data is an adserving partner which helps place ads on different platforms


-- upload procedures

-- powr_viewership
    -- fields to update: 
        --  filename, year, quarter, pattern (replace where there is an 'X')

    copy into powr_viewership(
    uid, 
    title, 
    type, 
    channel, 
    views, 
    watch_time_seconds, 
    average_watch_time_seconds, 
    platform, 
    geo, 
    year_month_day,
    quarter,
    year,
    filename
    )   
    from (select t.$1, t.$2, t.$3, t.$4, to_number(REPLACE(t.$5, ','), 12, 2), to_decimal(REPLACE(t.$6,  ','), 12, 2), to_number(REPLACE(REPLACE(t.$7, '-', ''), ','), 16, 6), t.$8, t.$9, t.$10, 'q2', 2022,  'powr_viewership_q2_2022.csv'
    from @oo_viewership t) pattern='.*powr_viewership_q2_2022.*' file_format = nosey_viewership 
    ON_ERROR=SKIP_FILE FORCE=TRUE;


-- gam_data
    -- fields to update: 
        --  filename, year, quarter, pattern (replace where there is an 'X')

        copy into gam_data (
        advertiser,
        ad_unit,
        month_year,
        advertiser_id,
        ad_unit_id,
        total_code_served,
        total_impressions,
        ad_exchange_revenue,
        quarter, 
        year, 
        filename
        )
        from (select t.$1, t.$2, t.$3, t.$4, t.$5, to_number(REPLACE(t.$6,  ','), 15, 0), to_number(REPLACE(t.$7,  ','), 15, 0), to_number(REPLACE(t.$8,  ','), 15, 2), 'q2', 2022,  'gam_q2_2022.csv'
        from @oo_ad_data t) pattern='.*gam_q2_2022.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;




-- spotx
    -- fields to update: 
        --  filename, year, quarter, pattern (replace where there is an 'X')
        
        copy into spotx (
        timestamp,
        channel_name,
        deal_demand_source,
        deal_name,
        placements,
        gross_revenue,
        impressions,
        quarter,
        year,
        filename
        )
        from (select t.$1, t.$2, t.$3, t.$4, to_number(REPLACE(t.$5, ','), 10, 0), to_number(REPLACE(t.$6, ','), 10,5), to_number(REPLACE(t.$7, ','), 12, 0),  'q2', 2022,  'spotx_revenue_q2_2022.csv'
        from @oo_revenue t) pattern='.*spotx_revenue_q2_2022.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;
        
 
 -- verizon
    -- fields to update: 
        -- quarter, pattern, year, filename, and replace where there is an 'X'
    
        copy into verizon(
        date,
        marketplace,
        app_bundle,
        ad_opportunity,
        ad_impressions,
        ad_revenue,
        fill_rate,
        ecpm,     
        year_month_day,
        quarter,
        month,
        filename
        )   
        from (select t.$1, t.$2, t.$3, to_number(REPLACE(t.$4, ','), 12, 0), to_number(REPLACE(t.$5, ','), 12, 0), t.$6, to_decimal(REPLACE(t.$7, '%'), 10, 5), t.$8, t.$9, t.$10, t.$11, 'verizon_q2_2022.csv'
        from @oo_viewership t) pattern='.*verizon_q2_2022.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;
        
        
        
-------DEPARTMENT ID UPDATE ---------
-- in order to group our data properly, we need to be able to determine which 'department' a record belongs to
-- departments in this case refer to platforms: roku, firetv, ios, etc.  

-- step 2 is to update the department_id's of the records that were just uploaded 


-- powr_viewership
update powr_viewership p
    -- set device id column to val in query, set dept id to val in query
    set p.device_id = q.devid, p.department_id = q.depid
    from 
    (
        -- query to match viewership record to the device
        select p.id as qid, d.device_id as devid, d.department_id as depid from powr_viewership p
        join dictionary.public.devices d on (d.entry = p.platform)
        where year = 2022 and quarter = 'q2'
    ) q
    -- update where the record id matches the record id in query
    where p.id = q.qid

    -- Delete undefined platforms and titles = none 
delete from powr_viewership where year = 2022 and title = 'none'

delete from powr_viewership where year = 2022 and quarter = 'q2' and (type = 'none' or type = 'trailer' or type = 'extra')

select * from powr_viewership where year = 2022 and quarter = 'q2'

update powr_viewership
set month = 6
where year_month_day = 20220601

-- spotx 
    update spotx s
    -- set channel id column to val in query, set dept id to val in query
    set s.channel_id = q.chid, s.department_id = q.depid
    from
    (
        -- query to match viewership record to the channel
        select s.id as qid,  c.id as chid, c.department_id as depid from spotx s
        join dictionary.public.spotx_channels c on (c.name = s.channel_name)
        where year = 2022 and quarter = 'q2' 
    ) q
    -- update where the record id matches the record id in query
    where s.id = q.qid
    
    
        update spotx s
    -- set channel id column to val in query, set dept id to val in query
    set s.device_id = q.did, s.department_id = q.depid
    from
    (
        -- query to match viewership record to the channel
        select s.id as qid,  d.device_id as did, d.department_id as depid from spotx s
        join dictionary.public.devices d on (d.entry = s.channel_name)
        where year = 2022 and quarter = 'q2' 
    ) q
    -- update where the record id matches the record id in query
    where s.id = q.qid


select * from spotx where quarter = 'q2' and year = 2022 

select * from dictionary.public.spotx_channels
select * from dictionary.public.channels
select * from dictionary.public.departments
select * from dictionary.public.devices

-- gam_data 
    update gam_data g
    -- set device id column to val in query, set dept id to val in query
    set g.device_id = q.devid, g.department_id = q.depid
    from 
    (
        -- query to match viewership record to the device
        select g.id as qid, d.id as devid, d.department_id as depid from gam_data g
        join dictionary.public.devices d on (d.entry = g.ad_unit)
        where year = 2022 and quarter = 'q2'
    ) q
    -- update where the record id matches the record id in query
    where g.id = q.qid


-- verizon 
    update verizon v
    -- set device id column to val in query, set dept id to val in query
    set v.device_id = q.devid, v.department_id = q.depid
    from 
    (
        -- query to match viewership record to the device
        select v.id as qid, d.device_id as devid, d.department_id as depid, d. from verizon v
        join dictionary.public.devices d on (d.entry = v.marketplace)
        where year = 2022 and quarter = 'q2'
    ) q
    -- update where the record id matches the record id in query
    where v.id = q.qid




update gam_data
set device_name = 'iOS'
where year = 2022 and quarter = 'q2' and department_id = 1

select channel_name, deal_demand_source, deal_name, month, sum(gross_revenue), sum(impressions) from spotx where year = 2022 and quarter = 'q2' and deal_name like '%VideoBridge%'
group by channel_name and month


select year_month_day, sum(gross_revenue) as revenue, 'Video Bridge' as pay_partner, 'VideoBridge' as title, channel_name as description, sum(impressions) as impressions, department_id, quarter, year, 'Manual Insert' as filename
from spotx where year = 2022 and quarter = 'q2' and deal_name like '%VideoBridge%'
group by channel_name, year_month_day, quarter, year, department_id
order by channel_name


copy into revenue(year_month_day, amount, pay_partner, title, type, description, impressions, department, department_id, cpm, quarter, year, filename)
from (select t.$1, to_number(REPLACE(REPLACE(t.$2, '$', ''), ','), 12, 2), t.$3, t.$4, t.$5, t.$6,  to_number(REPLACE(t.$7, ','),12, 0), t.$8, t.$9, to_number(REPLACE(t.$10, ','),6, 2), t.$11, t.$12,  'revenue_q2_2022'
from @oo_revenue t) pattern='.*revenue_q2_2022.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE FORCE=TRUE;



    -- update share on records
    update powr_viewership p
    set p.share = q.powr_share
    from
    (
    select p.id as id, ref_id, WATCH_TIME_SECONDS / mv.TOT_VIEWERSHIP as powr_share, p.year_month_day from powr_viewership p
    join monthly_viewership mv on (mv.year_month_day = p.year_month_day and mv.department_id  = p.department_id)
    join dictionary.public.devices d on (d.department_id = p.department_id and d.entry = p.platform)
    where mv.usage = 'powr viewership share' and p.year = 2022 and p.quarter = 'q2'
    ) q
    where p.id = q.id
    
    select * from dictionary.public.devices