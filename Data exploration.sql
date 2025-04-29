

--SQL DATA EXPLORATION ---

Select *
From Project..CovidDeaths
where continent is not null
order by 3,4


--Select *
--From Project..CovidVaccinations
--order by 3,4

Select location, date,  new_cases, total_cases, total_deaths, population
from Project..CovidDeaths
order by 1,2

--Looking at tatol cases who actually get infectedd vs Total deaths 
-- shows likehood of dying if you cotract covid in your country 
SELECT 
    location, 
    date,  
    CAST(total_cases AS FLOAT) AS total_cases,
    CAST(total_deaths AS FLOAT) AS total_deaths,
    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM 
    Project..CovidDeaths
	Where location like '%states%'
ORDER BY 
    location, date;

--Looking at total cases vs population 

SELECT 
    location, 
    date,  
    CAST(total_cases AS FLOAT) AS total_cases,
    CAST(population AS FLOAT) AS population,
    (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS DeathPercentage
FROM 
    Project..CovidDeaths
	--Where location like '%states%'
ORDER BY 
    location, date;

--country with highest infection Rate comapred tp population 

SELECT 
    location, 
    CAST(MAX (total_cases) AS FLOAT) AS HoghestInfectioncount,
    CAST(MAX (population) AS FLOAT) AS population,
    (CAST(MAX (total_cases) AS FLOAT) / CAST( MAX (population) AS FLOAT)) * 100 AS PercentagePopulatedInfected
FROM 
    Project..CovidDeaths
	--Where location like '%states%'
GROUP BY 
	location
ORDER BY 
	HoghestInfectioncount;


-- Showing country with highest death count per population

SELECT 
    location, 
    CAST(MAX (total_deaths) AS int) AS TotalDeathCount
From 
	Project..CovidDeaths
	--Where location like '%states%'
	  where continent is not null
GROUP BY 
	location
ORDER BY 
	TotalDeathCount;

-- lets break thongs down by CONTINENT

SELECT 
    continent, 
    CAST(MAX (total_deaths) AS int) AS TotalDeathCount
From 
	Project..CovidDeaths
	--Where location like '%states%'
	  where continent is not null
GROUP BY 
	continent
ORDER BY 
	TotalDeathCount desc;


--GLOBAL NUMBERS

SELECT 
    --date,  
    SUM(CAST(new_cases AS INT)) AS new_cases,
    SUM(CAST(new_deaths AS INT)) AS new_deaths,
    (SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT))) * 100 AS DeathPercentage
FROM 
    Project..CovidDeaths
WHERE 
    continent IS NOT NULL
--GROUP BY date
--ORDER BY date;


Select *
From Project..CovidVaccinations
order by 3,4

--JOIN 
--TOTAL POPULATION VS VACCINATION
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac 
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Windows Function (OVER with PARTITION BY)

Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 

SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated,
(people_vaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac  
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--COMMON EXPRESSION TABLE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac  
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (PeopleVaccinated/Population)*100
From PopvsVac


--TEMP Table

DROP Table if exists  #PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac  
     On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (PeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated



--Creating View to store data for later visualization

Create View PercentagePopulationVaccinated as 
Select dea.continent, 
dea.location, 
dea.date, 
dea.population , 
vac.new_vaccinations, 

SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated,
(people_vaccinated/population)*100 as vPercentagePopulationVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac  
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


--select * 
--From PercentagePopulationVaccinated