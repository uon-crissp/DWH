select * from
(
select replace(DATABASE(),'openmrs_', '') as Facility
, coalesce(a.unique_patient_no, a.patient_clinic_number) as ccc_number
, a.dob as date_of_birth
, TIMESTAMPDIFF(YEAR, a.DOB, @todate) AS age
, case when a.Gender='M' then 'Male' else 'Female' end as Gender
, case when TIMESTAMPDIFF(DAY, c.Appointment_date, @todate) <= 30 then 'Active' else 'Inactive' end as ART_Status
, c.last_visit_date as last_visit_date
, c.Appointment_date as nextappointment
, (select pwp_disclosure from tools_hiv_followup x where x.patient_id=a.patient_id and length(pwp_disclosure)>1 order by visit_date desc limit 1) as pwp_disclosure
, (select pwp_partner_tested from tools_hiv_followup x where x.patient_id=a.patient_id and length(pwp_partner_tested)>1 order by visit_date desc limit 1) as pwp_partner_tested
, (select condom_provided from tools_hiv_followup x where x.patient_id=a.patient_id and length(condom_provided)>1 order by visit_date desc limit 1) as condom_provided
, (select substance_abuse_screening from tools_hiv_followup x where x.patient_id=a.patient_id and length(substance_abuse_screening)>1 order by visit_date desc limit 1) as substance_abuse_screening
, (select screened_for_sti from tools_hiv_followup x where x.patient_id=a.patient_id and length(screened_for_sti)>1 order by visit_date desc limit 1) as screened_for_sti
, (select cacx_screening from tools_hiv_followup x where x.patient_id=a.patient_id and length(cacx_screening)>1 order by visit_date desc limit 1) as cacx_screening
, (select sti_partner_notification from tools_hiv_followup x where x.patient_id=a.patient_id and length(sti_partner_notification)>1 order by visit_date desc limit 1) as sti_partner_notification
, (select at_risk_population from tools_hiv_followup x where x.patient_id=a.patient_id and length(at_risk_population)>1 order by visit_date desc limit 1) as at_risk_population
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
) a where a.ART_Status='Active'