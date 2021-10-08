--1--
select match_id, player_name, team_name, count(bowler) as num_wickets from player, team, (
select match_id, bowler, team_bowling from wicket_taken join ball_by_ball 
using(match_id, over_id, ball_id, innings_no) 
where kind_out in (1, 2, 4, 6, 7, 8)) as t1
where bowler=player_id and team_bowling=team_id group by match_id, player_name, team_name having count(bowler) >= 5
order by num_wickets desc, player_name asc, team_name asc, match_id asc;

--2--
select * from (
select player_name, num_matches from (
select man_of_the_match as player_id, count(man_of_the_match) as num_matches from (
select match_id, man_of_the_match, mom_team from (
select match.match_id, match_winner, man_of_the_match, team_id as mom_team from match, player_match
where match.match_id=player_match.match_id and man_of_the_match=player_id ) as t1
where match_winner!=mom_team ) as t2
group by man_of_the_match ) as t3
join player using(player_id)
order by num_matches desc, player_name asc ) as t4
limit 3;

--3--
select player_name from (
select fielders as player_id, count(fielders) as num_catches from (
select match_id, kind_out, fielders, match_date from wicket_taken join match 
using(match_id) where kind_out=1 and date_part('year', match_date)=2012 ) as t1
group by fielders ) as t2
join player using(player_id)
order by num_catches desc, player_name asc
limit 1;

--4--
select season_year, player_name, num_matches from (
select season_year, player_id, num_matches from (
select season_id, season_year, purple_cap as player_id from season ) as t1
join (
select distinct on (season_id, player_id) season_id, player_id, count(match_id) as num_matches from 
player_match join match using(match_id)
group by season_id, player_id ) as t2
using (season_id, player_id) ) as t3
join player using(player_id)
order by season_year asc;

--5--
select distinct player_name from (
select match_id, player_id, runs_scored from (
select match_id, match_winner, player_id, runs_scored, team_id from (
select match_id, match_winner, striker as player_id, runs_scored from (
select match_id, striker, sum(runs_scored) as runs_scored from (
select match_id, over_id, ball_id, innings_no, striker, runs_scored from batsman_scored
join ball_by_ball using(match_id, over_id, ball_id, innings_no) where innings_no in (1,2) ) as t1
group by match_id, striker ) as t2
join match using(match_id) ) as t3
join player_match using(match_id, player_id)) as t4
where match_winner!=team_id and runs_scored>50 ) as t5
join player using(player_id)
order by player_name asc;

--6--
select season_year, team_name, rank from (
select season_year, team_name, num_players, row_number() over(partition by season_year order by num_players desc, team_name asc) as rank from (
select season_year, team_id, num_players from (
select distinct on (season_id, team_id) season_id, team_id, count(player_id) as num_players from (
select distinct on (season_id, team_id, player_id) season_id, team_id, player_id from (
select season_id, match_id, team_id, player_id from (
select match_id, player_id, team_id from player_match join player using(player_id) where batting_hand=1 and country_id!=1 ) as t1
join match using(match_id) ) as t2 ) as t3
group by season_id, team_id ) as t4 join season using(season_id) ) as t4
join team using(team_id) ) as t5
where rank <= 5;

--7--
select team_name from (
select match_id, match_winner as team_id from match where date_part('year', match_date)=2009 ) as t1
join team using(team_id)
group by team_name
order by count(team_name) desc, team_name asc;

