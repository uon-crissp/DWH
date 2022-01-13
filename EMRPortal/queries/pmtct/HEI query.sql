select replace(DATABASE(),'openmrs_', '') as Facility
, a.patient_clinic_number
, a.DOB
, TIMESTAMPDIFF(YEAR, a.DOB, CURDATE()) AS age
, a.Gender
, date_enrolled as Date_Enrolled_MCH
, c.last_visit_date
, c.Appointment_date
from kenyaemr_etl.etl_patient_demographics a
inner join
(select patient_id, max(date_enrolled) as date_enrolled from kenyaemr_etl.etl_patient_program x 
where program='MCH-Child Services' and date_completed is null group by patient_id) b on a.patient_id=b.patient_id
inner join
(select patient_id, max(visit_date) as last_visit_date, max(next_appointment_date) as Appointment_date
from kenyaemr_etl.etl_hei_follow_up_visit group by patient_id) c on a.patient_id=c.patient_id