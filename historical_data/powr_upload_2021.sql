--powr_viewership q1 & q2 upload
    copy into powr_viewership(
    uid, 
    title, 
    type, 
    channel, 
    views, 
    watch_time_seconds, 
    average_watch_time_seconds,
    tot_hov,
    platform, 
    geo,
    ref_id,
    content_provider,
    series,
    dept_share,
    year_month_day,
    rev_share,
    quarter,
    year,
    filename
    )   
    from (select t.$1, t.$2, t.$3, t.$4, to_number(REPLACE(t.$5, ','), 12, 2), to_decimal(REPLACE(t.$6,  ','), 12, 2), to_number(REPLACE(REPLACE(t.$7, '-', ''), ','), 16, 6), to_number(REPLACE(t.$8, ','), 20,5), t.$9, t.$10, t.$11, t.$12, t.$13, to_number(REPLACE(t.$14, '%'),10,8), t.$15, t.$16, 'q2', 2021,  'powr_historical_q2_21_11032022_fix.csv'
    from @oo_viewership t) pattern='.*powr_historical_q2_21_11032022_fix.*' file_format = nosey_viewership 
    ON_ERROR=SKIP_FILE FORCE=TRUE;