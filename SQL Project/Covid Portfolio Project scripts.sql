--Using the Coronavirus (COVID-19) Deaths dataset from https://ourworldindata.org/covid-deaths

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location,date, total_cases, new_cases, total_deaths, population_density
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_deaths,total_cases,
CONVERT(decimal(15,3), total_deaths) as 'totaldeaths', 
CONVERT(decimal(15,3), total_cases) as 'totalcases',
CONVERT(DECIMAL(15, 3), (CONVERT(DECIMAL(15, 3), total_deaths) / CONVERT(DECIMAL(15, 3), total_cases))) AS 'deathpercentages'
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
ORDER BY 1,2



-- Looking at Total Cases vs Population

SELECT location,date,total_cases,population_density,
CONVERT(decimal(15,3), total_cases) as 'totalcases',
CONVERT(DECIMAL(15, 3), (CONVERT(DECIMAL(15, 3), population_density) / CONVERT(DECIMAL(15, 3), total_cases))) AS 'deathpercentages'
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location,MAX(total_cases) as highestinfectioncount,population_density
FROM PortfolioProject.dbo.CovidDeaths
Group by location, population_density
order by highestinfectioncount desc


-- Showing Countires with Highest Death count per population

SELECT location,MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject.dbo.CovidDeaths
where continent is not NULL
Group by location
order by totaldeathcount desc


--Break down by continent
SELECT continent,MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject.dbo.CovidDeaths
where continent is not NULL
Group by continent
order by totaldeathcount desc


-- Global Numbers

SELECT date,SUM(new_cases) as total_cases,SUM(cast (new_deaths as int )) as total_daeth, SUM(cast(new_deaths as int))/ nullif(SUM(New_cases),0) *100 as DeathPercentage

FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
where continent is not NULL

Group by date
ORDER BY 1,2



SELECT SUM(new_cases) as total_cases,SUM(cast (new_deaths as int )) as total_daeth, SUM(cast(new_deaths as int))/ nullif(SUM(New_cases),0) *100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
where continent is not NULL
ORDER BY 1,2



--Looking total population vs vaccinations
SELECT dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea 
Join  PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

--Use CTE
With PopvsVAc (continent,location,date,population,new_vaccinations,RollingPplVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,vac.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea 
Join  PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL

)
SELECT *,(RollingPplVaccinated/population)*100
From PopvsVAc


--TEMP Table
Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPplVaccinated numeric)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,vac.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea 
Join  PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL
SELECT *,(RollingPplVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,vac.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea 
Join  PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL

select*
From PercentPopulationVaccinated