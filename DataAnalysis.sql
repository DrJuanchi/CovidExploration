#Data was imported with "NULL" instead of null. Therefore to correct that
UPDATE coviddeaths
	SET continent = null
WHERE continent = "NULL";

UPDATE covidvaccinations
	SET continent = null
WHERE continent = "NULL";

SELECT * FROM coviddeaths
WHERE continent is not NULL
ORDER BY 3, 4;

#Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1, 2;

#Looking at the Total Cases vs Total Deaths
#Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE Location LIKE "%spain%"
ORDER BY 1, 2;

#Looking at the Total Cases vs Population
#Shows percentage of population that got COVID
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM coviddeaths
WHERE Location Like "%spain%"
ORDER BY 1, 2;

#Looking at countries with the highest Infection Rate
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as HighestInfectedPercentage
FROM coviddeaths
GROUP BY Location, population
ORDER BY HighestInfectedPercentage DESC;

#Looking at countries with the highest death count per Population
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

#BREAKING THINGS DOWN BY CONTINENT

#Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;



#GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
#GROUP BY date
ORDER BY 1, 2;


#Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.Location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


#USE CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.Location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 FROM PopVsVac;



#Creating Views to store data for later visualizations
Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.Location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

Create View ContinentDeaths as
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

Create View SpainInfectionRate as
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM coviddeaths
WHERE Location Like "%spain%"
ORDER BY 1, 2;

