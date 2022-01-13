SET SQL_MODE='ALLOW_INVALID_DATES';

DROP TABLE IF EXISTS kenyaemr_etl.temp_all_vls;

create table kenyaemr_etl.temp_all_vls
select a.person_id as Patient_id, a.obs_datetime as vl_date, a.value_numeric as vl, count(*) as row_no from
(select person_id, obs_datetime, value_numeric from openmrs.obs where concept_id=856
union
select person_id, obs_datetime, 0 from openmrs.obs where concept_id=1305) a
inner join 
(select person_id, obs_datetime, value_numeric from openmrs.obs where concept_id=856
union
select person_id, obs_datetime, 0 from openmrs.obs where concept_id=1305) b 
on a.person_id=b.person_id and a.obs_datetime <= b.obs_datetime
group by a.person_id, a.obs_datetime, a.value_numeric;

select replace(DATABASE(),'openmrs_', '') as Facility
, a.unique_patient_no
, a.patient_clinic_number 
, a.DOB
, TIMESTAMPDIFF(YEAR, a.DOB, CURDATE()) AS age
, a.Gender
, c.last_visit_date
, c.Appointment_date
, d.date_enrolled as ART_start_date
, d.hivTestDate
, (select x.vl from kenyaemr_etl.temp_all_vls x where x.patient_id=a.patient_id and x.row_no=1 limit 1) as VL1
, (select x.vl_date from kenyaemr_etl.temp_all_vls x where x.patient_id=a.patient_id and x.row_no=1 limit 1) as VL1_date
, (select x.vl from kenyaemr_etl.temp_all_vls x where x.patient_id=a.patient_id and x.row_no=2 limit 1) as VL2
, (select x.vl_date from kenyaemr_etl.temp_all_vls x where x.patient_id=a.patient_id and x.row_no=2 limit 1) as VL2_date
, (select x.vl from kenyaemr_etl.temp_all_vls x where x.patient_id=a.patient_id and x.row_no=3 limit 1) as VL3
, (select x.vl_date from kenyaemr_etl.temp_all_vls x where x.patient_id=a.patient_id and x.row_no=3 limit 1) as VL3_date
, (select x.vl from kenyaemr_etl.temp_all_vls x where x.patient_id=a.patient_id and x.row_no=4 limit 1) as VL4
, (select x.vl_date from kenyaemr_etl.temp_all_vls x where x.patient_id=a.patient_id and x.row_no=4 limit 1) as VL4_date
from kenyaemr_etl.etl_patient_demographics a
inner join
(select patient_id, max(date_enrolled) as date_enrolled from kenyaemr_etl.etl_patient_program x 
where program='MCH-Mother Services' and date_completed is null group by patient_id) b on a.patient_id=b.patient_id
inner join
(select patient_id, max(visit_date) as last_visit_date, max(next_appointment_date) as Appointment_date 
from kenyaemr_etl.etl_patient_hiv_followup group by patient_id) c on a.patient_id=c.patient_id
inner join
(select patient_id, min(date_first_enrolled_in_care) as date_enrolled, max(date_confirmed_hiv_positive) as hivTestDate
from kenyaemr_etl.etl_hiv_enrollment group by patient_id) d on a.patient_id=d.patient_id;