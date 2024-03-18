CREATE DATABASE PROJECT3;
USE PROJECT3;

#TABLE 1 - users
#user_id	created_at	company_id	language	activated_at	state

CREATE TABLE USERS
(USER_ID INT,
created_at varchar(100),
COMPANY_ID INT,
LANGUAGE VARCHAR(50),
ACTIVATED_AT VARCHAR(100),
STATE VARCHAR(50));

SHOW VARIABLES LIKE 'SECURE_FILE_PRIV';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.CSV"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES terminated by '\n'
ignore 1 ROWS;

SELECT * FROM USERS;

set SQL_safe_updates = 0;


ALTER table users
add column temp_created_at datetime;
update users set temp_created_at = str_to_date(created_at, '%d-%m-%Y %H:%i' ) ;

ALTER table users
add column temp_activated_at datetime;
Update users set temp_activated_at = str_to_date(activated_at, '%d-%m-%Y %H:%i');

ALTER table users
drop column created_at;
ALTER table users
drop column activated_at;

alter table users
change column temp_created_at created_at datetime;
alter table users
change column temp_activated_at activated_at datetime;


#table 2 events

create table events
	(
     user_id int,
	 occured_at varchar(100),
     event_type varchar(50),
     event_name varchar(100),
     location varchar(50),
     device varchar(50),
     user_type int
     );
     
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.CSV"
INTO TABLE events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES terminated by '\n'
IGNORE 1 ROWS;

select * from events;

set SQL_safe_updates = 0;

alter table events
add column temp_occured_at datetime;

update events
set temp_occured_at = STR_TO_DATE(occured_at, '%d-%m-%Y %H:%i');

alter table events
drop column occured_at;

alter table events
change column temp_occured_at occured_at datetime;


#table-3 email_events

create table email_events
(
	user_id int,
    occured_at varchar(100),
    action varchar(100),
    user_type int
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.CSV"
INTO TABLE email_events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES terminated by '\n'
IGNORE 1 ROWS;

select * from email_events;

set SQL_safe_updates = 0;

alter table email_events
add column temp_occured_at datetime;

update email_events
set temp_occured_at = STR_TO_DATE(occured_at, '%d-%m-%Y %H:%i');

alter table email_events
drop column occured_at;

alter table email_events
change column temp_occured_at occured_at datetime;






#A. weekly user engagement
#Select * from events;

select extract(week from occured_at), count(distinct(user_id))
from events
where event_type = "engagement"
group by extract(week from occured_at)
order by 1;


#B.User growth analysis
#select * from users;

with temp_users as
(
select year, month, active_users,  sum(active_users) over (order by year, month rows between unbounded preceding and current row) as cumulative_users
from
		(select extract(year from created_at) as year, extract(month from created_at)as month, count(user_id) as active_users
		from users
		group by year, month
		order by 1,2) a
)

select    year
        , month
        , cumulative_users, lag(cumulative_users, 1) over (order by year, month) as prev_cumulative_users
	    ,((cumulative_users-lag(cumulative_users, 1 ) over (order by year, month))/lag(cumulative_users, 1) over (order by year, month))*100 as user_growth
from temp_users;


#C. weekly retention analysis
#select * from events;

with
retention as
(
with
cte_signup as
(	
select distinct user_id, extract(week from occured_at) as signup_week
from events
where event_type = "signup_flow"
order by user_id
),

cte_engage as
(
select distinct user_id, extract(week from occured_at) as engagement_week
from events
where event_type = "engagement"
order by user_id
)

select s.user_id, s.signup_week, e.engagement_week, e.engagement_week-s.signup_week as retention_week
from cte_signup as s
left join cte_engage as e
on s.user_id = e.user_id
)

select count(distinct(user_id)) as weekly_retained_users
from retention
where retention_week > 1;

with
retention as
(
with
cte_signup as
(	
select events.user_id, extract(week from occured_at) as signup_week
from events
where event_type = "signup_flow"
order by events.user_id
),

cte_engage as
(
select distinct events.user_id, extract(week from occured_at) as engagement_week
from events
where event_type = "engagement"
order by events.user_id
)

select s.user_id, s.signup_week, e.engagement_week, e.engagement_week-s.signup_week as retention_week
from cte_signup as s
left join cte_engage as e
on s.user_id = e.user_id
)

select count(distinct(user_id)) as not_weekly_retained
from retention
where retention_week = 0;


#D. weekly engagement per device
#select * from events;

select extract(week from occured_at) as "week", device, count(distinct(user_id)) as total_users
from events
where event_type = "engagement"
group by 1,2
order by 1;


#E. email engagement analysis
# we have consider only weekly digest mails as total sent mail and considered the reengagement mails in total % calculation

select 
((select count(user_id) from email_events where action = "email_open")  /
 (select count(user_id) from email_events where action = "sent_weekly_digest") )* 100 
 as "percentage of email opened";
                                       
select 
((select count(user_id) from email_events where action = "email_clickthrough")  /
 (select count(user_id) from email_events where action = "sent_weekly_digest")) * 100 
 as "percentage of email clicked";
 
