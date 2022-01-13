DROP TABLE IF EXISTS kenyaemr_etl.temp_all_vls;
DROP TABLE IF EXISTS kenyaemr_etl.temp_all_cd4;
DROP TABLE IF EXISTS kenyaemr_etl.temp_art_regimens;

create table temp_all_vls
select a.person_id as Patient_id, cast(a.obs_datetime as date) as vl_date, a.value_numeric as vl, count(*) as row_no 
, (select case order_reason when 843 then 'Confirmation of treatment failure (repeat VL)' 
when 1434 then 'Pregnancy' 
when 162080 then 'Baseline VL (for infants diagnosed through EID)'
when 1259 then 'Single Drug Substitution' 
when 159882 then 'Breastfeeding' 
when 163523 then 'Clinical failure' 
when 161236 then 'Routine' end as justification
from orders x where x.encounter_id = a.encounter_id limit 1) as justification
from
(select person_id, encounter_id, obs_datetime, value_numeric from obs where concept_id=856
union
select person_id, encounter_id, obs_datetime, 0 from obs where concept_id=1305) a
inner join 
(select person_id, encounter_id, obs_datetime, value_numeric from obs where concept_id=856
union
select person_id, encounter_id, obs_datetime, 0 from obs where concept_id=1305) b 
on a.person_id=b.person_id and a.obs_datetime <= b.obs_datetime
group by a.person_id, a.encounter_id, a.obs_datetime, a.value_numeric;

alter table kenyaemr_etl.temp_all_vls add pkid int auto_increment primary key;
CREATE  INDEX ix_patient_id ON kenyaemr_etl.temp_all_vls(Patient_id);
CREATE  INDEX ix_row_no ON kenyaemr_etl.temp_all_vls(row_no);

create table kenyaemr_etl.temp_all_cd4
select a.person_id as Patient_id, a.obs_datetime as cd4_date, a.value_numeric as cd4_result, count(*) as row_no 
from
(select person_id, obs_datetime, value_numeric from openmrs.obs where concept_id=5497) a
inner join 
(select person_id, obs_datetime, value_numeric from openmrs.obs where concept_id=5497) b
on a.person_id=b.person_id and a.obs_datetime >= b.obs_datetime
group by a.person_id, a.obs_datetime, a.value_numeric;

alter table kenyaemr_etl.temp_all_cd4 add pkid_cd4 int auto_increment primary key;
CREATE  INDEX ix_patient_id_cd4 ON kenyaemr_etl.temp_all_cd4(Patient_id);
CREATE  INDEX ix_row_no_cd4 ON kenyaemr_etl.temp_all_cd4(row_no);

