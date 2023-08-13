----------------------------------------LEVEL 3 PROBLEMS------------------------------------------------------

-- Show all of the patients grouped into weight groups.
--Show the total amount of patients in each weight group.
--Order the list by the weight group decending.
--For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.

SELECT
	COUNT(*) as patients_in_group,
    FLOOR(weight/10) * 10 AS weight_group
FROM patients
group by weight_group
ORDER BY weight_group DESC

-- Show patient_id, weight, height, isObese from the patients table.
--Display isObese as a boolean 0 or 1.
--Obese is defined as weight(kg)/(height(m)2) >= 30.
--weight is in units kg.
--height is in units cm.

SELECT
	patient_id,
    weight,
    height,
    CASE 
    	WHEN (weight * 10000 /(height*height))>=30 THEN 1
        ELSE 0
       END AS isObese
FROM patients

-- Show patient_id, first_name, last_name, and attending doctor's specialty.
--Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'
--Check patients, admissions, and doctors tables for required information.

SELECT 
	patients.patient_id,
    patients.first_name,
    patients.last_name,
    doctors.specialty
FROM patients
INNER JOIN admissions
	ON patients.patient_id = admissions.patient_id
INNER JOIN doctors 
	ON doctors.doctor_id = admissions.attending_doctor_id
WHERE 
	admissions.diagnosis = 'Epilepsy' 
    AND doctors.first_name = 'Lisa';
	
-- All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
--The password must be the following, in order:
--1. patient_id
--2. the numerical length of patient's last_name
--3. year of patient's birth_date

SELECT 
	DISTINCT(patients.patient_id),
    CONCAT(patients.patient_id,LEN(last_name),YEAR(birth_date)) AS temp_password
FROM patients
INNER JOIN admissions
	ON patients.patient_id = admissions.patient_id
	
--Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance.
--Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.

SELECT
	CASE
    	WHEN patient_id%2=0 THEN 'YES'
        ELSE 'NO'
       END AS has_insurance,
       	
     SUM(CASE 
      	WHEN patient_id%2=0 THEN 10
      	ELSE 50
      END )AS cost_after_insurance
      
FROM admissions
GROUP BY has_insurance

-- Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name

SELECT 
	province_name
FROM patients
INNER JOIN province_names
	ON province_names.province_id = patients.province_id
group by province_names.province_name
having
	COUNT(CASE WHEN gender = 'M' THEN 1 END) > COUNT(CASE WHEN gender='F' THEN 1 END)
	
-- We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
-- First_name contains an 'r' after the first two letters.
-- Identifies their gender as 'F'
-- Born in February, May, or December
-- Their weight would be between 60kg and 80kg
-- Their patient_id is an odd number
-- They are from the city 'Kingston'

SELECT * FROM patients
WHERE
	first_name LIKE '__r%' AND
    gender = 'F' AND
    weight between 60 AND 80 AND
    patient_id % 2 != 0 AND
    city = 'Kingston'
	
-- Show the percent of patients that have 'M' as their gender. Round the answer to the nearest hundreth number and in percent form.

SELECT 
	CONCAT(
      ROUND(
        (SELECT COUNT(*) 
         FROM patients
         WHERE gender='M'
         ) / CAST(COUNT(*) AS float), 4) * 100 ,'%')
FROM patients

-- For each day display the total amount of admissions on that day. Display the amount changed from the previous date.

SELECT
	admission_date,
	COUNT(admission_date),
    COUNT(admission_date) - LAG(count(admission_date)) OVER(order by admission_date) as admission_count
FROM admissions
group by admission_date

-- Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.

SELECT
	province_name
FROM province_names
order by 
	case
    	WHEN province_name = 'Ontario' THEN 0
        ELSE 1
	END
	
-- We need a breakdown for the total amount of admissions each doctor has started each year. Show the doctor_id, doctor_full_name, specialty, year, total_admissions for that year.

select 
	doctors.doctor_id,
    concat(doctors.first_name, ' ' , doctors.last_name) as doctor_name,
    specialty,
    year(admissions.admission_date) as year_selected,
    COUNT(*) AS total_admissions
FROM admissions
inner join doctors on doctors.doctor_id = admissions.attending_doctor_id
group by doctors.first_name, doctors.last_name, year(admission_date)

-------------------------------------------------------------------------------------------------
---------------------------------------------LEVEL 2 PROBLEMS----------------------------------------------------------

-- Show unique birth years from patients and order them by ascending.

select distinct(year(birth_date)) as birth_year 
FROM patients
ORDER BY YEAR(birth_date);

-- Show unique first names from the patients table which only occurs once in the list.
-- For example, if two or more people are named 'John' in the first_name column then don't include their name in the output list. If only 1 person is named 'Leo' then include them in the output.

SELECT 
	distinct(first_name)
