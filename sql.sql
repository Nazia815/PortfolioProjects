select* from covidDeaths
order by 2,4;


--select * from covidVaccinations
--order by 3,4;



--select the data that we are using


select * from covidDeaths
order by 3,4;


select location, date, total_case, new_case, total_deaths, population
from covidDeaths
order by 1,2;


--Analyzing total cases vs total deaths

select location, date, total_case,total_deaths,(cast(total_deaths as decimal) / total_case)*100 as death_per
from covidDeaths
order by 1,2;

--liklihood of dying if you contact covid in india

select location, date, total_case,total_deaths,(cast(total_deaths as decimal) / total_case)*100 as death_per
from covidDeaths
where location = 'India'
order by 1,2;


--looking at the total cases vs Population

-- shows what percentage of population got covid

select location, date,population, total_case, (cast(total_case as decimal)/population)*100 as per_pop_infected
from covidDeaths
--where location = 'India'
order by 1,2;


--Countries with highest infection rate compared to population


select location, population, max(total_case) as highest_infection_count, max(cast(total_case as decimal)/population)*100 as per_pop_infected 
from covidDeaths
--where location = 'India'
group by location, population
order by per_pop_infected desc;


--Showing Countries with Highest Death Count per Population



select location,max(total_deaths) as total_death_count
from covidDeaths
--where location = 'India'
where continent is not null
group by location
order by total_death_count desc;



--Further analysis on the basis of continents


-- showing the continents with the highest death_count


select continent, max(total_deaths) as total_death_count
from covidDeaths
--where location = 'India'
where continent is not null
group by continent
order by total_death_count desc;




--Analyses on Global numbers

--Total cases day wise

select date, sum(new_case) as total_cases , sum(new_deaths) as total_deaths,sum(cast(new_deaths as numeric))/ sum(new_case)*100 
as DeathPercentage
from covidDeaths
--where location = 'India'
where continent is not null
group by date
order by 1,2;



--Total worldwide cases and deaths

select sum(new_case) as total_cases , sum(new_deaths) as total_deaths,sum(cast(new_deaths as numeric))/ sum(new_case)*100 
as DeathPercentage
from covidDeaths
--where location = 'India'
where continent is not null
order by 1,2;



--Lets look at covidVaccinations Table now


select * from covidVaccinations;

--I noticed that by mistake i have written slightly diffrent spellings with the same colomun name 
--location in both the table so 
--correcting colomun name location from locations

alter table covidVaccinations
rename column locations to location;

--check if the column has been changed to location

select * from covidVaccinations;


-- joining both the table

select * 
from covidDeaths dea
join covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--looking at total population vs vaccination
--Calculating total new vaccination of each country


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
as Rolling_people_vac

from covidDeaths as dea
join covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 ;


-- Calculating a percentage of population vaccinated in each country
-- using CTE

with Popvsvac(continent, location,date,population, new_vaccinations, Rolling_people_vac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
    as Rolling_people_vac

from covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select * ,(Rolling_people_vac/ population)*100 as total_percentage
from Popvsvac


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	continent varchar(200),
	location varchar(200),
	date date,
	population numeric,
	new_vaccinations numeric,
	Rolling_people_vac numeric,
)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
    as Rolling_people_vac

from covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select * ,(Rolling_people_vac/ population)*100 as total_percentage
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 































