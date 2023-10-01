/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



SELECT*
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4


--Select Data to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
ORDER BY 1,2

-- Looking at Total cases vs Total Death
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST total_deaths/total_cases AS int)*100
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1, 2


--Looking at Total Cases vs population in Nigeria

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeath
WHERE location LIKE '%igeria%' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population
-- Shows likelihood of dying if you contract covid in your country
SELECT location, population, MAX(total_cases) AS Higestinfectedcountry,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Higestinfectedcountry DESC, percentagePopulationInfected DESC

--Countries with Highest Death count per population

SELECT location, MAX (CAST(total_deaths AS int)) AS TotalDeath
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeath DESC


-- BREAKING THINGS DOWN BY CONTINENT

--Showing continent with highest death count
SELECT continent, MAX (CAST(total_deaths AS int)) AS TotalDeath
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath DESC

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Joining The Tables
SELECT *
FROM CovidDeath AS Dae
JOIN CovidVaccinations AS Vac
ON Dae.location = Vac. location
AND Dae.date = Vac.date

--Looking at Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT Dae.continent, Dae.location, Dae.date, Dae.population, Vac.new_vaccinations,
       SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dae.location ORDER BY Dae.location, Dae.date) AS RollingPeopleVaccinated
FROM CovidDeath AS Dae
JOIN CovidVaccinations AS Vac
     ON Dae.location = Vac. location
     AND Dae.date = Vac.date
WHERE Dae.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continenet, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(SELECT Dae.continent, Dae.location, Dae.date, Dae.population, Vac.new_vaccinations,
       SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dae.location ORDER BY Dae.location, Dae.date) AS RollingPeopleVaccinated
FROM CovidDeath AS Dae
JOIN CovidVaccinations AS Vac
     ON Dae.location = Vac. location
     AND Dae.date = Vac.date
WHERE Dae.continent IS NOT NULL)
--ORDER BY 2,3)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac
     

	 -- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentagePopulationVaccinated
SELECT Dae.continent, Dae.location, Dae.date, Dae.population, Vac.new_vaccinations,
       SUM(CONVERT(numeric,Vac.new_vaccinations)) OVER (PARTITION BY Dae.location ORDER BY Dae.location, Dae.date) AS RollingPeopleVaccinated
FROM CovidDeath AS Dae
JOIN CovidVaccinations AS Vac
     ON Dae.location = Vac.location
     AND Dae.date = Vac.date
--WHERE Dae.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated


--Creating View to store data for visualization
CREATE VIEW PercentagePopulationVaccinated AS
SELECT Dae.continent, Dae.location, Dae.date, Dae.population, Vac.new_vaccinations,
       SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dae.location ORDER BY Dae.location, Dae.date) AS RollingPeopleVaccinated
FROM CovidDeath AS Dae
JOIN CovidVaccinations AS Vac
     ON Dae.location = Vac. location
     AND Dae.date = Vac.date
WHERE Dae.continent IS NOT NULL
--ORDER BY 2,3	