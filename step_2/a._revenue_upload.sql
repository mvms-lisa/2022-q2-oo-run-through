-- This file only contains the manual revenue inserts

insert into revenue(year_month_day, amount, pay_partner, title, description, impressions, department_id, quarter, year, filename)
select year_month_day, sum(gross_revenue) as revenue, 'spotx' as pay_partner, 'SpotX' as title, channel_name as description, sum(impressions) as impressions, department_id, quarter, year, 'Manual Insert' as filename
from spotx where year = 2022 and quarter = 'q2' and channel_name not like '%Tegna%'
group by channel_name, year_month_day, quarter, year, department_id
order by channel_name

--AdX
insert into revenue(year_month_day, amount, pay_partner, title, description, impressions, department_id, quarter, year, filename)
select year_month_day, sum(ad_exchange_revenue) as revenue, 'adx' as pay_partner, advertiser as title, ad_unit as description, sum(total_impressions) as impressions, department_id, quarter, year, 'Manual Insert' as filename
from gam_data where year = 2022 and quarter = 'q2' and advertiser = 'AdX'
group by ad_unit, year_month_day, quarter, year, department_id, advertiser
order by ad_unit

--9 Media Online
insert into revenue(year_month_day, amount, pay_partner, title, description, impressions, department_id, quarter, year, filename)
select year_month_day, sum(gross_revenue) as revenue, '9mediaonline' as pay_partner, '9MediaOnline' as title, channel_name as description, sum(impressions) as impressions, department_id, quarter, year, 'Manual Insert' as filename
from spotx where year = 2022 and quarter = 'q2' and deal_name like '%9 Media%'
group by channel_name, year_month_day, quarter, year, department_id
order by channel_name

--manual insert SpotX Seat Fee into Expenses table
insert into expenses(amount, type, year, quarter, pay_partner, filename, title, description, label, viewership_type)
values (-2500, 'seat fee', 2022, 'q1',	'spotx', 'manual', 'SpotX',	'SpotX Seat Fee', 'Expense', 'VOD')


--Expenses insert
-- COPY INTO STATEMENT:
copy into expenses(year_month_day, month, amount, pay_partner, type, description, department, department_id, quarter, year, label, filename)
from (select t.$1, t.$2, to_number(REPLACE(REPLACE(t.$3, '$', ''), ','), 12, 2), t.$4, t.$5, t.$6, t.$7, t.$8, t.$9, t.$10, t.$11, 'expenses_q2_2022.csv'
from @oo_expenses t) pattern='.*expenses_q2_2022.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE FORCE=TRUE; 


--this is a fix - not sure if we will need this
copy into expenses(amount, type, year_month_day, year, quarter, pay_partner, filename, department, title, description, month, label, department_id, viewership_type)
from (select to_number(REPLACE(REPLACE(t.$1, '$', ''), ','), 12, 2), t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8, t.$9, t.$10, t.$11, t.$12, t.$13, t.$14
from @oo_expenses t) pattern='.*expenses_q1_22_fix.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE FORCE=TRUE; 



--SpringServe manual insert into Revenue
insert into revenue(year_month_day, amount, pay_partner, title, description, department_id, month, quarter, year, filename, viewership_type, label)
VALUES(20220401, 3089.08, 'springserve', 'SpringServe', 'Roku CTV App Revenue', 5, 4, 'q2', 2022, 'Manual Insert', 'VOD', 'Revenue'),
(20220501, 3106.35, 'springserve', 'SpringServe', 'Roku CTV App Revenue', 5, 5, 'q2', 2022, 'Manual Insert','VOD', 'Revenue'),
(20220601, 5069.72, 'springserve', 'SpringServe', 'Roku CTV App Revenue', 5, 6, 'q2', 2022, 'Manual Insert', 'VOD', 'Revenue')

-- INSERT into revenue (MAGNITE)
insert into revenue(impressions, amount, cpm, month, quarter, year, filename, pay_partner, year_month_day, department, title, type, description, label, viewership_type )
values
(1990, 30.25, 21.71, 4, 'q2', 2022, 'Manual Insert', 'magnite', 20220401, 'Roku', 'Magnite', 'Roku Revenue', 'Invite Only Auction - (Net)', 'Revenue', 'VOD'),
(5519, 54.10, 14.00, 4, 'q2', 2022, 'Manual Insert', 'magnite', 20220401, 'Roku', 'Magnite', 'Roku Revenue', 'Marketplace - (Net)', 'Revenue', 'VOD'),
(299, 2.92, 13.95, 4, 'q2', 2022, 'Manual Insert', 'magnite', 20220401, 'Roku', 'Magnite', 'Roku Revenue', 'Open Auction - (Net)', 'Revenue', 'VOD'),
(9, 0.15, 20.00, 4, 'q2', 2022, 'Manual Insert', 'magnite', 20220401, 'Roku', 'Magnite', 'Roku Revenue', 'Unreserved Fixed Rate Deal - (Net)', 'Revenue', 'VOD'),
(4476, 68.12, 21.74, 5, 'q2', 2022, 'Manual Insert', 'magnite', 20220501, 'Roku', 'Magnite', 'Roku Revenue', 'Invite Only Auction - (Net)', 'Revenue', 'VOD'),
(7460, 68.40, 13.10, 5, 'q2', 2022, 'Manual Insert', 'magnite', 20220501, 'Roku', 'Magnite', 'Roku Revenue', 'Marketplace - (Net)', 'Revenue', 'VOD'),
(853, 8.34, 13.96, 5, 'q2', 2022, 'Manual Insert', 'magnite', 20220501, 'Roku', 'Magnite', 'Roku Revenue', 'Open Auction - (Net)', 'Revenue', 'VOD'),
(27, 0.46, 20.00, 5, 'q2', 2022, 'Manual Insert', 'magnite', 20220501, 'Roku', 'Magnite', 'Roku Revenue', 'Unreserved Fixed Rate Deal - (Net)', 'Revenue', 'VOD'),
(1990, 30.25, 21.71, 6, 'q2', 2022, 'Manual Insert', 'magnite', 20220601, 'Roku', 'Magnite', 'Roku Revenue', 'Invite Only Auction - (Net)', 'Revenue', 'VOD'),
(5519, 54.10, 14.00, 6, 'q2', 2022, 'Manual Insert', 'magnite', 20220601, 'Roku', 'Magnite', 'Roku Revenue', 'Marketplace - (Net)', 'Revenue', 'VOD'),
(299, 2.92, 13.95, 6, 'q2', 2022, 'Manual Insert', 'magnite', 20220601, 'Roku', 'Magnite', 'Roku Revenue', 'Open Auction - (Net)', 'Revenue', 'VOD'),
(9, 0.15, 20.00, 6, 'q2', 2022, 'Manual Insert', 'magnite', 20220601, 'Roku', 'Magnite', 'Roku Revenue', 'Unreserved Fixed Rate Deal - (Net)', 'Revenue', 'VOD')