FROM patients
group by first_name
HAVING COUNT(first_name) = 1;

-- Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.

SELECT 
	patient_id,
    first_name
FROM patients
WHERE 
	first_name LIKE 's%s' and
    len(first_name) >= 6;
	
-- Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
-- Primary diagnosis is stored in the admissions table.

SELECT 
	patients.patient_id,
    first_name,
    last_name
FROM patients
INNER JOIN admissions
	ON admissions.patient_id = patients.patient_id
where admissions.diagnosis = 'Dementia';

-- Display every patient's first_name.
-- Order the list by the length of each name and then by alphbetically

SELECT first_name
FROM patients
ORDER BY len(first_name), first_name;

-- Show the total amount of male patients and the total amount of female patients in the patients table.
-- Display the two results in the same row.

SELECT 
	COUNT(
      CASE
    	WHEN gender = 'M' THEN 1
      END) AS male_count,
      
    COUNT(
      	CASE
			WHEN gender = 'F' THEN 1
      	END)  AS female_count
FROM patients

-- Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. Show results ordered ascending by allergies then by first_name then by last_name.

SELECT 
	first_name,
    last_name,
    allergies
FROM patients
WHERE allergies IN ('Penicillin', 'Morphine')
ORDER BY allergies, first_name, last_name

-- Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.

SELECT 
	patient_id,
    diagnosis
FROM admissions
group by patient_id, diagnosis
HAVING count(*) >1;

-- Show the city and the total number of patients in the city.
-- Order from most to least patients and then by city name ascending.

SELECT 
	city,
    COUNT(*) AS num_patients
FROM patients
group by city
order by num_patients DESC,
		city ASC;
		
-- Show first name, last name and role of every person that is either patient or doctor.
-- The roles are either "Patient" or "Doctor"

SELECT 
	first_name,
    last_name,
    CASE
    	WHEN true THEN 'Patient'
     END AS roles
FROM patients
	
UNION ALL

SELECT 
	first_name,
	last_name,
    CASE 
    	WHEN true THEN 'Doctor'
        END AS roles
FROM doctors

-- Show all allergies ordered by popularity. Remove NULL values from query.

SELECT
	allergies,
    count(allergies)
FROM patients
WHERE allergies is NOT NUll
group by (allergies)
ORDER BY count(allergies) DESC

-- Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.

SELECT 
	first_name,
    last_name,
    birth_date
FROM patients
WHERE YEAR(birth_date) between 1970 AND 1979
ORDER BY birth_date

-- We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, then first_name in all lower case letters. Separate the last_name and first_name with a comma. Order the list by the first_name in decending order

SELECT
	CONCAT(UPPER(last_name),',',LOWER(first_name))
FROM patients
order by first_name DESC;

-- Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.

SELECT
	province_id,
    SUM(height) AS sum_height
FROM patients
GROUP BY province_id
HAVING sum_height >= 7000;

-- Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'

SELECT 
	MAX(weight) - MIN(weight)
FROM patients
WHERE last_name = 'Maroni';

-- Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with most admissions to least admissions.

SELECT 
	day(admission_date),
	COUNT(DAY(admission_date)) as admission_count
FROM admissions
group by DAY(admission_date)
ORDER BY admission_count DESC

-- Show all columns for patient_id 542's most recent admission_date.

SELECT * FROM admissions
WHERE 
	patient_id = 542 AND
    admission_date = (
      	SELECT MAX(admission_date) FROM admissions
      	WHERE patient_id = 542
      )
	  
-- Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
-- 1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
-- 2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.

SELECT
	patient_id,
    attending_doctor_id,
    diagnosis
FROM admissions
WHERE 	
	(patient_id % 2 != 0 AND
    attending_doctor_id IN (1,5,19))
    or 
    (CAST(attending_doctor_id AS char)) LIKE '%2%' AND
    LEN(CAST(patient_id AS char)) = 3;
	
-- Show first_name, last_name, and the total number of admissions attended for each doctor.
-- Every admission has been attended by a doctor.

SELECT 
	doctors.first_name,
    doctors.last_name,
    COUNT(*)
FROM admissions
INNER JOIN doctors 
	ON doctors.doctor_id = admissions.attending_doctor_id
group by attending_doctor_id

-- For each doctor, display their id, full name, and the first and last admission date they attended.

SELECT 
	attending_doctor_id,
    CONCAT(first_name, ' ', last_name),
    MIN(admission_date),
    Max(admission_date)
FROM admissions
INNER JOIN doctors 
	ON doctors.doctor_id = admissions.attending_doctor_id
group by attending_doctor_id

-- Display the total amount of patients for each province. Order by descending.

SELECT 
	province_name,
	COUNT(*) as total_patients
FROM patients
INNER JOIN province_names
	ON patients.province_id = province_names.province_id
group by patients.province_id
order by total_patients DESC

