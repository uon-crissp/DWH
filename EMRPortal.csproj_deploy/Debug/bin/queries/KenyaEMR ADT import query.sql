DROP TABLE IF EXISTS temp_art_regimens;

create table temp_art_regimens
SELECT a.patient_id
, b.encounter_datetime as date_created
, f.concept_id
, e.value_coded
, case when e.value_coded=792 then 'AF3A CF3A'
	when e.value_coded=817 then 'AF1C CF2C'
	when e.value_coded=1652 then 'AF1A CF1A'
	when e.value_coded=160104 then 'AF3B CF3B'
	when e.value_coded=160124 then 'AF1B CF1B'
	when e.value_coded=162199 then 'AF4A CF2A'
	when e.value_coded=162200 then 'AS3A CS2A'
	when e.value_coded=162201 then 'AS2A CG4A'
	when e.value_coded=162559 then 'AS3B AS3B'
	when e.value_coded=162560 then 'AS4A CS3A'
	when e.value_coded=162561 then 'AS1A CS1A'
	when e.value_coded=162562 then 'AF5X CF5X'
	when e.value_coded=162563 then 'AF4B CF2B'
	when e.value_coded=162565 then 'AF2A CF4A'
	when e.value_coded=164505 then 'AF2B CF4B'
	when e.value_coded=164511 then 'AS1B AS1B'
	when e.value_coded=164512 then 'AS2C AS2C'
	when e.value_coded=164968 then 'AF1D AF1D'
	when e.value_coded=164969 then 'AF2E CF4E'
	when e.value_coded=164970 then 'AF4C CF2G'
	when e.value_coded=164971 then 'AF2C AF2C'
	when e.value_coded=164972 then 'AS6X CS4X'
	when e.value_coded=164973 then 'AS6X CS4X'
	when e.value_coded=164974 then 'AS6X CS4X'
	when e.value_coded=164975 then 'AF3C AF3C'
	when e.value_coded=164976 then 'AS6X CS4X'
	when e.value_coded=165357 then 'AS3C AS3C'
	when e.value_coded=165369 then 'AS6X CS4X'
	when e.value_coded=165370 then 'AS6X CS4X'
	when e.value_coded=165371 then 'AS6X CS4X'
	when e.value_coded=165372 then 'CF2F CF2F'
	when e.value_coded=165373 then 'AS6X CS4X'
	when e.value_coded=165374 then 'CS2D CS2D'
	when e.value_coded=165375 then 'AS6X CS4X'
	when e.value_coded=165376 then 'AS6X CS4X'
	when e.value_coded=165377 then 'AS6X CS4X'
	when e.value_coded=165378 then 'AS6X CS4X'
	when e.value_coded=165379 then 'AS6X CS4X'
    else 'AF5X CF5X'
	end as FieldValue
FROM .patient a
inner join .encounter b on a.patient_id=b.patient_id
inner join .encounter_type c on b.encounter_type = c.encounter_type_id
inner join .form d on b.form_id = d.form_id
inner join .obs e on b.encounter_id = e.encounter_id
inner join .concept f on e.concept_id = f.concept_id
inner join .concept_description h on f.concept_id = h.concept_id
inner join .concept_datatype i on f.datatype_id = i.concept_datatype_id
where d.name='Drug Regimen Editor'
and f.concept_id=1193;

alter table temp_art_regimens add pkid int auto_increment primary key;
CREATE  INDEX ix_patient_id ON temp_art_regimens(Patient_id);
CREATE  INDEX ix_date_created ON temp_art_regimens(date_created);

select coalesce(a.unique_patient_no, a.patient_clinic_number) as ccc_number
, a.given_name as first_name
, a.middle_name as other_name
, a.family_name as last_name
, DATE_FORMAT(a.dob, '%Y-%m-%d') as date_of_birth
, TIMESTAMPDIFF(YEAR, a.DOB, CURDATE()) AS age
, case when a.Gender='M' then 'Male' else 'Female' end as Gender
, (select weight from etl_patient_triage x where x.patient_id=a.patient_id and weight>0 order by date_created desc limit 1) as current_weight
, (select height from etl_patient_triage x where x.patient_id=a.patient_id and height>0 order by date_created desc limit 1) as current_height
, DATE_FORMAT(b.date_enrolled, '%Y-%m-%d') as date_enrolled
, 'outpatient' as patient_source
, case when e.patient_id is not null then 'ART'
	when f.patient_id is not null then 'PrEP'
    when g.patient_id is not null then 'PMTCT'
    when h.patient_id is not null then 'HEI'
    else '' end as service_Type
