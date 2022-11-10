-- Looks like I only used this to calculate OAO Expense Share?
-- update -- yes??
update gam_data g
set g.oao_expense_share = q.expense_sh
from (
  select g.id as gid, oao_share * e.amount as expense_sh from gam_data g
  join monthly_expenses e on (e.year_month_day = g.year_month_day)
  where g.department_id != 5 and g.quarter = 'q2' and g.year = 2022 and e.department_id = 3
) q
where q.gid = g.id

-- total monthly impressions
 insert into monthly_impressions(tot_impressions, year_month_day, partner, year, quarter, month, viewership_type)
 select sum(TOTAL_IMPRESSIONS), year_month_day, 'gam', year, quarter, month, 'VOD' as viewership_type from gam_data
 where quarter = 'q2' and year = 2022 and advertiser != 'Tremor'
 group by year_month_day, year, quarter, month

 -- Check Monthly Impressions 
select sum(tot_impressions), year_month_day from monthly_impressions
where quarter = 'q2' and year = 2022 and quarter = 'q2' and partner in ('gam - firetv', 'gam - mobile/web')
group by year_month_day

-- update oao share
  -- Update where statement for quarter and year; replace '2'
update gam_data g
set g.oao_share = q.oao
from (
select g.id as gid, total_impressions / m.tot_impressions as oao ,g.year_month_day, ad_unit from gam_data g
join monthly_impressions m on (m.year_month_day = g.year_month_day)
where  m.partner = 'gam' and g.quarter = 'q2' and g.year = 2022
 ) q
where q.gid = g.id