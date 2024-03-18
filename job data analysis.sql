
USE PROJECT3;

select * from job_data;

#A. Jobs Reviewed Over Time
Select ds, sum(time_spent)/3600 as "jobs reviewed per hour"
from job_data
group by ds
order by ds;

#B. Throughput Analysis:
with totaltimespent as
(
Select ds, sum(time_spent) as daywise_spent
from job_data
group by ds
order by ds
)

select ds, daywise_spent, avg(daywise_spent) over(order by ds rows between 6 preceding and current row) as "7-days rolling avg"
from totaltimespent;

#C. Language Share Analysis
Create view L_count as
(
select language, count(language) as a
from job_data
group by language
);

select language, round(a/(select sum(a) from L_count)*100,2) as "Percentage Share of language"
from L_count;


#D. Duplicate Rows Detection

select job_id, count(job_id),
		actor_id, count(actor_id),
		org, count(org),
        language, count(language)
from job_data
group by job_id, actor_id, org, language
having  count(job_id)>1 and count(actor_id)>1 and  count(org)>1 and count(language)>1;



