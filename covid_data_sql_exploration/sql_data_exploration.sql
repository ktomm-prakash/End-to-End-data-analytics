create database portfolio_project;
use portfolio_project;

select * from coviddeaths;

select * from covidvaccinations;


select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths
where continent is not null
order by 1,2;

-- looking at total cases vs total deaths
-- show likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location = 'india'
and continent is not null;

-- looking at total cases vs population
-- shows what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as covid_percentage
from coviddeaths
where continent is not null;


-- looking at countries highest infection rate compared to population
select location, population,max(total_cases)as highestinfectioncount,max((total_cases/population))*100 as percentagepopulationinfected
from coviddeaths
-- where location like '%ndi%'
where continent is not null 
group by location,population
order by percentagepopulationinfected desc;


-- showing countries with highest death count per population
select location, max(total_deaths)as totaldeathscount
from coviddeaths
-- where location = 'india'
where continent is not null
group by location
order by totaldeathscount desc;

-- let's break things down by continent
select continent, max(total_deaths)as totaldeathscount
from coviddeaths
where continent is not null
group by continent
order by totaldeathscount desc;

-- showing continents with the highest death count per population
select continent, max(total_deaths)as totaldeathscount
from coviddeaths
where continent is not null
group by continent
order by totaldeathscount desc;


-- global numbers
select sum(new_cases)as total_cases,sum(new_deaths)as total_deaths,sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not null;
-- group by date


select * from covidvaccinations;


-- join the two table
select * from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date;


-- looking at the total population vs vaccinations
select coviddeaths.population,sum(covidvaccinations.total_vaccinations)
from coviddeaths join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
group by coviddeaths.population;


select death.continent,death.location,death.date,death.population,vacci.new_vaccinations,
sum(vacci.new_vaccinations) over (partition by location order by death.location,death.date)as rollingpeoplevaccination
from coviddeaths death join covidvaccinations vacci
on death.location = vacci.location
and death.date = vacci.date
where death.continent is not null;



-- use CTE

with POPvsVAC(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by location order by dea.location,dea.date)as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from POPvsvac;


-- temp table
create table percentpopulationvaccinated
(
continent varchar(250),
location varchar(250),
date datetime,
population int,
new_vaccinations numeric,
RollingPeopleVaccinated int
);

insert into percentpopulationvaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by location order by dea.location,dea.date)as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select * from percentpopulationvaccinated;

select *,(RollingPeopleVaccinated/population)*100
from percentpopulationvaccinated;

-- creating view to store data for later visualization
create view percentpopulationvaccinatedd as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by location order by dea.location,dea.date)as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;



# Visualization Part

-- global numbers
select sum(new_cases)as total_cases,sum(new_deaths)as total_deaths,sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not null;


-- we take these out as they are not include in the above queries and want to stay consistent 
-- european union is part of europe
select location,sum(new_deaths)as total_death_count from coviddeaths
where continent is null
and location not in('world','european union','international')
group by location
order by total_death_count desc;

-- 3
select location, population,max(total_cases)as highestinfectioncount,max((total_cases/population))*100 as percentagepopulationinfected
from coviddeaths
group by location,population
order by percentagepopulationinfected desc;

-- 4
select location, population,date,max(total_cases)as highestinfectioncount,max((total_cases/population))*100 as percentagepopulationinfected
from coviddeaths
group by location,population,date
order by percentagepopulationinfected desc;