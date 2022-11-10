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