SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total cases Vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE 'Colombia'
ORDER BY 1,2

--SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'CovidDeaths'

-- Change data types of a column
--ALTER TABLE PortfolioProject.dbo.CovidDeaths
--ALTER COLUMN total_cases float

-- Looking at Total cases vs. population
-- Show what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population) * 100 as CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE 'Colombia'
ORDER BY 1,2

-- Looking at percentage of Covid cases Grouped by country. 
-- Looking at countries with highest Infection Rate compared to population
SELECT 
	location, 
	MAX(total_cases) as TotalCases, 
	MAX(population) as TotalPopulation, 
	(MAX(total_cases)/MAX(population)) * 100 as CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location
ORDER BY CasesPercentage DESC

-- Looking at countries with highest Infection Rate compared to population
SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(total_cases/population) * 100 AS PercentPopulationInfected 
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with highest Death Count per Population
SELECT 
	location,
	population,
	MAX(total_deaths) AS HighestDeathCount,
	MAX(total_deaths/population) * 100 AS PercentPopulationDead
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationDead DESC

-- Showing Countries with highest Death Count per Population
SELECT 
	location,
	MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent
SELECT 
	continent,
	MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent
SELECT 
	location,
	MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent
SELECT DBC.continent, SUM(DBC.TotalDeathCount) as TotalDeathCount
FROM (
	SELECT 
		location,
		continent, 
		MAX(total_deaths) AS TotalDeathCount
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY location, continent
) as DBC
GROUP BY DBC.continent
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population


-- Global numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths--, (SUM(new_deaths)/SUM(population)) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY date

-- Covid Vaccination

ALTER TABLE PortfolioProject.dbo.CovidVaccinations
ALTER COLUMN new_vaccinations float

-- Looking at total population vs. vaccination
SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

