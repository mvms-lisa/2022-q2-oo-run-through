-- pubmatic - share calc - q2 2022 - as of 10/25/22, did not fully execute. Need to re-evaluate.
    -- in order to calculate pubmatic share, we need   
        --  m =  monthly impressions 
        --  divide record level impressions by monthly impressions (m)
        --  then we can sum share by department_id
        
         
      -- monthly_impressions
        --update year and month
      select sum(impressions), year_month_day from spotx s
      where DEAL_NAME like '%Pubmatic%' and year = 2022 and quarter = 'q2'
      group by year_month_day
      
      -- insert into  monthly_impressions table
      insert into monthly_impressions(tot_impressions, year_month_day, partner, month, quarter, year)
      select sum(impressions), year_month_day, 'pubmatic', month, quarter, year from spotx s
      where DEAL_NAME like '%Pubmatic%' and year = 2022 and quarter = 'q2'
      group by year_month_day, month, quarter, year
      
       
      -- calculate the pubmatic share 
      select (impressions / tot_impressions) as pub_share, s.year_month_day from spotx s
      join monthly_impressions m on (m.year_month_day = s.year_month_day)
      where DEAL_NAME like '%Pubmatic%' and s.year = 2022 and s.quarter = 'q2'
      and m.partner = 'pubmatic'
      
      
      --update pub_share column in spotx table
      update spotx s
      set s.pub_share = q.pubshare
      from (
        select s.id as sid, (impressions / tot_impressions) as pubshare, s.year_month_day from spotx s
        join monthly_impressions m on (m.year_month_day = s.year_month_day)
        where  DEAL_NAME like '%Pubmatic%' and s.year = 2022 and s.quarter = 'q2'
        and m.partner = 'pubmatic'
      )  q
      where s.id = q.sid
      
      select * from spotx where year = 2022 and quarter = 'q2' and DEAL_NAME like '%Pubmatic%'


    -- Update pubmatic rev share
    update spotx s
    set s.pub_revenue = q.pub_rev
    from ( 
      select s.id as qid, pub_share, s.impressions, pub_share * r.amount as pub_rev,  s.year_month_day, s.channel_name from spotx s
      join revenue r on (r.year_month_day = s.year_month_day)
      where DEAL_NAME like '%Pubmatic%' and s.year = 2022 and s.quarter = 'q2'
      and r.pay_partner = 'pubmatic'
    ) q
    where q.qid = s.id