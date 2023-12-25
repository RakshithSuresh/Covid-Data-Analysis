use CovidDataAnalysis;

select * from
CovidDataAnalysis..CovidDeaths
where continent is not null
order by 3,4;

--select * from
--CovidDataAnalysis..CovidVaccinations
--order by 3,4;

-- calculating death percentage
select location,date,total_cases, total_deaths,
(convert(float,total_deaths)/NULLIF(convert(float,total_cases),0))*100 as DeathPercentage
from CovidDataAnalysis..CovidDeaths
where continent is not null
order by 1,2;

-- calculating for specific countries using LIKE and extracting highest death percentage month
select location,date,total_cases, total_deaths,
(convert(float,total_deaths)/NULLIF(convert(float,total_cases),0))*100 as DeathPercentage
from CovidDataAnalysis..CovidDeaths
where location like '%states%' and continent is not null
order by 5 desc;

-- total case vs population
-- what percentage of people got covid (highest percentage at the top)
select location, date, population,total_cases,
(convert(float,total_cases)/NULLIF(convert(float,population),0))*100 as InfectedPopulationPercent
from CovidDataAnalysis..CovidDeaths
where location like '%states%' and continent is not null
order by 1 asc,2 desc;

-- finding country with highest infection rate
select location, population,max(total_cases) as highestInfectionCount,
max((convert(float,total_cases)/NULLIF(convert(float,population),0)))*100 as Population
from CovidDataAnalysis..CovidDeaths
where continent is not null
group by location,population
order by 4 desc;

-- showing countries with highest death rate
select location, max(total_deaths) as highestDeathRate
from CovidDataAnalysis..CovidDeaths
where continent is not null
group by location
order by 2 desc;

-- showing continents with highest death rate
select location, max(total_deaths) as highestDeathRate
from CovidDataAnalysis..CovidDeaths
where continent is null
group by location
order by highestDeathRate desc;

-- GLOBAL NUMBERS

select location,date,total_cases, total_deaths,
(convert(float,total_deaths)/NULLIF(convert(float,total_cases),0))*100 as DeathPercentage
from CovidDataAnalysis..CovidDeaths
where continent is not null
order by 1 asc, 2 desc;

-- looking at the worldwide new cases and deaths by date
select date, sum(new_cases) as New_cases, sum(new_deaths) as New_deaths
from CovidDataAnalysis..CovidDeaths
where continent is not null
group by date
order by 1;

-- death percentage globally across the world grouped by date
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
SUM(cast(new_deaths as float)) / NULLIF(SUM(cast(new_cases as float)), 0) * 100 AS DeathPercentage
from CovidDataAnalysis..CovidDeaths
where continent is not null
group by date
order by 1;

-- total death and total cases, and death percentage
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
SUM(cast(new_deaths as float)) / NULLIF(SUM(cast(new_cases as float)), 0) * 100 AS DeathPercentage
from CovidDataAnalysis..CovidDeaths
where continent is not null
order by 1;

-- joining two tables
select * 
from CovidDataAnalysis..CovidDeaths dea
join CovidDataAnalysis..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date;

-- total population v total vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations)over (partition by dea.location order by dea.location, dea.date) as Rolling_people_Vaccinated
from CovidDataAnalysis..CovidDeaths dea
join CovidDataAnalysis..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- using CTE
with PopvsVac (continent, location, date, population, new_vaccinations, Rolling_people_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations)over (partition by dea.location order by dea.location, dea.date) as Rolling_people_Vaccinated
from CovidDataAnalysis..CovidDeaths dea
join CovidDataAnalysis..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--and dea.location like '%states%'
)
select *, cast (Rolling_people_Vaccinated as float) / cast(population as float) * 100 as Peeps_Vaccinated_Percent
from PopvsVac;

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent varchar(100), location varchar(100), date datetime, population numeric, new_vaccinations numeric, Rolling_people_Vaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations)over (partition by dea.location order by dea.location, dea.date) as Rolling_people_Vaccinated
from CovidDataAnalysis..CovidDeaths dea
join CovidDataAnalysis..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--and dea.location like '%states%'

select *, cast (Rolling_people_Vaccinated as float) / cast(population as float) * 100 as Peeps_Vaccinated_Percent
from #PercentPopulationVaccinated;

-- Creating view to store data for visualizations later
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations)over (partition by dea.location order by dea.location, dea.date) as Rolling_people_Vaccinated
from CovidDataAnalysis..CovidDeaths dea
join CovidDataAnalysis..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--and dea.location like '%states%'

use CovidDataAnalysis;

select *
from PercentPopulationVaccinated;