, (select case when TIMESTAMPDIFF(YEAR, a.DOB, CURDATE())>=15 then SUBSTRING(fieldvalue, 1, 4) else SUBSTRING(fieldvalue, 6, 4) end
	from temp_art_regimens x where x.patient_id=a.patient_id order by date_created limit 1) as Start_regimen
, (select DATE_FORMAT(date_created, '%Y-%m-%d') from temp_art_regimens x where x.patient_id=a.patient_id order by date_created limit 1) as Start_regimen_date
, case when i.discontinuation_date > c.last_visit_date then i.discontinuation_reason
	else 'active' end as current_status
, (select case when TIMESTAMPDIFF(YEAR, a.DOB, CURDATE())>=15 then SUBSTRING(fieldvalue, 1, 4) else SUBSTRING(fieldvalue, 6, 4) end
	from temp_art_regimens x where x.patient_id=a.patient_id order by date_created desc limit 1) as current_regimen
, DATE_FORMAT(c.last_visit_date, '%Y-%m-%d') as last_visit_date
, DATE_FORMAT(c.Appointment_date, '%Y-%m-%d') as nextappointment
, TIMESTAMPDIFF(day, last_visit_date, c.Appointment_date) as days_to_nextappointment
, DATE_FORMAT(c.Appointment_date, '%Y-%m-%d') as clinicalappointment
, (select weight from etl_patient_triage x where x.patient_id=a.patient_id and weight>0 order by date_created limit 1) as start_weight
, (select height from etl_patient_triage x where x.patient_id=a.patient_id and height>0 order by date_created limit 1) as start_height
, DATE_FORMAT(d.hivTestDate, '%Y-%m-%d') as hivTestDate
, '' as transfer_from
, '' as prophylaxis
, '' isoniazid_start_date	
, '' isoniazid_end_date	
, '' rifap_isoniazid_start_date	
, '' rifap_isoniazid_end_date	
, '' differentiated_care_status
from etl_patient_demographics a
inner join
(select patient_id, min(date_enrolled) as date_enrolled from etl_patient_program x 
group by patient_id) b on a.patient_id=b.patient_id
left join
(select patient_id, max(visit_date) as last_visit_date, max(next_appointment_date) as Appointment_date 
from etl_patient_hiv_followup group by patient_id) c on a.patient_id=c.patient_id
left join
(select patient_id, min(date_first_enrolled_in_care) as date_enrolled, max(date_confirmed_hiv_positive) as hivTestDate
from etl_hiv_enrollment group by patient_id) d on a.patient_id=d.patient_id
left join
(select patient_id, min(date_enrolled) as date_enrolled from etl_patient_program x 
where x.program='hiv' group by patient_id) e on a.patient_id = e.patient_id
left join
(select patient_id, min(date_enrolled) as date_enrolled from etl_patient_program x 
where x.program='prep' group by patient_id) f on a.patient_id = f.patient_id
left join
(select patient_id, min(date_enrolled) as date_enrolled from etl_patient_program x 
where x.program='MCH-Mother Services' group by patient_id) g on a.patient_id = g.patient_id
left join
(select patient_id, min(date_enrolled) as date_enrolled from etl_patient_program x 
where x.program='MCH-Child Services' group by patient_id) h on a.patient_id = h.patient_id
left join
(select patient_id, max(visit_date) as discontinuation_date, 
case when max(discontinuation_reason) like '%transfer%' then 'Transfer out'
	when max(discontinuation_reason) like '%died%' then 'Deceased'
    when max(discontinuation_reason) like '%lost%' then 'Lost to follow-up'
    else 'Lost to follow-up' end as discontinuation_reason
from tools_patient_program_discontinuation where program_name='HIV' group by patient_id) i on a.patient_id=i.patient_id
