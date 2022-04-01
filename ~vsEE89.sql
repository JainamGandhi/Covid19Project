SELECT *
FROM Covid19..CovidDeaths$
where continent is not null
order by 3,4


Select location,date,total_cases,new_cases,total_deaths,population
FROM Covid19..CovidDeaths$
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid19..CovidDeaths$
where location like '%india%' and continent is not null

order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location,date,Population,total_cases, (total_cases/population)*100 as PopulationPercentageInfected
FROM Covid19..CovidDeaths$
where location like '%india%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location,Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
FROM Covid19..CovidDeaths$
--where location like '%india%'
Group By location , Population
order by PopulationPercentageInfected desc

--Countries with highest death count
Select location,MAX(cast(total_deaths as int)) as HighestDeathCount
FROM Covid19..CovidDeaths$
where continent is not null
--where location like '%india%'
Group By location 
order by HighestDeathCount desc

--Break Things by Continent 
--Continent with highest death count
Select continent,MAX(cast(total_deaths as int)) as HighestDeathCount
FROM Covid19..CovidDeaths$
where continent is not null
--where location like '%india%'
Group By continent 
order by HighestDeathCount desc

-- GLOBAL NUMBERS

Select sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
FROM Covid19..CovidDeaths$
--where location like '%india%' 
where continent is not null

-- Total Vaccinations vs Total Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19..CovidDeaths$ dea
Join Covid19..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--CTE
With PopsVac(Continent , Location , Date , Population,New_Vaccinations,RollingPeopleVaccinated)
AS(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19..CovidDeaths$ dea
Join Covid19..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinateds
CREATE Table #PercentPopulationVaccinateds
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinateds
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19..CovidDeaths$ dea
Join Covid19..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinateds


--Creating View

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19..CovidDeaths$ dea
Join Covid19..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
 
 Select * 
 From PercentPopulationVaccinated