create table kenyaemr_etl.temp_art_regimens
SELECT a.patient_id
, b.encounter_datetime as date_created
, f.concept_id
, e.value_coded
, case when e.value_coded=792 then 'D4T/3TC/NVP'
	when e.value_coded=817 then 'AZT/3TC/ABC'
	when e.value_coded=1652 then 'AZT/3TC/NVP'
	when e.value_coded=160104 then 'D4T/3TC/EFV'
	when e.value_coded=160124 then 'AZT/3TC/EFV'
	when e.value_coded=162199 then 'ABC/3TC/NVP'
	when e.value_coded=162200 then 'ABC/3TC/LPV/r'
	when e.value_coded=162201 then 'TDF/3TC/LPV/r'
	when e.value_coded=162559 then 'ABC/DDI/LPV/r'
	when e.value_coded=162560 then 'D4T/3TC/LPV/r'
	when e.value_coded=162561 then 'AZT/3TC/LPV/r'
	when e.value_coded=162562 then 'TDF/ABC/LPV/r'
	when e.value_coded=162563 then 'ABC/3TC/EFV'
	when e.value_coded=162565 then 'TDF/3TC/NVP'
	when e.value_coded=164505 then 'TDF/3TC/EFV'
	when e.value_coded=164511 then 'AZT/3TC/ATV/r'
	when e.value_coded=164512 then 'TDF/3TC/ATV/r'
	when e.value_coded=164968 then 'AZT/3TC/DTG'
	when e.value_coded=164969 then 'TDF/3TC/DTG'
	when e.value_coded=164970 then 'ABC/3TC/DTG'
	when e.value_coded=164971 then 'TDF/3TC/AZT'
	when e.value_coded=164972 then 'AZT/TDF/3TC/LPV/r'
	when e.value_coded=164973 then 'ETR/RAL/DRV/RTV'
	when e.value_coded=164974 then 'ETR/TDF/3TC/LPV/r'
	when e.value_coded=164975 then 'D4T/3TC/ABC'
	when e.value_coded=164976 then 'ABC/TDF/3TC/LPV/r'
	when e.value_coded=165357 then 'ABC/3TC/ATV/r'
	when e.value_coded=165369 then 'TDF/3TC/DTG/DRV/r'
	when e.value_coded=165370 then 'TDF/3TC/RAL/DRV/r'
	when e.value_coded=165371 then 'TDF/3TC/DTG/EFV/DRV/r'
	when e.value_coded=165372 then 'ABC/3TC/RAL'
	when e.value_coded=165373 then 'AZT/3TC/RAL/DRV/r'
	when e.value_coded=165374 then 'ABC/3TC/RAL/DRV/r'
	when e.value_coded=165375 then 'RAL/3TC/DRV/RTV'
	when e.value_coded=165376 then 'RAL/3TC/DRV/RTV/AZT'
	when e.value_coded=165377 then 'RAL/3TC/DRV/RTV/ABC'
	when e.value_coded=165378 then 'ETV/3TC/DRV/RTV'
	when e.value_coded=165379 then 'RAL/3TC/DRV/RTV/TDF'
	else 'OTHER'
	end as FieldValue
FROM openmrs.patient a
inner join openmrs.encounter b on a.patient_id=b.patient_id
inner join openmrs.encounter_type c on b.encounter_type = c.encounter_type_id
inner join openmrs.form d on b.form_id = d.form_id
inner join openmrs.obs e on b.encounter_id = e.encounter_id
inner join openmrs.concept f on e.concept_id = f.concept_id
inner join openmrs.concept_description h on f.concept_id = h.concept_id
inner join openmrs.concept_datatype i on f.datatype_id = i.concept_datatype_id
where d.name='Drug Regimen Editor'
and f.concept_id=1193;

alter table kenyaemr_etl.temp_art_regimens add pkid int auto_increment primary key;
CREATE  INDEX ix_patient_id ON kenyaemr_etl.temp_art_regimens(Patient_id);
CREATE  INDEX ix_date_created ON kenyaemr_etl.temp_art_regimens(date_created);

