--REMINDER: Be sure to update the quarter and year in each select statement and/or where clause

-- check expense share
  select oao_share * e.amount as exp_share, g.year_month_day,  ad_unit, g.department_id as dep_id from gam_data g
  join expenses e on (e.year_month_day = g.year_month_day )
  where pay_partner = 'oao' and type = 'adserving' and g.quarter = 'qX' and g.year = 202X


-- doesn't make sense unless only one oao expense in expenses table 
-- update gam_data g
-- set g.oao_expense_share = q.expense_sh
-- from (
--   select g.id as gid, oao_share * e.amount as expense_sh, g.year_month_day,  ad_unit, g.department_id as dep_id from gam_data g
--   join expenses e on (e.year_month_day = g.year_month_day )
--   where pay_partner = 'oao' and type = 'adserving' and g.quarter = 'qX' and g.year = 202X
-- ) q
-- where q.gid = g.id


 
-- firetv expenses
select sum(oao_share) * e.amount as exp, g.year_month_day from gam_data g
join expenses e on (e.year_month_day = g.year_month_day and type = 'adserving')
where  g.department_id = 2 and g.quarter = 'qX' and g.year = 202X
group by g.year_month_day,  e.amount

-- non firetv expenses
select sum(oao_share)* e.amount as exp, g.year_month_day from gam_data g
join expenses e on (e.year_month_day = g.year_month_day and type = 'adserving')
where  g.department_id != 2 and g.quarter = 'qX' and g.year = 202X
group by g.year_month_day,  e.amount


-- insert firetv expenses
--- Update quarter and year in select statement and where clause
insert into monthly_expenses(
    amount, 
    year_month_day,
    department_id,
    title,
    year, 
    quarter
)
select sum(oao_share) * e.amount as exp, g.year_month_day, g.department_id, 'OAO - Adserving', 202X, 'qX'  from gam_data g
join expenses e on (e.year_month_day = g.year_month_day and type = 'adserving')
where g.department_id = 2 and g.quarter = 'qX' and g.year = 202X
group by g.year_month_day,  e.amount, g.department_id


-- insert non-firetv expenses
insert into monthly_expenses(
    amount, 
    year_month_day,
    department_id,
    title,
    year, 
    quarter
)
select sum(oao_share) * e.amount as exp, g.year_month_day, 3, 'OAO - Adserving', 202X, 'qX'  from gam_data g
join expenses e on (e.year_month_day = g.year_month_day and type = 'adserving')
where  g.department_id != 2 and g.quarter = 'qX' and g.year = 202X
group by g.year_month_day,  e.amount


-- insert non-FireTV expenses (TEMPORARY - to delete after gam_data oao_expense_share is updated)
insert into monthly_expenses(
    amount, 
    year_month_day,
    department_id,
    title,
    year, 
    quarter,
    month,
    type,
    partner,
    department
  
)
select sum(e.amount), e.year_month_day, 3, title, year, quarter, month, 'Temporary' as type, pay_partner, department  from expenses e
where  e.department_id != 5 and e.quarter = 'qX' and e.year = 202X and pay_partner = 'oao'
group by e.year_month_day, title, year, quarter, month, type, pay_partner, department

-- Update OAO Expense Share in gam_data table - must have temp mobile monthly share in monthly_expenses before this
update gam_data g
set g.oao_expense_share = q.expense_sh
from (
  select g.id as gid, oao_share * e.amount as expense_sh from gam_data g
  join monthly_expenses e on (e.year_month_day = g.year_month_day)
  where g.department_id != 5 and g.quarter = 'qX' and g.year = 202X and e.department_id = 3
) q
where q.gid = g.id

--SELECT non-FireTV Temporary Expenses
delete from monthly_expenses where year = 202X and quarter = 'qX' and department_id = 3 and partner is null

--DELETE non-FireTV Temporary Expenses
delete from monthly_expenses where year = 202X and quarter = 'qX' and department_id = 3 and partner is null


-- OAO - Roku
insert into monthly_expenses(
    amount, 
    year_month_day,
    department_id,
    title,
    year, 
    quarter,
    month, 
    description,
    type,
    partner,
    department,
    viewership_type
) select amount, year_month_day, department_id, title, year, quarter, month, description, type, pay_partner, department, viewership_type from expenses 
where department_id = 5 and pay_partner = 'oao' and year = 202X and quarter = 'qX'


-- AWS
insert into monthly_expenses (amount, year_month_day, department_id, title, year, quarter, month, description, type, partner, department, viewership_type)
select amount, year_month_day, department_id, title, year, quarter, month, description, type, pay_partner, department, 'VOD' as viewership_type from expenses
where year = 202X and quarter = 'qX' and pay_partner = 'aws'

-- POWR
insert into monthly_expenses (amount, year_month_day, department_id, title, year, quarter, month, description, type, partner, department, viewership_type)
select amount, year_month_day, department_id, title, year, quarter, month, description, type, pay_partner, department, 'VOD' as viewership_type from expenses
where year = 202X and quarter = 'qX' and pay_partner = 'powr'


-- OAO Mobile/Web
insert into monthly_expenses (amount, year_month_day, year, quarter, month, department_id, title, type, description )
select sum(oao_expense_share), year_month_day, year, quarter, month, 6 as department_id, 'OAO Adserving' as title, 'adserving' as type, 'OAO Mobile/Web Expenses' as description from gam_data
where year = 202X and quarter = 'qX' and department_id !=2 and advertiser != 'Tremor'
group by year_month_day, year, quarter, month


-- OAO FireTV
insert into monthly_expenses (amount, year_month_day, year, quarter, month, department_id, title, type, description )
select sum(oao_expense_share), year_month_day, year, quarter, month, 2 as department_id, 'OAO Adserving' as title, 'adserving' as type, 'OAO FireTV Expenses' as description from gam_data
where year = 202X and quarter = 'qX' and department_id = 2 and advertiser != 'Tremor'
group by year_month_day, year, quarter, month



-- check roku expenses
select * from expenses where type = 'roku'

-- add roku expenses to monthly_expenses
insert into monthly_expenses(
    amount, 
    year_month_day,
    department_id,
    title,
    year, 
    quarter
) select amount, year_month_day, 5, 'OAO - Adserving', 202X, 'qX' from expenses where type = 'roku'