select * from
(
	select replace(DATABASE(),'openmrs_', '') as Facility
	, a.patient_id
    , a.unique_patient_no
	, coalesce(f.ServiceArea, 'ART') as Program
	, TIMESTAMPDIFF(YEAR, a.DOB, @todate) AS age
	, a.Gender
	, '' as Residence
	, c.Enrollment_Date
    , b.Last_Visit_date
	, b.Appointment_date
	, TIMESTAMPDIFF(DAY, b.Appointment_date, @todate) as days_missed
	, d.tracing_type
	, d.tracing_outcome
	, d.attempt_number
    , e.visit_date as Discontinuation_date
	from kenyaemr_etl.etl_patient_demographics a
	inner join 
	(select patient_id, max(visit_date) as Last_Visit_date,  
    case when max(next_appointment_date) <= max(visit_date) then null else max(next_appointment_date) end as Appointment_date
	from kenyaemr_etl.etl_patient_hiv_followup x group by x.patient_id) b on a.patient_id=b.patient_id
	left join
	(select patient_id, min(visit_date) as Enrollment_Date, min(date_first_enrolled_in_care) as date_first_enrolled_in_care
    , max(name_of_treatment_supporter) as name_of_treatment_supporter, 
	max(treatment_supporter_telephone) as treatment_supporter_telephone
    from kenyaemr_etl.etl_hiv_enrollment group by patient_id) c on a.patient_id=c.patient_id
	left join
	(select x.patient_id, max(x.tracing_type) as tracing_type, max(x.tracing_outcome) as tracing_outcome, max(x.attempt_number) as attempt_number 
	from kenyaemr_etl.etl_ccc_defaulter_tracing x group by x.patient_id) d on a.patient_id=d.patient_id
    left join
    (select patient_id, visit_date, discontinuation_reason 
    from kenyaemr_etl.etl_patient_program_discontinuation where program_name='ccc') e on a.patient_id=e.patient_id
    left join 
    (select patient_id, 'PMTCT' as ServiceArea, max(date_enrolled) as date_enrolled from kenyaemr_etl.etl_patient_program x 
	where program='MCH-Mother Services' and date_completed is null group by patient_id) f on a.patient_id=f.patient_id
)
a where (a.days_missed >= 31 or a.days_missed is null)
and a.Discontinuation_date is null
and a.unique_patient_no is not null
and a.last_visit_date >= @fromdate;