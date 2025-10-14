Drop table covid_vaccinations ;

DROP TABLE IF EXISTS covid_deaths;

CREATE TABLE covid_deaths (
    iso_code TEXT,
    continent TEXT,
    location TEXT,
    date DATE,
    population BIGINT,
    total_cases NUMERIC,
    new_cases NUMERIC,
    new_cases_smoothed NUMERIC,
    total_deaths NUMERIC,
    new_deaths NUMERIC,
    new_deaths_smoothed NUMERIC,
    total_cases_per_million NUMERIC,
    new_cases_per_million NUMERIC,
    new_cases_smoothed_per_million NUMERIC,
    total_deaths_per_million NUMERIC,
    new_deaths_per_million NUMERIC,
    new_deaths_smoothed_per_million NUMERIC,
    reproduction_rate NUMERIC,
    icu_patients NUMERIC,
    icu_patients_per_million NUMERIC,
    hosp_patients NUMERIC,
    hosp_patients_per_million NUMERIC,
    weekly_icu_admissions NUMERIC,
    weekly_icu_admissions_per_million NUMERIC,
    weekly_hosp_admissions NUMERIC,
    weekly_hosp_admissions_per_million NUMERIC
);


CREATE TABLE covid_vaccinations (
    iso_code TEXT,
    continent TEXT,
    location TEXT,
    date DATE,
    new_tests BIGINT,
    total_tests BIGINT,
    total_tests_per_thousand NUMERIC,
    new_tests_per_thousand NUMERIC,
    new_tests_smoothed NUMERIC,
    new_tests_smoothed_per_thousand NUMERIC,
    positive_rate NUMERIC,
    tests_per_case NUMERIC,
    tests_units TEXT,
    total_vaccinations BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    new_vaccinations BIGINT,
    new_vaccinations_smoothed BIGINT,
    total_vaccinations_per_hundred NUMERIC,
    people_vaccinated_per_hundred NUMERIC,
    people_fully_vaccinated_per_hundred NUMERIC,
    new_vaccinations_smoothed_per_million NUMERIC,
    stringency_index NUMERIC,
    population_density NUMERIC,
    median_age NUMERIC,
    aged_65_older NUMERIC,
    aged_70_older NUMERIC,
    gdp_per_capita NUMERIC,
    extreme_poverty NUMERIC,
    cardiovasc_death_rate NUMERIC,
    diabetes_prevalence NUMERIC,
    female_smokers NUMERIC,
    male_smokers NUMERIC,
    handwashing_facilities NUMERIC,
    hospital_beds_per_thousand NUMERIC,
    life_expectancy NUMERIC,
    human_development_index NUMERIC
);




SELECT * 
FROM covid_deaths;

SELECT * 
FROM covid_vaccinations;


--SELECTING THE DATA WE ARE GOING TO USE

SELECT location, date, population, new_cases, total_cases, total_deaths
FROM covid_deaths
--WHERE location = 'India'
ORDER BY location, date;

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--FOR INDIA
--1
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 DEATH_PERCENT
FROM covid_deaths
ORDER BY location, date;

--2
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 DEATH_PERCENT
FROM covid_deaths
WHERE location ='India'
ORDER BY location, date;

--LOOKING AT TOTAL_CASE VS POPULATION
SELECT location, date, population, total_cases,(total_cases/population)*100 cases_per_population
FROM covid_deaths
WHERE location = 'India'
ORDER BY location, date;

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARE TO POPULATION
--showing the same foe specific country
--1
SELECT location, population, MAX(total_cases)HighestInfectionCount, MAX(total_cases/population)*100 PercentPopulationInfected
FROM covid_deaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--2
SELECT location, population, MAX(total_cases)HighestInfectionCount, MAX(total_cases/population)*100 PercentPopulationInfected
FROM covid_deaths
WHERE location = 'India'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION;
SELECT continent, MAX(total_deaths) AS Total_Deaths
FROM covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY  Total_Deaths DESC;

-- GLOBAL NUMBERS
SELECT date, SUM(total_cases)AS TOTAL_CASES_WORLDWIDE, SUM(total_deaths)AS TOTAL_DEATHS_WORLDWIDE,  (SUM(total_deaths)/SUM(total_cases))*100 AS TOTAL_DEATH_RATE
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- LOOKING AT THE NEW AND TOTAL CASES AND DEATH BY DATE
SELECT 
date,
SUM(new_cases) AS NEW_CASES, SUM(new_deaths)AS NEW_DEATHS, (SUM(new_cases)/ SUM(new_deaths))*100 AS DAILY_DEATH_RATE,
SUM(total_cases)AS TOTAL_CASES_WORLDWIDE, SUM(total_deaths)AS TOTAL_DEATHS_WORLDWIDE,  (SUM(total_deaths)/SUM(total_cases))*100 AS TOTAL_DEATH_RATE
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date;

--TOTAL POPULATION VS VACCINATIONS GLOBALY
SELECT da.continent, da.location, da.date, da.population, va.new_vaccinations,
SUM(va.new_vaccinations) OVER (PARTITION BY da.location ORDER BY da.location,da.date) AS cummulative_vaccination
FROM covid_deaths da
JOIN covid_vaccinations va
  ON da.location = va.location
  AND da.date = va.date
WHERE da.continent IS NOT NULL 
ORDER BY 2,3;



--- USE CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, cummulative_vaccination)
AS 
  (SELECT da.continent, da.location, da.date, da.population, va.new_vaccinations,
  SUM(va.new_vaccinations) OVER (PARTITION BY da.location ORDER BY da.location,da.date) AS cummulative_vaccination
  FROM covid_deaths da
  JOIN covid_vaccinations va
   ON da.location = va.location
   AND da.date = va.date
  WHERE da.continent IS NOT NULL 
  ORDER BY 2,3
 )
SELECT *
FROM pop_vs_vac;



--TEM TABLE
DROP TABLE IF EXISTS PERCENT_POPULATION_VACCINATED;
CREATE TABLE PERCENT_POPULATION_VACCINATED
(
continent text,
location text,
date date,
population bigint,
new_vaccination bigint,
cummulative_vaccination numeric
);

INSERT INTO PERCENT_POPULATION_VACCINATED
SELECT da.continent, da.location, da.date, da.population, va.new_vaccinations,
SUM(va.new_vaccinations) OVER (PARTITION BY da.location ORDER BY da.location,da.date) AS cummulative_vaccination
FROM covid_deaths da
JOIN covid_vaccinations va
  ON da.location = va.location
  AND da.date = va.date
  --WHERE da.continent IS NOT NULL 
ORDER BY 2,3;

SELECT *,(cummulative_vaccination/population)*100 as VACCINATION_RATE
FROM PERCENT_POPULATION_VACCINATED;



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW PERCENT_VACCINATED AS 
SELECT da.continent, da.location, da.date, da.population, va.new_vaccinations,
SUM(va.new_vaccinations) OVER (PARTITION BY da.location ORDER BY da.location,da.date) AS cummulative_vaccination
FROM covid_deaths da
JOIN covid_vaccinations va
  ON da.location = va.location
  AND da.date = va.date
WHERE da.continent IS NOT NULL 
;

SELECT * FROM PERCENT_VACCINATED;

