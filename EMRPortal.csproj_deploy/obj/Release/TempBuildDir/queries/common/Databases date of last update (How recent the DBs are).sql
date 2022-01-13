select replace(database(),'openmrs_', '') as facility
, (select CAST(date_created as date) from encounter order by encounter_id desc limit 1) as last_update