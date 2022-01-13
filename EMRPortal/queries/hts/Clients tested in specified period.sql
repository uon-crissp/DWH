select replace(database(), 'openmrs_', '') as Facility 
, sum(1) as Tested
, sum(case when a.final_test_result='positive' then 1 else 0 end) as positive
, sum(case when b.patient_id is not null then 1 else 0 end) as linked
from tools_hts_test a 
left join tools_hts_referral_and_linkage b on a.patient_id=b.patient_id
where a.visit_date between @fromdate and @todate