-- For every admission, display the patient's full name, their admission diagnosis, and their doctor's full name who diagnosed their problem.

SELECT 
	CONCAT(patients.first_name, ' ', patients.last_name),
    diagnosis,
    CONCAT(doctors.first_name, ' ', doctors.last_name)
FROM patients
INNER JOIN admissions
	ON patients.patient_id = admissions.patient_id
INNER JOIN doctors
	ON admissions.attending_doctor_id = doctors.doctor_id
	
-- display the number of duplicate patients based on their first_name and last_name.

SELECT 
	first_name,
    last_name,
    COUNT(concat(first_name,last_name)) as num_duplicates
FROM patients
group by first_name, last_name
HAVING num_duplicates > 1;

-- Display patient's full name,
--height in the units feet rounded to 1 decimal,
--weight in the unit pounds rounded to 0 decimals,
--birth_date,
--gender non abbreviated.
--Convert CM to feet by dividing by 30.48.
--Convert KG to pounds by multiplying by 2.205.

SELECT
	CONCAT(first_name, ' ', last_name),
    ROUND((height/30.48),1),
    ROUND((weight*2.205),0),
    birth_date,
    CASE
      	WHEN gender = 'M' THEN 'MALE'
      	ELSE 'FEMALE'
    	END AS gender_type 

FROM patients;

-- Show patient_id, first_name, last_name from patients whose does not have any records in the admissions table. (Their patient_id does not exist in any admissions.patient_id rows.)

select patient_id,first_name, last_name FROM patients
where patients.patient_id NOT IN (
select patients.patient_id from patients
inner join admissions on patients.patient_id = admissions.patient_id)

-------------------------------------------------------------------------------------------------
---------------------------------------------LEVEL 1 PROBLEMS----------------------------------------------------------

-- Show first name, last name, and gender of patients whose gender is 'M'

SELECT first_name, last_name, gender FROM patients
WHERE gender = 'M';

-- Show first name and last name of patients who does not have allergies. (null)

SELECT 	
	first_name,
    last_name
FROM patients
WHERE allergies is NULL

-- Show first name of patients that start with the letter 'C'

SELECT 	
	first_name
FROM patients
WHERE first_name LIKE 'C%';

-- Show first name and last name of patients that weight within the range of 100 to 120 (inclusive)

SELECT 	
	first_name,
    last_name
FROM patients
WHERE weight between 100 AND 120;

-- Update the patients table for the allergies column. If the patient's allergies is null then replace it with 'NKA'

UPDATE patients SET allergies = 'NKA'
WHERE allergies IS NULL;

-- Show first name and last name concatinated into one column to show their full name.

SELECT 
	concat(first_name, ' ', last_name) AS full_name
FROM patients;

-- Show first name, last name, and the full province name of each patient.

SELECT 
	patients.first_name, 
    patients.last_name,
    province_name
FROM patients
INNER JOIN province_names
ON province_names.province_id = patients.province_id;

-- Show how many patients have a birth_date with 2010 as the birth year.

SELECT 
	COUNT(*)
FROM patients
WHERE year(birth_date) = 2010;
-- Show the first_name, last_name, and height of the patient with the greatest height.

SELECT 
	first_name,
    last_name,
    height
FROM patients
order by height DESC
LIMIT 1;

-- Show all columns for patients who have one of the following patient_ids: 1,45,534,879,1000

SELECT * FROM patients
WHERE patient_id IN (1,45,534,879,1000)

-- Show all the columns from admissions where the patient was admitted and discharged on the same day.

SELECT * FROM admissions
WHERE admission_date = discharge_date;

-- Show the patient id and the total number of admissions for patient_id 579.

SELECT 
	patient_id,
    count(*)
FROM admissions
WHERE patient_id = 579;

-- Based on the cities that our patients live in, show unique cities that are in province_id 'NS'?

SELECT 
	distinct(city)
FROM patients
WHERE province_id = 'NS';

-- Write a query to find the first_name, last name and birth date of patients who has height greater than 160 and weight greater than 70

SELECT
	first_name,
    last_name,
    birth_date
FROM patients
WHERE 
	height>160 AND
    weight>70;
	
-- Write a query to find list of patients first_name, last_name, and allergies from Hamilton where allergies are not null

SELECT
	first_name,
    last_name,
    allergies
FROM patients
WHERE 
	city = 'Hamilton' AND
    allergies IS NOT NULL;
	
-- Based on cities where our patient lives in, write a query to display the list of unique city starting with a vowel (a, e, i, o, u). Show the result order in ascending by city.

SELECT 
	distinct(city)
FROM patients
WHERE 
	city LIKE 'a%' OR
    city LIKE 'e%' OR
    city LIKE 'i%' OR
    city LIKE 'o%' or
    city LIKE 'u%' 
ORDER BY city;



