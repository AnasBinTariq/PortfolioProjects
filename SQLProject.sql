Select *
From PortfolioProject.dbo.CovidDeaths
Order By 3,4

Select *
From PortfolioProject.dbo.CovidVaccinations
Order By 3,4
--Alter Table PortfolioProject..CovidVaccinations
--Drop Column F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24, F25, F26   /*** These two scripted lines for deleting column by names ****/

--SELECT DATA WE ARE GOING TO USE

Select continent, country, date, population, total_cases, new_cases, total_deaths
From PortfolioProject..CovidDeaths
Where continent is Not Null
Order By 2,3

--LOOKING AT TOTAL DEATHS VS TOTAL CASES 
--SHOWS LIKELIHOOD OF DYING IF PEOPLE CONTRACT COVID IN THEIR COUNTRY

Select country, date, total_deaths, total_cases, 
Case 
	When total_cases <> 0 Then (total_deaths/total_cases)*100 
End	AS DeathRate 
From PortfolioProject..CovidDeaths
Where continent is Not Null
--and country like '%Pakistan%'
Order By 1,2  

--LOOKING AT THE TOTAL CASES VS POPULATION
-- SHOWS PERCENTAGE OF POPULATION GOT CORONA INFECTED

Select country, date, total_cases, population, (total_cases/population)*100 AS InfectedRate 
From PortfolioProject..CovidDeaths
Where continent is Not Null
--and country like '%Pakistan%'
Order By 1,2 

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE AS COMPARED TO POPULATION

Select country, population, Max(total_cases) As MaxCases, Max(total_cases/population)*100 As HighestInfectedRate 
From PortfolioProject..CovidDeaths
Where continent is Not Null
--and country like '%Pakistan%'
Group By country, population
Order By HighestInfectedRate Desc 

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select country, Max(total_deaths) As MaxDeaths 
From PortfolioProject..CovidDeaths
Where continent is Not Null
--and country like '%Pakistan%'
Group By country, population
Order By MaxDeaths Desc

--LETS BREAKDOWN BY CONTINENT
--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
 
Select continent, Max(total_deaths) As MaxDeaths 
From PortfolioProject..CovidDeaths
Where continent is Not Null
--and country like '%Pakistan%'
Group By continent
Order By MaxDeaths Desc

--GLOBAL NUMBERS

Select Sum (new_deaths) as CumulativeDeaths, Sum (new_cases) as CumulativeCases,
Case 
	When Sum (new_cases) <> 0 Then Sum (new_deaths)/Sum (new_cases)*100
End	AS CumulativeDeathRate 
From PortfolioProject..CovidDeaths
Where continent is Not Null
--and country like '%Pakistan%'
--Group By date
--Order By 1 

--LOOKING AT TOTAL POPULATION VS TOTAL PEOPLE VACCINATED 

Select Cdea.date, Cdea.continent, Cdea.country, population, Cvac.new_vaccinations,
Sum(cast(new_vaccinations as float)) over (partition by Cdea.country order by Cdea.country, Cdea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 /*** Now Wanted to calculate total people vaccinated out of total population but we can not use alias in the same scope ***/
/**** as we can not use alias so here the role of CTE and Temp Table comes in to play ****/
From PortfolioProject..CovidDeaths Cdea
Join PortfolioProject..CovidVaccinations Cvac
	On Cdea.country = Cvac.country
	And Cdea.date = Cvac.date
Where Cdea.continent Is Not Null
Order By 2,3,1

--USING CTE (Use CTE every time with the select statement)

With PopVsVac (date, continent, country, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select Cdea.date, Cdea.continent, Cdea.country, population, Cvac.new_vaccinations,
Sum(cast(new_vaccinations as float)) over (partition by Cdea.country order by Cdea.country, Cdea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Cdea
Join PortfolioProject..CovidVaccinations Cvac
	On Cdea.country = Cvac.country
	And Cdea.date = Cvac.date
Where Cdea.continent Is Not Null
--Order By 2,3,1
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVsVac

--USING TEMP TABLE

Drop Table if exists #PopVsVac 
Create Table #PopVsVac
(date datetime,
continent nvarchar(255),
country nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PopVsVac 
Select Cdea.date, Cdea.continent, Cdea.country, population, Cvac.new_vaccinations,
Sum(cast(new_vaccinations as float)) over (partition by Cdea.country order by Cdea.country, Cdea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Cdea
Join PortfolioProject..CovidVaccinations Cvac
	On Cdea.country = Cvac.country
	And Cdea.date = Cvac.date
Where Cdea.continent Is Not Null
Order By 2,3,1

Select *, (RollingPeopleVaccinated/population)*100
From #PopVsVac

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Go   /*** Use Go after CTE and before create view to avoid error like create view must be the only statement in the batch or create view before cte of same name in start ***/

Create View PopVsVac as
Select Cdea.date, Cdea.continent, Cdea.country, population, Cvac.new_vaccinations,
Sum(cast(new_vaccinations as float)) over (partition by Cdea.country order by Cdea.country, Cdea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Cdea
Join PortfolioProject..CovidVaccinations Cvac
	On Cdea.country = Cvac.country
	And Cdea.date = Cvac.date
Where Cdea.continent Is Not Null
--Order By 2,3,1

Select *
From PopVsVac


