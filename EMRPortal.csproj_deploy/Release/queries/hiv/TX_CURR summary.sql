select replace(database(),'openmrs_', '') as facility
, (select count(*) from etl_current_in_care x where x.started_on_drugs is not null and enroll_date between @fromdate and @todate) as TX_NEW
, (select count(*) from etl_current_in_care x where x.started_on_drugs is not null) as TX_CURR