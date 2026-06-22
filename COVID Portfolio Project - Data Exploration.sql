select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select Data that we are going to be using

select Location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select Location,date, Population, total_cases,  (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at countries with Highest Infection Rate copmared to Population

select Location, Population, max(total_cases) as HighestInfectionCount, max ((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population
select Location, max(cast (total_deaths as int )) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- LET's BREAK THINGS DOWN BY CONTINENT
select continent, max(cast (total_deaths as int )) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population
select continent, max(cast (total_deaths as int )) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths,sum(cast (new_deaths as int))/sum(new_cases)*100 
as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


---------
with PopvsVac(Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum (convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--USE CTE
--with PopvsVac


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
contintnent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum (convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 1,2

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

----




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated
