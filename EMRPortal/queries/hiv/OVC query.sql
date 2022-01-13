select replace(DATABASE(),'openmrs_', '') as Facility
, a.patient_clinic_number
, a.unique_patient_no 
, a.DOB
, TIMESTAMPDIFF(YEAR, a.DOB, CURDATE()) AS age
, a.Gender
, b.client_enrolled_cpims
, b.partner_offering_ovc
from kenyaemr_etl.etl_patient_demographics a
inner join kenyaemr_etl.etl_ovc_enrolment b on a.patient_id=b.patient_id