select * from
(
select replace(DATABASE(),'openmrs_', '') as Facility
, a.patient_id
, a.unique_patient_no
, a.patient_clinic_number
, a.DOB
, round(TIMESTAMPDIFF(month, a.DOB, @todate)/12.0, 1) AS age
, a.Gender
, j.location
, j.ward
, j.sub_location
, j.village
, a.education_level
, a.marital_status
, c.hiv_test_date
, c.date_first_enrolled_in_care
, c.Enrollment_Date
, case when f.pmtct_date_enrolled is not null then 'Yes' end as Enrolled_in_pmtct
, f.pmtct_date_enrolled
, f.pmtct_date_completed
, case when i.otz_date_enrolled is not null then 'Yes' end as Enrolled_in_otz
, i.otz_date_enrolled
, i.otz_date_completed
, case when k.ovc_date_enrolled is not null then 'Yes' end as Enrolled_in_ovc
, k.ovc_date_enrolled
, k.ovc_date_completed

, (select fieldvalue from temp_art_regimens x where x.patient_id=a.patient_id order by date_created limit 1) as Start_regimen
, (select date_created from temp_art_regimens x where x.patient_id=a.patient_id order by date_created limit 1) as Start_regimen_date
, (select fieldvalue from temp_art_regimens x where x.patient_id=a.patient_id order by date_created desc limit 1) as current_regimen
, (select date_created from temp_art_regimens x where x.patient_id=a.patient_id order by date_created desc limit 1) as current_regimen_date

, (select cd4_result from temp_all_cd4 x where x.patient_id=a.patient_id and row_no=1 limit 1) as baseline_cd4
, (select cd4_date from temp_all_cd4 x where x.patient_id=a.patient_id and row_no=1 limit 1) as baseline_cd4_date

, case when  (select vl_date from temp_all_vls x where x.patient_id=a.patient_id and row_no=1 limit 1) < l.vl_order_date then l.vl_order_date 
	else null end as Pending_VL_order_date
, case when  (select vl_date from temp_all_vls x where x.patient_id=a.patient_id and row_no=1 limit 1) < l.vl_order_date then l.justification 
	else null end as Pending_VL_justification
, (select vl from temp_all_vls x where x.patient_id=a.patient_id and row_no=1 limit 1) as VL_latest
, (select vl_date from temp_all_vls x where x.patient_id=a.patient_id and row_no=1 limit 1) as VL_latest_date
, (select justification from temp_all_vls x where x.patient_id=a.patient_id and row_no=1 limit 1) as VL_latest_justification
, (select vl from temp_all_vls x where x.patient_id=a.patient_id and row_no=2 limit 1) as VL2
, (select vl_date from temp_all_vls x where x.patient_id=a.patient_id and row_no=2 limit 1) as VL2_date
, (select vl from temp_all_vls x where x.patient_id=a.patient_id and row_no=3 limit 1) as VL3
, (select vl_date from temp_all_vls x where x.patient_id=a.patient_id and row_no=3 limit 1) as VL3_date
, (select vl from temp_all_vls x where x.patient_id=a.patient_id and row_no=4 limit 1) as VL4
, (select vl_date from temp_all_vls x where x.patient_id=a.patient_id and row_no=4 limit 1) as VL4_date

, (select arv_adherence from tools_hiv_followup x where x.patient_id=a.patient_id and length(arv_adherence)>1 order by visit_date desc limit 1) as arv_adherence
, (select resulting_tb_status from tools_tb_screening x where x.patient_id=a.patient_id order by visit_date desc limit 1) as tb_screening_result
, (select visit_date from tools_tb_screening x where x.patient_id=a.patient_id order by visit_date desc limit 1) as tb_screening_date
, (select on_anti_tb_drugs from tools_hiv_followup x where x.patient_id=a.patient_id and length(on_anti_tb_drugs)>1 order by visit_date desc limit 1) as on_anti_tb_drugs
, h.tb_date_enrolled
, h.tb_date_completed
, (select ever_on_ipt from tools_hiv_followup x where x.patient_id=a.patient_id and length(ever_on_ipt)>1 order by visit_date desc limit 1) as ever_on_ipt
, (select on_ipt from tools_hiv_followup x where x.patient_id=a.patient_id and length(on_ipt)>1 order by visit_date desc limit 1) as on_ipt
, g.ipt_date_enrolled
, g.ipt_date_completed

, b.Last_Visit_date
, b.Appointment_date
, TIMESTAMPDIFF(day, b.Last_Visit_date, b.Appointment_date) as duration_in_days
, case when TIMESTAMPDIFF(DAY, b.Appointment_date, @todate) <= 30 then 'Active' else 'Inactive' end as ART_Status
, case when TIMESTAMPDIFF(DAY, b.Appointment_date, @todate) > 0 then TIMESTAMPDIFF(DAY, b.Appointment_date, @todate) end as days_missed

, (select stability from tools_hiv_followup x where x.patient_id=a.patient_id and length(stability)>1 order by visit_date desc limit 1) as stable
, (select differentiated_care from tools_hiv_followup x where x.patient_id=a.patient_id and length(differentiated_care)>1 order by visit_date desc limit 1) as dc_model

, (select cacx_screening from tools_hiv_followup x where x.patient_id=a.patient_id and length(cacx_screening)>1 order by visit_date desc limit 1) as cacx_screening

, (select family_planning_status from tools_hiv_followup x where x.patient_id=a.patient_id and length(family_planning_status)>1 order by visit_date desc limit 1) as family_planning_status
, (select family_planning_method from tools_hiv_followup x where x.patient_id=a.patient_id and length(family_planning_status)>1 order by visit_date desc limit 1) as family_planning_method
, (select reason_not_using_family_planning from tools_hiv_followup x where x.patient_id=a.patient_id and length(family_planning_status)>1 order by visit_date desc limit 1) as reason_not_using_family_planning

, case when b.Last_Visit_date < e.Discontinuation_date then e.Discontinuation_date end as Discontinuation_date
, case when b.Last_Visit_date < e.Discontinuation_date then e.discontinuation_reason end as discontinuation_reason

from (select patient_id, min(visit_date) as Enrollment_Date, min(date_first_enrolled_in_care) as date_first_enrolled_in_care
	, max(name_of_treatment_supporter) as name_of_treatment_supporter
	, max(treatment_supporter_telephone) as treatment_supporter_telephone
	, max(date_confirmed_hiv_positive) as hiv_test_date
	from etl_hiv_enrollment group by patient_id) c
inner join 
	(select patient_id, max(visit_date) as Last_Visit_date,  
	case when max(next_appointment_date) <= max(visit_date) then null else max(next_appointment_date) end as Appointment_date
	from etl_patient_hiv_followup x group by x.patient_id) b on c.patient_id=b.patient_id
inner join
	etl_patient_demographics a on a.patient_id=c.patient_id
left join
	(select patient_id, max(visit_date) as discontinuation_date, max(discontinuation_reason) as discontinuation_reason
	from tools_patient_program_discontinuation where program_name='HIV' group by patient_id) e on a.patient_id=e.patient_id
left join 
	(select patient_id, max(date_enrolled) as pmtct_date_enrolled, max(date_completed) as pmtct_date_completed
    from etl_patient_program x 
	where program='MCH-Mother Services' and date_completed is null group by patient_id) f on a.patient_id=f.patient_id
left join
	(select patient_id, max(date_enrolled) as ipt_date_enrolled, max(date_completed) as ipt_date_completed
    from etl_patient_program x 
	where program='IPT' and date_completed is null group by patient_id) g on a.patient_id=g.patient_id
left join
	(select patient_id, max(date_enrolled) as tb_date_enrolled, max(date_completed) as tb_date_completed
    from etl_patient_program x 
	where program='tb' and date_completed is null group by patient_id) h on a.patient_id=h.patient_id
left join
	(select patient_id, max(date_enrolled) as otz_date_enrolled, max(date_completed) as otz_date_completed
    from etl_patient_program x 
	where program='otz' and date_completed is null group by patient_id) i on a.patient_id=i.patient_id
left join
	(select patient_id, max(location) as location, max(ward) as ward, max(sub_location) as sub_location, max(village) as village 
	from tools_person_address group by patient_id) j on a.patient_id=j.patient_id
left join
	(select patient_id, max(date_enrolled) as ovc_date_enrolled, max(date_completed) as ovc_date_completed
    from etl_patient_program x 
	where program='ovc' and date_completed is null group by patient_id) k on a.patient_id=k.patient_id 
left join
	(select b.patient_id, cast(max(encounter_datetime) as date) as vl_order_date 
    , case a.order_reason when 843 then 'Confirmation of treatment failure (repeat VL)' 
	when 1434 then 'Pregnancy' 
	when 162080 then 'Baseline VL (for infants diagnosed through EID)'
	when 1259 then 'Single Drug Substitution' 
	when 159882 then 'Breastfeeding' 
	when 163523 then 'Clinical failure' 
	when 161236 then 'Routine' end as justification
    from orders a
	inner join encounter b on a.encounter_id=b.encounter_id
	where a.concept_id in (856, 1305) group by b.patient_id) l on a.patient_id = l.patient_id
where c.Enrollment_Date <= @todate
) a where a.ART_Status='Active' and a.Start_regimen is not null