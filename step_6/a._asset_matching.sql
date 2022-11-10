--Asset Matching
-- Be sure to update the quarter and year:
-- weighted_composite_score 
    -- function definitons are below
select p.title as powr_title, a.title as assets_title, p.channel as powr_channel, a.series as assets_series, soundex(p.title) t1_powr, soundex(a.title) t2_assets, fuzzy_score(a.title, p.title) v3, fuzzy_score(soundex(p.title), soundex(a.title)) v4 , 
((v3*1)+(v4*2))/3 weighted_composite_score,
p.id as p_id, a.ref_id as a_ref_id
from powr_viewership p
cross join assets.public.metadata  a
where quarter = 'q2' and year = 2022  and p.ref_id is null and weighted_composite_score = 1 and p.channel = a.series
LIMIT 1000 --this limit number can be changed



-- update viewership using above, update ref_id and content_provider
update powr_viewership p 
set p.ref_id = q.a_ref_id, p.content_provider = q.cp_name
from (
    select p.title as powr_title, a.title as assets_title, p.channel as powr_channel, a.series as assets_series, soundex(p.title) t1, soundex(a.title) t2, fuzzy_score(a.title, p.title) v3, fuzzy_score(soundex(p.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    p.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from powr_viewership p
    cross join assets.public.metadata  a
    where quarter = 'q2' and year = 2022 and p.ref_id is null and weighted_composite_score > .9
    LIMIT 5000 
    ) q 
where q.p_id = p.id


-- LOAD NEW TABLE - POWR_ASSETS 
copy into dictionary.public.powr_assets(uid, title, ref_id, series, content_provider, filename)
from (select t.$1, t.$2, t.$3, t.$4, t.$5, 'powr_assets_q2_22.csv' from @nosey_assets t)
pattern='.*powr_assets_q2_22.*'
file_format=nosey_viewership
ON_ERROR=SKIP_FILE FORCE=TRUE;


update powr_viewership p 
set p.ref_id = q.a_ref_id, p.content_provider = q.cp_name
from (
    select p.title as powr_title, a.title as assets_title, p.channel as powr_channel, a.series as assets_series, soundex(p.title) t1, soundex(a.title) t2, fuzzy_score(a.title, p.title) v3, fuzzy_score(soundex(p.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    p.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from powr_viewership p
    cross join dictionary.public.powr_assets  a
    where quarter = 'q2' and year = 2022 and p.ref_id is null and weighted_composite_score > .95
    LIMIT 10000 
    ) q 
where q.p_id = p.id