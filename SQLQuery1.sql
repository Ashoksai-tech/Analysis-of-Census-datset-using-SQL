
use CovidProject
select*from dbo.census1
select*from dbo.census2

--to find number of rows
select count(*) from CovidProject..census1
select count(*) from CovidProject..census2


select*from census1
where state in ('Gujarat' , 'Bihar');



--population of india 
select sum(population) as totalpoulation from census2;



--avg growth
select state,AVG(growth)*100 as avg_growth from census1
group by state;



--avg sexratio per state
select state,round(AVG(sex_ratio),0) as avg_sex_ratio from census1
group by state
order by avg_sex_ratio desc;



--avg literacy rate
select state,round(AVG(Literacy),0) as avg_literacy_ratio from census1
group by state having (round(AVG(Literacy),0)>80)
order by avg_literacy_ratio desc;



--top 3 states highest growth ratio
select top 5 state,AVG(growth)*100 as avg_growth from census1
group by state
order by avg_growth desc 



--bottom 3 states with lowest ratio
select top 4 state,round(AVG(sex_ratio),0) as avg_sex_ratio from census1
group by state
order by avg_sex_ratio asc;



--select top 3 states

drop table if exists #topstates
create table #topstates(
state nvarchar(255),
topstates float 
)
insert into #topstates
select state,round(AVG(Literacy),0) as avg_literacy_ratio from census1
group by state 
order by avg_literacy_ratio desc



--select bottom 3 states 

drop table if exists #bottomstates;
create table #bottomstates(
state nvarchar(255),
bottomstates float 
)
insert into #bottomstates
select top 3 state,round(AVG(Literacy),0) as avg_literacy_ratio from census1
group by state 
order by avg_literacy_ratio asc


select*from
(select top 3*from #topstates order by topstates desc) a
union
select*from
(select top 3*from #bottomstates order by bottomstates asc) b;


--wild cards 
select distinct State from census1
where State like 'a%' or state like 'b%';
 
 --joining the both tables
 select c.district,c.state,round(c.population/(c.sex_ratio+1),0) as male,round((c.population*(c.sex_ratio))/(c.sex_ratio+1),0) as females from
 (
 select a.district,a.state,a.sex_ratio/1000 as sex_ratio,b.population from dbo.Census1 a
 inner join dbo.census2 b on
 a.district = b.district
 )c


 

-- literacy rate
--total literate people/population = literacy_rate
--total literate people = literacy_rate*population

select c.state,sum(literate_people) as tot_lit_population,sum(illeterate_people) as tot_ill_population from
(select d.district,d.state,round(d.literacy_ratio*d.population,0) as literate_people,round((1-d.literacy_ratio)*d.population,0) as illeterate_people from
(select a.district,a.state,a.literacy/100 as literacy_ratio,a.sex_ratio,b.population from dbo.Census1 a
inner join dbo.Census2 b on 
a.district = b.district)d)c
group by c.State
order by tot_lit_population desc


--population in previous census
--Prevoius_census+growth*previous_census = population
--previous_census = population/(1+growth)


select  g.total_area/g.previous_census_population as area_available_prev,g.total_area/g.current_census_population as area_available_curr from
(select q.*,r.total_area from
(select 1 as keyy,n.*from
(select sum(m.previous_census_population) as previous_census_population,sum(m.current_census_population) as current_census_population from (
select e.state,sum(e.previous_census_population) as previous_census_population,sum(e.current_census_population) as current_census_population from
(select d.state,round(d.population/(1+d.growth),0) as previous_census_population,d.population as current_census_population from
(select a.state,a.district,a.growth,b.population from dbo.census1 a
inner join dbo.Census2 b on 
a.District = b.district)d)e
group by e.state)m)n)q inner join (

select '1' as keyy,z.*from
(select sum(area_km2) as total_area from dbo.census2)z) r on q.keyy=r.keyy)g
 

 --window functions to display top 3 districts in a state with high literacy rate
 select n.*from
 (select district,State,literacy,rank() over (partition by State order by literacy desc) as rnk from dbo.Census1)n
 where n.rnk in (1,2,3)
 order by State