--8--
select team_name, player_name, runs from (
select team_name, player_id, runs_scored as runs from (
select team_id, player_id, runs_scored from (
select distinct on (team_batting) team_batting as team_id, max(runs_scored) as runs_scored from (
select distinct on (team_batting, player_id) team_batting, player_id, sum(runs_scored) as runs_scored from (
select match_id, match_date, runs_scored, player_id, team_batting from (
select match_id, runs_scored, striker as player_id, team_batting from batsman_scored
join ball_by_ball using(match_id, over_id, ball_id, innings_no) where innings_no in (1,2) ) as t1
join match using(match_id)
where date_part('year', match_date)=2010 ) as t2
group by team_batting, player_id ) as t3
group by team_batting ) as t4
join (
select distinct on (team_batting, player_id) team_batting as team_id, player_id, sum(runs_scored) as runs_scored from (
select match_id, match_date, runs_scored, player_id, team_batting from (
select match_id, runs_scored, striker as player_id, team_batting from batsman_scored
join ball_by_ball using(match_id, over_id, ball_id, innings_no) where innings_no in (1,2) ) as t5
join match using(match_id)
where date_part('year', match_date)=2010 ) as t6
group by team_batting, player_id ) as t7
using(team_id, runs_scored) ) as t8
join team using(team_id) ) as t9
join player using(player_id)
order by team_name asc, player_name asc;

--9--
select team_1_name as team_name, team_name as opponent_team_name, num_sixes as number_of_sixes from (
select team_name as team_1_name, team_bowling as team_id, num_sixes from (
select match_id, season_id, innings_no, team_batting as team_id, team_bowling, count(runs_scored) as num_sixes from (
select match_id, innings_no, team_batting, team_bowling, runs_scored from ball_by_ball
join batsman_scored using(match_id, over_id, ball_id, innings_no) where runs_scored=6 ) as t1
join match using(match_id) where season_id=1
group by match_id, season_id, innings_no, team_batting, team_bowling ) as t2
join team using(team_id) ) as t3
join team using(team_id)
order by number_of_sixes desc, team_name asc
limit 3;

--10--
select bowling_category, player_name, round(batting_average, 2) as batting_average from (
select bowling_category, player_name, batting_average, row_number() over(partition by bowling_category order by batting_average desc, player_name asc) as rank from (
select bowling_category, player_name, num_wickets, batting_average from (
select bowling_skill as bowling_category, player_name, num_wickets from (
select bowling_id, player_name, num_wickets from (
select player_id, bowling_skill as bowling_id, num_wickets from (
select player_id, bowling_skill, num_wickets from (
select distinct on (player_id) player_id, count(kind_out) as num_wickets from (
select bowler as player_id, kind_out from wicket_taken join ball_by_ball
using(match_id, over_id, ball_id, innings_no) where innings_no in (1, 2) and kind_out in (1,2,4,6,7,8) ) as t2
group by player_id ) as t3
join player using(player_id) ) as t4, (
select avg(num_wickets) as bowling_average from (
select player_id, bowling_skill, num_wickets from (
select distinct on (player_id) player_id, count(kind_out) as num_wickets from (
select bowler as player_id, kind_out from wicket_taken join ball_by_ball
using(match_id, over_id, ball_id, innings_no) where innings_no in (1, 2) and kind_out in (1,2,4,6,7,8) ) as t2
group by player_id ) as t3
join player using(player_id) ) as t4 ) as t5 
where num_wickets>bowling_average ) as t6 join player using(player_id) ) as t7
join bowling_style using(bowling_id) ) as t8
join (
select player_name, batting_average from (
select player_id, (runs_scored/num_matches) as batting_average from (
select distinct on (player_id) player_id, sum(runs_scored) as runs_scored from (
select striker as player_id, runs_scored from ball_by_ball join batsman_scored
using(match_id, over_id, ball_id, innings_no) where innings_no in (1,2) ) as t1
group by player_id ) as t2
join (
select player_id, count(match_id) as num_matches from (
select distinct on (match_id, striker) match_id, striker as player_id from ball_by_ball
group by match_id, striker ) as t1 group by player_id ) as t3
using(player_id) ) as t4 join player using(player_id) ) as t9 using(player_name) ) as t10 ) as t11
where rank=1;

--11--
select season_year, player_name, num_wickets, runs from (
select season_year, player_id, num_wickets, runs_scored as runs from (
select season_id, t9.player_id as player_id, player.batting_hand, runs_scored, num_wickets, num_matches from (
select season_id, player_id, runs_scored, num_wickets, num_matches from (
select season_id, player_id, runs_scored, num_wickets from (
select distinct on (season_id, player_id) season_id, player_id, sum(runs_scored) as runs_scored from (
select season_id, player_id, runs_scored from (
select match_id, striker as player_id, runs_scored from ball_by_ball
join batsman_scored using(match_id, over_id, ball_id, innings_no) where innings_no in (1,2) ) as t1
join match using(match_id) ) as t2
group by season_id, player_id having sum(runs_scored)>=150 ) as t3
join (
select distinct on (season_id, player_id) season_id, player_id, count(kind_out) as num_wickets from (
select season_id, player_id, kind_out from (
select match_id, bowler as player_id, kind_out from wicket_taken join ball_by_ball
using(match_id, over_id, ball_id, innings_no) where kind_out in (1,2,4,6,7,8) ) as t4
join match using(match_id) ) as t5
group by season_id, player_id having count(kind_out)>=5 ) as t6
using(season_id, player_id) ) as t7
join (
select distinct on (season_id, player_id) season_id, player_id, count(match_id) as num_matches from player_match
join match using(match_id) group by season_id, player_id having count(match_id)>=10 ) as t8
using(season_id, player_id) ) as t9, player
where t9.player_id=player.player_id and player.batting_hand=1 ) as t10
join season using(season_id) ) as t11
join player using(player_id)
order by num_wickets desc, runs desc, player_name asc;

--12--
select match_id, player_name, team_name, num_wickets, season_year from (
select season_id, match_id, player_name, team_name, num_wickets from (
select match_id, player_name, team_name, count(bowler) as num_wickets from player, team, (
select match_id, bowler, team_bowling from wicket_taken join ball_by_ball 
using(match_id, over_id, ball_id, innings_no) 
where kind_out in (1, 2, 4, 6, 7, 8)) as t1
where bowler=player_id and team_bowling=team_id group by match_id, player_name, team_name having count(bowler) >= 5
order by num_wickets desc, player_name asc, team_name asc ) as t3
join match using(match_id) ) as t4
join season using(season_id)
order by num_wickets desc, player_name asc, match_id asc
limit 1;

--13--
select player_name from (
select distinct on (player_id) player_id, count(season_id) as num_seasons from (
select distinct on (season_id, player_id) season_id, player_id from (
select match_id, player_id, season_id from player_match
join match using(match_id) ) as t1 ) as t2
group by player_id ) as t3
join player using(player_id)
where num_seasons=9
order by player_name asc;

--14--
select season_year, match_id, team_name from (
select season_year, match_id, team_name, num_players, row_number() over (partition by season_year order by num_players desc, team_name asc, match_id asc) as rank from (
select season_id, match_id, team_name, num_players from (
select season_id, match_id, team_id, num_players from (
select season_id, t3.match_id as match_id, team_id, num_players from (
select match_id, team_id, count(player_id) as num_players from (
select match_id, team_id, player_id from (
select match_id, team_batting as team_id, striker as player_id, runs_scored from ball_by_ball
join batsman_scored using(match_id, over_id, ball_id, innings_no) ) as t1
group by match_id, team_id, player_id having sum(runs_scored)>=50 ) as t2
group by match_id, team_id ) as t3, match
where t3.match_id=match.match_id and t3.team_id=match.match_winner ) as t4 ) as t5
join team using(team_id) ) as t6 join season using(season_id) ) as t6
where rank<=3;

