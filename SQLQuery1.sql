
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types
*/

select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select data

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows of likelihood of dying from covid in your country

select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at total cases VS population	
-- Shows what percentage of population has covid

select location, date, total_cases, population, (total_cases/ population)*100 as covid_percentage
from PortfolioProject..CovidDeaths
where location= 'United Sates'
order by 1,2

-- Looking at hightest infection count VS population

select location, MAX(total_cases) as hightest_count, population, MAX((total_cases/ population))*100 as covid_percentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by covid_percentage desc

-- Looking at countries with hightest deaths per population

select location, MAX(cast(total_deaths as int)) as hightest_deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by hightest_deaths desc

-- Breaking things per continent

--showing continects with hightest death  per population

select continent, MAX(cast(total_deaths as int)) as hightest_deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by hightest_deaths desc



-- global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int))/ sum(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

select * 
from PortfolioProject..CovidVaccinatons

-- Looking at total vaccinations VS population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by  dea.date) as rolling_count_of_vacc_people
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinatons vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using CTE for calculation on previous query

with PopVsVac ( continent, location, date, population, new_vaccinations, rolling_count_of_vacc_people)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by  dea.date) as rolling_count_of_vacc_people
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinatons vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select *, (rolling_count_of_vacc_people/population)*100
from PopVsVac



-- using TEMP TABLE for calculation on previous query

Drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_count_of_vacc_people numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by  dea.date) as rolling_count_of_vacc_people
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinatons vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select *, (rolling_count_of_vacc_people/population)*100
from #PercentagePopulationVaccinated


--Creating views to store data for later visualizations

create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by  dea.date) as rolling_count_of_vacc_people
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinatons vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
from PercentagePopulationVaccinated