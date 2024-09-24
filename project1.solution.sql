use ipl;
select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_player;
select * from ipl_stadium;
select * from ipl_team;
select * from ipl_team_players;
select * from ipl_team_standings;
select * from ipl_tournament;
select * from ipl_user;

-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
select ibp.bidder_id ,ibp.no_of_bids,ibd1.bidder_name,
sum(case
when bid_status like "won" then 1
else 0
end ) as total_wins,
round(sum(case
when bid_status like "won" then 1
else 0
end )/100,2) as  percentage_wins
from ipl_user iu
join ipl_bidder_details ibd1
on iu.user_id=ibd1.user_id
join ipl_bidder_points ibp
join ipl_bidding_details ibd
on ibd.bidder_id=ibp.bidder_id
where bid_status like "%won%"
group by ibp.bidder_id,ibp.no_of_bids,ibd1.bidder_name
order by percentage_wins  desc;


-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.
select * from ipl_stadium;
select * from ipl_tournament;
select * from ipl_match_schedule;
select * from ipl_match;
select ist.stadium_id,ist.stadium_name,ist.city,count(im.match_id) as no_of_matches
from ipl_match im join ipl_match_schedule ims
on im.match_id=ims.match_id
join ipl_stadium ist
on ims.STADIUM_ID=ist.stadium_id
group by ist.stadium_id,ist.stadium_name,ist.city;

-- 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?
select * from ipl_match;
select * from ipl_stadium;
select * from ipl_team_standings;
select * from ipl_team;
select * from ipl_match_schedule;

select ist.stadium_id,ist.stadium_name,it.team_name,im.match_id,
round(sum(its.matches_won/its.matches_played)*100,2) as percentage_of_wins
from ipl_team it join ipl_team_standings its
on it.team_id=its.team_id
join ipl_match im join ipl_match_schedule ims
on im.match_id=ims.match_id
cross join ipl_stadium ist

where toss_winner=match_winner and status="completed"
group by ist.stadium_id,ist.stadium_name,it.team_name,im.match_id;


select stadium_id,stadium_name,sum(case 
when toss_winner=match_winner then 1
else 0
end) cwon,count(stadium_id) total_matches,
(sum(case 
when toss_winner=match_winner then 1
else 0
end)/count(stadium_id))*100  win_percentage
from ipl_match  join
ipl_match_schedule using(match_id)
join ipl_stadium using(stadium_id)
where status="completed"
group by stadium_id,stadium_name
order by stadium_id;

-- 4.	Show the total bids along with the bid team and team name.
select bid_team,sum(no_of_bids),team_name from ipl_bidder_points ibp
join ipl_bidding_details ibd on ibp.bidder_id=ibd.bidder_id join ipl_team  it on ibd.bid_team=it.team_id
group by bid_team,team_name
order by bid_team;

-- 5.	Show the team id who won the match as per the win details.
select team_id,team_name,win_details from ipl_match im 
join ipl_team it on im.TEAM_ID1=it.TEAM_ID 
where it.team_id=im.MATCH_WINNER
group by team_id,team_name,WIN_DETAILS;

-- 6.	Display total matches played, total matches won and total matches lost by the team along with its team name.

select its.TOURNMT_ID,it.team_id,it.team_name,its.matches_played,its.matches_won,its.matches_lost
from ipl_team_standings its join ipl_team it
on its.team_id=it.team_id
order by its.tournmt_id;

-- 7.	Display the bowlers for the Mumbai Indians team.
select ip.player_name,itp.player_id,team_name,player_role from ipl_team_players itp join ipl_team it
on itp.team_id=it.team_id join ipl_player ip 
on itp.player_id= ip.player_id
where player_role ="Bowler" and it.team_id=5;

-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 
select itp.team_id,it.team_name,player_role,count(*) as cnt_of_ar
from ipl_team_players itp join ipl_team it 
on itp.team_id=it.team_id
where itp.player_role="all-rounder"
group by itp.team_id;