--15--
select season_year, top_batsman, max_runs, top_bowler, max_wickets from ( 
select season_id, top_batsman, max_runs, top_bowler, max_wickets from (
select season_id, top_batsman, max_runs from (
select season_id, top_batsman, max_runs, row_number() over (partition by season_id order by max_runs desc, top_batsman asc) as rank from (
select season_id, player_name as top_batsman, runs_scored as max_runs from (
select distinct on (season_id, batsman) season_id, batsman as player_id, sum(runs_scored) as runs_scored from (
select season_id, batsman, runs_scored from (
select match_id, striker as batsman, runs_scored from ball_by_ball join batsman_scored
using(match_id, over_id, ball_id, innings_no) where innings_no in (1, 2) ) as t1
join match using(match_id) ) as t2
group by season_id, batsman ) as t3
join player using(player_id) ) as t4 ) as t5
where rank=2 ) as t6
join (
select season_id, top_bowler, max_wickets from (
select season_id, top_bowler, max_wickets, row_number() over (partition by season_id order by max_wickets desc, top_bowler asc) as rank from (
select season_id, player_name as top_bowler, num_wickets as max_wickets from (
select distinct on (season_id, bowler) season_id, bowler as player_id, count(kind_out) as num_wickets from (
select season_id, bowler, kind_out from (
select match_id, bowler, kind_out from ball_by_ball join wicket_taken
using(match_id, over_id, ball_id, innings_no) where innings_no in (1, 2) and kind_out in (1, 2, 4, 6, 7, 8) ) as t7
join match using(match_id) ) as t8
group by season_id, bowler ) as t9 
join player using(player_id) ) as t10 ) as t11
where rank=2 ) as t12
using(season_id) ) as t13
join season using(season_id);

--16--
select match_winner_name as team_name from (
select match_id, team_1_name, team_2_name, match_winner_name from (
select match_id, team_1, team_1_name, team_2, team_2_name, match_winner, team_name as match_winner_name from (
select match_id, team_1, team_1_name, team_2, team_name as team_2_name, match_winner from (
select match_id, team_1, team_name as team_1_name, team_2, match_winner from (
select match_id, team_1, team_2, match_date, match_winner from match
where date_part('year', match_date)=2008 ) as t1, team
where team_1=team.team_id ) as t2, team
where team_2=team.team_id ) as t3, team
where match_winner=team.team_id ) as t4
where (team_1_name='Royal Challengers Bangalore' and match_winner_name!='Royal Challengers Bangalore') 
or (team_2_name='Royal Challengers Bangalore' and match_winner_name!='Royal Challengers Bangalore') ) as t5
group by match_winner_name
order by count(match_winner_name) desc, match_winner_name asc;

--17--
select distinct on (team_name) team_name, player_name, mom_times as count from (
select team_id, team_name, player_id, mom_times from (
select mom_team as team_id, mom_times, man_of_the_match as player_id from (
select distinct on (mom_team) mom_team, max(mom_times) as mom_times from (
select distinct on (mom_team, man_of_the_match) mom_team, man_of_the_match, count(mom_team) as mom_times from (
select match.match_id as match_id, team_1, team_2, man_of_the_match, team_id as mom_team from match, player_match
where match.match_id=player_match.match_id and man_of_the_match=player_id ) as t1
group by mom_team, man_of_the_match ) as t2
group by mom_team ) as t3
join (
select distinct on (mom_team, man_of_the_match) mom_team, man_of_the_match, count(mom_team) as mom_times from (
select match.match_id as match_id, team_1, team_2, man_of_the_match, team_id as mom_team from match, player_match
where match.match_id=player_match.match_id and man_of_the_match=player_id ) as t4
group by mom_team, man_of_the_match ) as t5
using(mom_team, mom_times) ) as t6
join team using(team_id) ) as t7
join player using(player_id)
order by team_name asc, player_name asc;

--18--
select player_name from (
select player_id, concede_times, num_teams from (
select distinct on (player_id) player_id, count(player_id) as concede_times from (
select over_id, bowler as player_id, runs_conceded from (
select distinct on (match_id, over_id, bowler) over_id, bowler, sum(runs_scored) as runs_conceded from (
select match_id, over_id, ball_id, innings_no, runs_scored, bowler from batsman_scored
join ball_by_ball using(match_id, over_id, ball_id, innings_no) where innings_no in (1,2)) as t3
group by match_id, over_id, bowler ) as t4
where runs_conceded>20 ) as t5
group by player_id ) as t6
join (
select distinct on (player_id) player_id, count(team_id) as num_teams from (
select distinct player_id, team_id from player_match ) as t7
group by player_id ) as t8
using(player_id) where num_teams>=3 ) as t9
join player using(player_id)
order by concede_times desc, player_name asc
limit 5;

--19--
select team_name, avg_runs from (
select team_id, round(runs_scored/num_matches, 2) as avg_runs from(
select team_batting as team_id, sum(runs_scored) as runs_scored from (
select match_id, match_date, over_id, ball_id, innings_no, team_batting, runs_scored from (
select match_id, match_date, over_id, ball_id, innings_no, team_batting from ball_by_ball
join match using(match_id) where date_part('year', match_date)=2010 ) as t1
join batsman_scored using(match_id, over_id, ball_id, innings_no) where innings_no in (1,2) ) as t2
group by team_batting ) as t3
join (
select team_id, count(team_id) as num_matches from (
select distinct match_id, team_id from (
select match_id, team_id, match_date from player_match
join match using(match_id) ) as t4
where date_part('year', match_date)=2010 ) as t5
group by team_id ) as t6
using(team_id) ) as t7
join team using(team_id)
order by team_name asc;

--20--
select player_name as player_names from (
select player_out as player_id from wicket_taken
where over_id=1 ) as t1
join player using(player_id)
group by player_name
order by count(player_id) desc, player_name asc
limit 10;

--21--
select match_id, team_1_name, team_2_name, team_name as match_winner_name, number_of_boundaries from (
select match_id, team_1_name, team_name as team_2_name, match_winner as team_id, number_of_boundaries from (
select match_id, team_name as team_1_name, team_2 as team_id, match_winner, number_of_boundaries from (
select match_id, match.team_1 as team_id, match.team_2, match.match_winner, number_of_boundaries from match join (
select distinct on (match_id, team_1, team_2, match_winner) match_id, team_1, team_2, match_winner, count(runs_scored) as number_of_boundaries from (
select match_id, t1.team_1, t1.team_2, match_winner, runs_scored from (
select match_id, team_batting as team_1, team_bowling as team_2, runs_scored from ball_by_ball
join batsman_scored using(match_id, over_id, ball_id, innings_no) where innings_no=2 and runs_scored in (4, 6) ) as t1
join match using(match_id) where match_winner=t1.team_1) as t2
group by match_id, team_1, team_2, match_winner ) as t3 using(match_id) ) as t4
join team using(team_id) ) as t5
join team using(team_id) ) as t6
join team using(team_id)
order by number_of_boundaries asc, match_winner_name asc, team_1_name asc, team_2_name asc
limit 3;

--22--
select country_name from (
select player_id, player_name, country_id, avg_runs_conceded from (
select player_id, (runs_conceded/num_wickets) as avg_runs_conceded from (
select player_id, num_wickets, runs_conceded from (
select distinct on (player_id) player_id, count(kind_out) as num_wickets from (
select player_id, kind_out from (
select bowler as player_id, kind_out from ball_by_ball join wicket_taken
using(match_id, over_id, ball_id, innings_no) ) as t1
where kind_out in (1,2,4,6,7,8) ) as t2
group by player_id ) as t3
join (
select distinct on (player_id) player_id, sum(runs_scored) as runs_conceded from (
select bowler as player_id, runs_scored from ball_by_ball join batsman_scored
using(match_id, over_id, ball_id, innings_no) ) as t4
group by player_id ) as t4
using(player_id) ) as t5 ) as t6
join player using(player_id) ) as t7
join country using(country_id)
order by avg_runs_conceded asc, player_name asc
limit 3;