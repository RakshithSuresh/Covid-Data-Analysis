use CovidDataAnalysis;

select distinct location from CovidDataAnalysis..CovidDeaths;

-- 1. Finding Total Cases, Total Deaths and Death Percentage
--select sum(nullif(cast(new_deaths as bigint),0)) from CovidDataAnalysis..CovidDeaths;
--select sum(nullif(cast(new_cases as bigint),0)) from CovidDataAnalysis..CovidDeaths;

select sum(nullif(cast(new_cases as bigint),0)) as Total_Cases, sum(nullif(cast(new_deaths as bigint),0)) as Total_deaths,
(sum(nullif(cast(new_deaths as float),0))/sum(nullif(cast(new_cases as float),0))) * 100 as DeathPercentage
from 
CovidDataAnalysis..CovidDeaths
where continent is not null
order by 1,2;

-- 2. Taking Total Death count continent wise
select continent ,sum(nullif(cast(new_deaths as bigint),0)) as TotalDeathCount
from 
CovidDataAnalysis..CovidDeaths
where continent is not null
group by continent
order by 2 desc;

-- 3. Calculating Infection Rate location wise
select location, population, max(total_cases) as TotalCases,
max((cast(total_cases as float)/population)) * 100 as PercentPopulationInfected
from
CovidDataAnalysis..CovidDeaths
where location not in ('High income', 'European Union', 'Oceania', 'North America', 'South America', 'World', 'Upper middle income', 'Asia', 'Lower middle income', 'Africa', 'Low income')
group by location, population
order by 4 desc;

-- 4. Calculating Infection Rate location wise and grouping by date
select location, population,date, max(total_cases) as TotalCases,
max((cast(total_cases as float)/population)) * 100 as PercentPopulationInfected
from
CovidDataAnalysis..CovidDeaths
where location not in ('High income', 'European Union', 'Europe','Oceania', 'North America', 'South America', 'World', 'Upper middle income', 'Asia', 'Lower middle income', 'Africa', 'Low income')
group by location, population,date
order by 5 desc;