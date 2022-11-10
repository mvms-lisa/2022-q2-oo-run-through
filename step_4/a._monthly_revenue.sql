-- The first big goal to hit with revenue data is to break it out monthly and by department
-- Some of the revenue is already broken out this way coincidentally, for example: 
    -- 47 Samurai is only in the Roku department, and is broken out monthly, so there is no further breakout needed 
-- Other revenue payments are not broken out this way and need to be broken out by running queries, for ex:
    -- Roku Reps is paid in a quarterly sum, but is also only on Roku, so no need to break out by department
    -- the monthly revenue is calculated by the gam_impression share  

-- Reminder: Be sure to update the quarter and year in each statement's where clause

-- spotx revenue (Updated 8/23/22 - now using the final_net_revenue)
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title)
select sum(final_net_revenue) as revenue, year_month_day, department_id, 'spotx', year, quarter, month, channel_name as description, 'SpotX' as title from spotx
where department_id is not null and channel_name not like '%Tegna%' and year = 202X and quarter = 'qX'
group by year_month_day, channel_name, department_id, year, quarter, month

-- pubmatic revenue 
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, quarter, year, month, description, title)
select sum(pub_revenue), year_month_day, s.department_id, 'pubmatic', quarter, year, month, channel_name as description, 'Pubmatic' as title from spotx s
where pub_share is not null and year = 202X and quarter = 'qX'
group by YEAR_MONTH_DAY, s.department_id, quarter, year, month, channel_name


--adx is summed on record level
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, quarter, year, month, description, title)
select sum(ad_exchange_revenue),YEAR_MONTH_DAY, department_id, 'adx', quarter, year, month, ad_unit as description, 'AdX' as title from gam_data 
where advertiser = 'AdX' and year = 202X and quarter = 'qX'
group by YEAR_MONTH_DAY, department_id, quarter, year, month, ad_unit


-- amazon publisher services
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select revenue, year_month_day, 2, 'amazon publisher services', year, quarter, month, description, title, type from revenue 
where pay_partner like '%amazon%' and year = 202X and quarter = 'qX'


-- 47 samurai
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select amount, year_month_day, 5, '47 samurai', year, quarter, month, description, title, type from revenue 
where pay_partner like '%47%' and year = 202X and quarter = 'qX'


-- glewedTv
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select amount, year_month_day, 5, 'glewedtv', year, quarter, month, description, title, type from revenue
where pay_partner = 'glewedtv' and year = 202X and quarter = 'qX'

-- 9MediaOnline
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select sum(amount), year_month_day, department_id, pay_partner, year, quarter, month, description, title, type from revenue
where pay_partner = '9mediaonline' and year = 2022 and quarter = 'q2'
group by year_month_day, year, quarter, month, department_id, pay_partner, description, title, type
            
--SpringServe
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select sum(amount), year_month_day, department_id, pay_partner, year, quarter, month, description, title, type from revenue
where pay_partner = 'springserve' and year = 2022 and quarter = 'q2'
group by year_month_day, year, quarter, month, department_id, pay_partner, description, title, type

-- Magnite
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select amount, year_month_day, 5, 'magnite', year, quarter, month, description, title, type from revenue 
where pay_partner = 'magnite' and year = 2022 and quarter = 'q2'


-- video bridge
    -- roku
    insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
    select amount, year_month_day, 5, 'videobridge', year, quarter, month, description, title, type  from revenue
    where pay_partner like '%videobridge - roku%' and year = 202X and quarter = 'qX'

    -- firetv
    insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
    select amount, year_month_day, 2, 'videobridge', year, quarter, month, description, title, type from revenue
    where pay_partner like '%videobridge - firetv%' and year = 202X and quarter = 'qX'


  -- verizon
    -- roku (Updated 9/8/22)
    insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, month, quarter, description, type, title)
    select sum(verizon_revenue), year_month_day, v.department_id, 'verizon - roku', year, month, quarter, marketplace, 'Roku Revenue' as type, 'Verizon Media' as title  from verizon v
    join dictionary.public.departments nd on (nd.id = v.department_id)
    where year = 202X and quarter = 'qX' and v.department_id = 5
    group by YEAR_MONTH_DAY, v.department_id, year, month, quarter, marketplace


    -- firetv (Updated 9/8/22)
    insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, month, quarter, description, type, title)
    select sum(verizon_revenue), year_month_day, v.department_id, 'verizon - firetv', year, month, quarter, marketplace, 'FireTV Revenue' as type, 'Verizon Media' as title from verizon v
    join dictionary.public.departments nd on (nd.id = v.department_id)
    where year = 202X and quarter = 'qX' and v.department_id != 5
    group by YEAR_MONTH_DAY, v.department_id, year, month, quarter, marketplace



-- Roku Reps
-- Since roku reps pays in a quarterly sum, we need to calculate a share to breakout the monthly revenue.
-- For this we use spotx impressions
        -- get total impressions for roku reps deals in spotx
        select sum(impressions) from spotx 
        where DEAL_NAME like '%Reps%' and year = 202X and quarter = 'qX'


        -- use impressions of deals with roku reps to get share to break out revenue into months
        select (sum(s.impressions) / PUT_TOTAL_IMPRESSIONS_FROM_ABOVE_HERE), s.year_month_day from spotx s
        where DEAL_NAME like '%Reps%' and year = 202X and quarter = 'qX'
        group by s.year_month_day 


        -- get revenue breakout by month
        with 
        monthly as
        (
                select (sum(s.impressions) / PUT_TOTAL_IMPRESSIONS_FROM_ABOVE_HERE) as share, s.year_month_day as ymd, 'roku reps' from spotx s
                where DEAL_NAME like '%Reps%' and year = 202X and quarter = 'qX'
                group by s.year_month_day
            ) 
        select amount * monthly.share, monthly.ymd from revenue r, monthly where pay_partner = 'roku reps' and year = 202X and quarter = 'qX'

        -- manually update the values in the insert statement and get each months revenue into monthly_revenue table
        insert into monthly_revenue(tot_revenue, year_month_day, partner, department_id, year, quarter, month, description, title)
        VALUES (MANUALLY_PUT_REV_HERE, MANUALLY_PUT_YEAR_MONTH_DAY_HERE, 'roku reps', 5, 202X, 'qX', INSERT_MONTH, 'Roku CTV App Revenue', 'Roku Reps')