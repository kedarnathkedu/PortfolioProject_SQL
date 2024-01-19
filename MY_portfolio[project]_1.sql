select *
from Portfolio_Project..CovidDeaths
Where continent is not null
order by 3,4

-- select *
-- from Portfolio_Project..CovidVaccination
-- order by 3,4
-- select the data that we are going to be using

select Location , date, total_cases,new_cases,total_deaths, population
From Portfolio_Project..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at the Total_cases vs Total_deaths
-- Shows likelihood of dying if you contract covid in your country

select Location , date, total_deaths ,total_cases, (total_deaths/total_cases)* 100 as Death_percentage
From Portfolio_Project..CovidDeaths
Where location like '%states%'
 and continent is not null
order by 1,2

-- Looking at the Total_cases VS Population
-- Shows what percentage of population got covid

select Location , date, Population ,total_cases,total_deaths, (total_cases/population)* 100 as Death_percentage
From Portfolio_Project..CovidDeaths
-- Where location like '%states%'
order by 1,2


-- looking at the countries with higest infection rate compared to population

select Location , Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentagePopulationInfected
From Portfolio_Project..CovidDeaths
-- Where location like '%states%'
Group by Location , Population
order by PercentagePopulationInfected desc

--- showing countries with Highest death count per Population

select Location , MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location 
order by TotalDeathCount desc


-- lets break things by coninents.

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- showing continents with the highest death count per population

select Location , MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location 
order by TotalDeathCount desc

-- Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases )* 100 as Death_percentage
From Portfolio_Project..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

With  PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(

select dea.continent, dea.location,dea.date,dea.population,dea.new_vaccinations
, SUM(CONVERT(int,dea.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location
, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date	
Where dea.continent is not null
-- order by 1,2,3
)
select *, (RollingPeopleVaccinated/Population)* 100 
From PopvsVac

-- Temp Table 

Drop Table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric,
)


insert into  #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,dea.new_vaccinations
, SUM(CONVERT(int,dea.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location
, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date	
Where dea.continent is not null
-- order by 1,2,3

select *, (RollingPeopleVaccinated/Population)* 100 
From #PercentPopulationVaccinated

--- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population,dea.new_vaccinations
, SUM(CONVERT(int,dea.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location
, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date	
Where dea.continent is not null
-- order by 1,2,3

select *
From PercentPopulationVaccinated
