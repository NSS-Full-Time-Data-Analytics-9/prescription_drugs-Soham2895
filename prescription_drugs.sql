
 -- 1.a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
    
	SELECT npi, SUM(total_claim_count) as total
	FROM public.prescription
	GROUP BY npi
	ORDER BY SUM(total_claim_count) DESC
	LIMIT 1
 --b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT p1.nppes_provider_first_name,p1.nppes_provider_last_org_name,p1.specialty_description, count(total_claim_count)
FROM public.prescriber as p1
INNER JOIN public.prescription as p2
ON p1.npi = p2.npi 
GROUP BY p1.nppes_provider_first_name,p1.nppes_provider_last_org_name,p1.specialty_description
ORDER BY count(total_claim_count) DESC

--2. 
   -- a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT p1.specialty_description, SUM(total_claim_count) AS total_num_claims
FROM public.prescriber AS p1
INNER JOIN public.prescription AS p2
ON p1.npi = p2.npi
GROUP BY p1.specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 1
   -- b. Which specialty had the most total number of claims for opioids?

SELECT p1.specialty_description, SUM(total_claim_count) AS number_claims
FROM public.prescriber AS p1
INNER JOIN public.prescription p2
ON p1.npi = p2.npi
INNER JOIN public.drug AS d1
ON p2.drug_name = d1.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY p1.specialty_description,d1.drug_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 10

   -- c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT p1.specialty_description
FROM public.prescriber AS p1
LEFT JOIN public.prescription AS p2
ON p1.npi = p2.npi
WHERE p2.npi IS NULL




    --d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--3. 
   -- a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost)
FROM public.drug d1
INNER JOIN public.prescription AS p1
ON d1.drug_name = p1.drug_name
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC
LIMIT 5

    --b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT generic_name, 
       round((SUM(total_drug_cost)/p1.total_day_supply),2) AS cost_per_day
FROM public.drug d1
INNER JOIN public.prescription AS p1
ON d1.drug_name = p1.drug_name
GROUP BY generic_name,p1.total_day_supply
ORDER BY SUM(total_drug_cost) DESC
LIMIT 5


SELECT generic_name, round((SUM(total_drug_cost)/365),2) AS cost_per_day
FROM public.drug d1
INNER JOIN public.prescription AS p1
ON d1.drug_name = p1.drug_name
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC
LIMIT 5

--4. 
 --a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
       CASE 
           WHEN opioid_drug_flag = 'Y' THEN 'opioid'
           WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
           ELSE 'neither'
       END AS drug_type
FROM public.drug;


--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT drug_name,SUM(total_drug_cost) AS total_drug_cost,
       CASE 
           WHEN opioid_drug_flag = 'Y' THEN 'opioid'
           WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
           ELSE 'other'
       END AS drug_type
FROM public.drug AS d1
INNER JOIN public.prescription AS p1
USING (drug_name)
GROUP BY drug_type,drug_name
ORDER BY SUM(total_drug_cost)


--5. 
    --a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT count (DISTINCT cbsaname)
FROM public.cbsa
WHERE cbsaname ILIKE '%TN%'
 
 
 SELECT COUNT(DISTINCT cbsa)
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN';
    --b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
--Largest population
SELECT cbsaname, MAX (population) AS largest_population
FROM public.cbsa AS c1
INNER JOIN public.population AS p1
USING (fipscounty)
GROUP BY cbsaname
ORDER BY  MAX (population) DESC
LIMIT 1

--Smallest population

SELECT cbsaname, MIN (population) AS largest_population
FROM public.cbsa AS c1
INNER JOIN public.population AS p1
USING (fipscounty)
GROUP BY  cbsaname
ORDER BY  MIN (population) ASC
LIMIT 1

--Largest & Smallest Population combined in single query 

SELECT cbsaname, MAX (population) AS largest_population,MIN (population) AS smallest_population
FROM public.cbsa AS c1
INNER JOIN public.population AS p1
USING (fipscounty)
GROUP BY cbsaname
ORDER BY  MAX (population) DESC, 
           MIN(population) ASC
LIMIT 2

    --c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT county,population
FROM population
INNER JOIN fips_county
USING (fipscounty)
WHERE fipscounty NOT IN (SELECT DISTINCT fipscounty
FROM cbsa)
ORDER BY population DESC;

--6. 
    --a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name,SUM(total_claim_count)
FROM public.prescription
WHERE total_claim_count >= 3000 
GROUP BY drug_name
ORDER BY SUM (total_claim_count) DESC

    --b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name,total_claim_count,opioid_drug_flag
FROM public.prescription AS p1
INNER JOIN public.drug AS d1
USING (drug_name)
WHERE  total_claim_count >= 3000 
       AND opioid_drug_flag ='Y'
ORDER BY total_claim_count DESC

----USING CASE STATEMENT QUERY ----

SELECT  drug_name,total_claim_count,
CASE 
     WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	 ELSE 'other'
     END AS drug_type 
FROM public.prescription AS p1
INNER JOIN public.drug AS d1
USING (drug_name)
WHERE total_claim_count >= 3000 
ORDER BY total_claim_count DESC

    --c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row
SELECT p2.nppes_provider_first_name,p2.nppes_provider_last_org_name,d1.drug_name,p1.total_claim_count,d1.opioid_drug_flag
FROM public.prescription AS p1
INNER JOIN public.drug AS d1
USING (drug_name)
INNER JOIN public.prescriber AS p2
USING (npi)
WHERE total_claim_count <= 3000 
       AND opioid_drug_flag ='Y'
ORDER BY total_claim_count DESC

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

    --a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT npi,drug_name
FROM public.prescriber AS p1
CROSS JOIN public.drug AS d1	
WHERE p1.specialty_description = 'Pain Management'
AND p1.nppes_provider_city = 'NASHVILLE'
AND d1.opioid_drug_flag = 'Y'



--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
   
SELECT p1.npi, d1.drug_name, total_claim_count
FROM prescription AS p1, prescriber AS p2, drug AS d1
WHERE p2.specialty_description = 'Pain Management'
AND p2.nppes_provider_city = 'NASHVILLE'
AND d1.opioid_drug_flag = 'Y' 
GROUP BY p1.npi, d1.drug_name






--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT p2.npi, d1.drug_name, COALESCE(SUM(p1.total_claim_count), 0) AS total_claim_count
FROM prescription AS p1,prescriber AS p2,drug AS d1
WHERE p2.specialty_description = 'Pain Management'
AND p2.nppes_provider_city = 'NASHVILLE'
AND d1.opioid_drug_flag = 'Y' 
GROUP BY p2.npi, d1.drug_name;


--BONUS QUERY

--1. How many npi numbers appear in the prescriber table but not in the prescription table?

SELECT COUNT(DISTINCT p1.npi)
FROM prescriber AS p1
LEFT JOIN prescription AS p2
ON p1.npi = p2.npi
WHERE p2.npi IS NULL;


-- 2.
--a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT d1.generic_name
FROM public.prescription AS p1
INNER JOIN public.drug AS d1
USING (drug_name)
INNER JOIN public.prescriber AS p2
USING (npi)
WHERE specialty_description = 'Family Practice'
LIMIT 5

--b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT d1.generic_name
FROM public.prescription AS p1
INNER JOIN public.drug AS d1
USING (drug_name)
INNER JOIN public.prescriber AS p2
USING (npi)
WHERE specialty_description = 'Cardiology'
LIMIT 5
--c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

SELECT d1.generic_name
FROM public.prescription AS p1
INNER JOIN public.drug AS d1
USING (drug_name)
INNER JOIN public.prescriber AS p2
USING (npi)
WHERE specialty_description IN ('Cardiology','Family Practice')
      --AND  specialty_description = 'Family Practice'
LIMIT 5



--Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
  
  WITH Nashville_prescribers AS  (SELECT npi,drug_name, SUM(total_claim_count) AS num_claim
	                               FROM public.prescription
	                               GROUP BY npi,drug_name)
	SELECT p1.npi,	nppes_provider_city,num_claim
	FROM public.prescriber AS p1
	INNER JOIN Nashville_prescribers AS n1
	ON p1.npi = n1.npi
	WHERE nppes_provider_city ILIKE'%Nashville%'
	GROUP BY p1.npi,nppes_provider_city,num_claim
	ORDER BY num_claim DESC
	LIMIT 5

--b. Now, report the same for Memphis.
    
--c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