-- having cnt>4 
select itp.team_id,it.team_name,player_role,count(*) as cnt_of_ar
from ipl_team_players itp join ipl_team it 
on itp.team_id=it.team_id
where itp.player_role="all-rounder"
group by itp.team_id
having cnt_of_ar>4;

-- 9.Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
-- Note the total bidders’ points in descending order and the year is bidding year.
-- Display columns: bidding status, bid date as year, total bidder’s points

select ibp.bidder_id,bid_team,sum(total_points) as bidder_points,bid_status,stadium_id,year(bid_date)
from ipl_bidder_points ibp join ipl_bidding_details ibd
on ibp.bidder_id=ibd.bidder_id
join ipl_match im join ipl_match_schedule ims 
on im.match_id=ims.match_id
where bid_team=1 and bid_status="won" and STADIUM_ID=7
group by ibp.bidder_id,bid_status,year(bid_date)
order by bidder_points desc;

-- 10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
-- Note 
-- 1. use the performance_dtls column from ipl_player to get the total number of wickets
-- 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3.	Do not use joins in any cases.
-- 4.	Display the following columns teamn_name, player_name, and player_role.

select * from ipl_player;
-- select substring(performance_dtls,locate("-",performance_dtls,),3) as tot_wickets from ipl_player;
select substr(performance_dtls,20,7) as wkts from ipl_player;



-- 11.show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
select ims.match_id,bidder_id,ibd.schedule_id,sum(
case 
when bid_team=toss_winner then 1
else 0
end ) as total_toss_wins,
round(sum(
case 
when bid_team=toss_winner then 1
else 0
end/100),2) as percentage_wins
from ipl_bidding_details ibd join ipl_match_schedule ims
on ibd.schedule_id=ims.schedule_id
join ipl_match im on ims.match_id=im.match_id
group by  ims.match_id,bidder_id,ibd.schedule_id
order by percentage_wins desc;

-- 12.	find the IPL season which has min duration and max duration.
-- Output columns should be like the below:
-- Tournment_ID, Tourment_name, Duration column, Duration
with dur1 as
(with dur as
(select tournmt_id,tournmt_name,concat(From_date," to ",to_date) as duration_column,datediff(to_date,from_date) duration
from ipl_tournament
order by duration desc)
select *,dense_rank()over(order by duration desc) as rank_pos
from dur)
select * from dur1
where rank_pos in (1,5);
-- ( by applying where clause to fetch min and max rank, we get min as 2012 season, max as 2019 season )

-- 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. 
-- sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
-- Only use joins for the above query queries.
with top as
(select ibd.bidder_id,bidder_name,year(bid_date) as Year1,month(bid_date) as month1,sum(total_points) as tot_bid_points
from ipl_bidder_details ibd join ipl_bidding_details ibd1
on ibd.bidder_id=ibd1.bidder_id  
join ipl_bidder_points ibp 
on ibd1.BIDDER_ID=ibp.BIDDER_ID
where year(bid_date)=2017
group by ibd.bidder_id,bidder_name,year(BID_DATE),month(BID_DATE))
select * from top
order by tot_bid_points desc,month1 asc;
-- limit 3;

-- 14.	Write a query for the above question using sub queries by having the same constraints as the above question.

select bidder_id,bidder_name from ipl_bidder_details where BIDDER_ID in
(select year(bid_date) as Year1,month(bid_date) as month1 from ipl_bidding_details where BIDDER_ID in
(select bidder_id from ipl_bidder_points));

-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be:like:
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;

create view top3_bottom3 as
(select ibd.bidder_id,bidder_name,sum(total_points) as tot_bid_points from ipl_bidder_details ibd join ipl_bidding_details ibd1
on ibd.bidder_id=ibd1.bidder_id  join ipl_bidder_points ibp on ibd1.BIDDER_ID=ibp.BIDDER_ID
where year(bid_date)=2018
group by ibd.bidder_id,bidder_name);
(select *, dense_rank()over(order by tot_bid_points) as rank_pos from top3_bottom3
order by tot_bid_points desc
limit 3)
union 
(select *, dense_rank()over(order by tot_bid_points) as rank_pos from top3_bottom3
order by tot_bid_points asc
limit 3);


-











