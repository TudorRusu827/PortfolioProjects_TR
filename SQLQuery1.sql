-- Showing Countries with the highest Death Count per Population, per Location

select location, max(total_deaths) as TotalDeaths
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeaths desc

--Per continent

select continent, max(total_deaths) as TotalDeaths
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeaths desc

--Global Numbers

select date, sum(new_cases), sum(new_deaths), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccination

select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	
	on dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac (Continent,Location,Date,Population,new_vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	
	on dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null

)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
drop table if exists #percentpopulationvaccinated
Create table #PercentPopulationVaccinated

( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	
	on dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null

select *
from #PercentPopulationVaccinated


-- GLOBAL Numbers

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage

from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Creating View to store data for later visualization

create view PercentPopulationVaccinated as

select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	
	on dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null


select * 

from PercentPopulationVaccinated