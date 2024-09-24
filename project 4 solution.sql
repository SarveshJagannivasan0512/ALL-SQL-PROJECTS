create database test_match;
use test_match;
select * from icc_test_batting_figures;		
-- 2.	Remove the column 'Player Profile' from the table.
alter table icc_test_batting_figures drop column `Player Profile`;
-- 3.	Extract the country name and player names from the given data and store it in separate columns for further usage.
alter table icc_test_batting_figures add column Player_name varchar(50);
update icc_test_batting_figures set Player_name=substring_index(Player,'(',1);

alter table icc_test_batting_figures add column Country_name varchar(20);
update icc_test_batting_figures set Country_name=replace(replace(substring(Player,locate('(',player),length(player)), "(",""),")", "");

-- 4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.

alter table icc_test_batting_figures add column Start_year text(30);
alter table icc_test_batting_figures add column End_year text(30);
update icc_test_batting_figures set Start_year=substr(Span,1,4);
update icc_test_batting_figures set end_year=substr(Span,6,9);

-- 5.	The column 'HS' has the highest score scored by the player so far in any given match. The column also has details if the player had completed the match in a NOT OUT status. Extract the data and store the highest runs and the NOT OUT status in different columns.
alter table icc_test_batting_figures add column Not_outs text(30);
update icc_test_batting_figures set Not_outs=if(instr(HS,"*")=0,"No","Yes");
alter table icc_test_batting_figures add column highest_score text(30);
update icc_test_batting_figures set highest_score=replace(HS,"*","");

-- 6.	Using the data given, considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for India.

select Player,avg,end_year from icc_test_batting_figures
where end_year>="2019" and Country_name="INDIA"
order by avg desc
limit 6;

-- Select * 
-- from (
-- Select * , Dense_Rank() over (order by Avg Desc) as Good_Avg_Rank
-- from icc_test_batting_figures
-- where Country_name='INDIA'
-- and  end_year >= 2019
-- )a
-- where Good_Avg_Rank<=6;

-- 7.	Using the data given, considering the players who were active in the year of 2019,
--  create a set of batting order of best 6 players using the selection criteria of those who have the highest number of 100s across all matches for India.

select * from
( select player, dense_rank()over(order by `100` desc) as tot_hundreds
from icc_test_batting_figures
where country_name="India") t
where tot_hundreds<=6;

-- 8.	Using the data given, 
-- considering the players who were active in the year of 2019, create a set of batting order of best 6 players using 2 selection criteria of your own for India.
select Player,avg,`50`,runs from icc_test_batting_figures
where end_year>="2019" and Country_name="INDIA"
order by `50` desc ,runs desc
limit 6;

-- 9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for South Africa.
create view batting_order_goodavgscorers_sa as
(select * ,dense_rank()over(order by avg desc) as good_avg_score
from icc_test_batting_figures
where country_name="SA" and end_year>=2019);
select * from batting_order_goodavgscorers_sa where good_avg_score<=6;

-- 10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players using the selection criteria of those who have highest number of 100s across all matches for South Africa.

create view batting_order_highestcenturyscorers_sa as
(select * ,dense_rank()over(order by `100` desc) as most_hundreds
from icc_test_batting_figures
where country_name="sa" and end_year>=2019);
select * from batting_order_highestcenturyscorers_sa
where most_hundreds<=6;

-- 11.	Using the data given, Give the number of player_played for each country.
select country_name,count(Player) as count_of_players from icc_test_batting_figures
group by Country_name;

select country_name from icc_test_batting_figures
group by country_name;

-- 12.	Using the data given, Give the number of player_played for Asian and Non-Asian continent
select count(player) as cnt_of_players,
case
when country_name in ("INDIA","3PAK","AFG","INDIA/PAK","ICC/SL","BDESH","ZIM","ICC/PAK","PAK","SL","ICC/INDIA") then "ASIAN COUNTRY"
else "NON ASIAN COUNTRY"
end as country_tag
from icc_test_batting_figures
group by country_tag;


