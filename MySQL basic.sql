create database Shubham;
CREATE DATABASE IF NOT EXISTS SHUBHAM;
use shubham;
SHOW databases;

#--TO DELETE THE DATABASE
DROP database SHUBHAM; 

#primary key not allow duplicate or null entries

CREATE DATABASE SHUBHAM;
USE SHUBHAM;

CREATE TABLE IF NOT EXISTS `STUDENT DATA`
(  
Roll_No bigint PRIMARY KEY,
`Name` varchar(20),
Age int,
Gender char(1),
Hobbies varchar(50)
);



use companydb;
select * from works_on;

#truncate used to delete all the data within the table but not delete the table
truncate works_on;

use shubham;

select * from project;

#adding column after/before particular column
alter table `student data`
add column hometown varchar(10) after age;

alter table `student data`
add column (
			emergency_contact varchar(20),
            address varchar(30)
            );
            
#delete column
alter table `student data`
drop column hometown;


#modify column
alter table `student data`
modify address varchar(255);

#rename column
alter table `student data`
change column emergency_contact contact varchar(10);

#rename table
alter table `student data`
rename to student;






#wildcard operators with 'like'
#1. % - to select name starting or ending or between with specific character
#2. _ - ex. A___ it means name starts with A and have 3 characters after that

select fname, lname from employee where fname like 'J___';
select fname, address from employee where address like '%houston%';

#use of between and not and in function
select fname, ssn, salary from employee where salary between 20000 and 40000;
select pname, plocation from project where plocation not in ('houston','stafford');


#insert into 
#1. table name (column 1,2,3..) values------if you want to add in specific column and according to your order and not all column
#2.table name values------------if you are entering into all the columns


#update
set SQL_safe_updates = 0;

update employee
set super_ssn = '333445555'
where super_ssn is null; 

select * from employee;

#delete
delete
from employee
where super_ssn = '333445555';


#extract day/month/year/week from timestamp
#ex. in column 'createdate' 2021-12-25 01:59:11.137 
#day(createdate) = 25
#dayname(createdate) = wednesday
#daymonth(createdate) = 12

SELECT * FROM EMPLOYEE;
SELECT EXTRACT(YEAR FROM BDATE) AS YEAR_OF_BIRTH FROM EMPLOYEE;

SELECT EXTRACT(YEAR FROM BDATE) AS YEAR_OF_BIRTH, COUNT(*) FROM EMPLOYEE
GROUP BY YEAR_OF_BIRTH;

SELECT EXTRACT(MONTH FROM BDATE) AS MONTH_OF_BIRTH FROM EMPLOYEE;


use companydb;

#primary key
#1st column in each table
#cant have null and duplicate values
#in 1 table only 1 primary key
#ex. 2 ways to do that -------"ssn char(9) PRIMARY KEY"  or "constarint pk_employee PRIMARY KEY (ssn)"

#can be made unique by combining 2 column creating unique values
#ex  1 way to do that---------------"constraint pk_employee PRIMARY KEY (ssn, bdate, sex)" 


#foreign key
#it is a column in one table that is a primary key in different table
#alter table works_on
#add
#constraint fk_essn FOREIGN KEY (essn) REFERENCES employee(ssn); fk in current table and essn column refering to ssn column in employee table


#aliases
#inner join - common row output
#left join - 
#right join -
#outer join - row in either table - in mysql outer join dont work but you can use this by union function
#self join - 

select * from employee;
select * from works_on;

#cross join - each row from 1 table to each row of other table like cartesian 
select * from department;
select * from project;

select *
from project
cross join department;

#inner join and filtering

select * from employee
inner join department
on employee.dno = department.dnumber and salary > 40000;


#count - returns how many non null values are there in column
# count(*) = total number of rows in their

use companydb;
select count(*) from employee;

select * from employee;
select count(super_ssn) from employee;


# FROM -> WHERE -> GROUP BY -> SELECT -> having -> ORDER BY

SELECT DNO, AVG(SALARY) AS AVG_SALARY
FROM EMPLOYEE WHERE AVG-SALARY > 32000
GROUP BY DNO;
# ABOVE CODE DIDN'T WORK BCZ WHERE CONDITION WILL BE EXECUTED AHEAD OF GROUP BY, W/O GROUP BY YOU CANT CREATE AVG SALARY PER DEPARTENT NO

#HAVING 
SELECT DNO, AVG(SALARY) AS AVG_SALARY
FROM EMPLOYEE 
GROUP BY DNO
HAVING AVG_SALARY > 32000;

#CASE 
select ssn, salary,
case 
	when salary < 35125 then "less"
    when salary = 35125 then "equal"
    else "more"
end as pay_scale
from employee;


#nested subquery

#print details of all the managers from the employee table
#1st run inner query to find out who the managers are then will find its details
#subqury generate column

select ssn, fname, dno
from employee
where ssn in 
		(
        select distinct super_ssn from employee
        );
        
select * from employee;

#print details of employees who are working on a project
#1st find who is working on project then find its details


select ssn, fname, lname
from employee
where ssn in
	(
	select distinct essn from works_on
	where essn is not null
    );
    
    
    
#inline subquery

#print max and min avg salary across all department
#1st we have to find avg salary of each dept, then we will find mx and min among them
#here we use direct column name that we have created in subquery, here subquery works as table and using from--we are drawing data from that table
#subquery generate table

select min(avg_salary), max(avg_salary)
from (
	select dno, avg(salary) as Avg_salary
	from employee
	group by dno
    ) as dept_avg;
    
    
#scalar query

#print all employee who are earning more than the avg salary across all employee 
#1st find the avg salary of all employee then with outer query find employee who has more than that 
#subqury generate scalar value

select ssn, fname, salary
from employee
where salary > (
				select avg(salary) as avg_salary from employee
                );
                
#cte ---when query


#print name, dept, and total hours that each has worked
#1st calculate total hours single employee work

with 
employee_hours as (
	select essn, sum(hours) as total_hours
	from works_on
	group by essn
    )
 
SELECT 
    ssn, fname, dno, total_hours
FROM
    employee
        INNER JOIN
    employee_hours ON employee.ssn = employee_hours.essn;
    
    
    
#after with you can create more than 1 cte(common table expression)
#print name, dept, and total hours that each has worked and total project that each employee had done  
  
with 
employee_hours as (
	select essn, sum(hours) as total_hours
	from works_on
	group by essn
    ),
    
    employee_project as (
	select essn, count(pno) as total_project
    from works_on
    group by essn
    )
    
select ssn, fname, dno, total_project, total_hours
from employee_project
inner join (
		select ssn, fname, dno, total_hours
		from employee
		inner join employee_hours
		on employee.ssn = employee_hours.essn
		  ) as inner_query
	on employee_project.essn = inner_query.ssn;
    
    
#corelated subquery

#Print all employees which are earning more than their department average
#inner query is using dno column 
#1st row will be taken and then it will take its dno then it will avg the salary of all the employee w/ same dno and give result to salary > avg dept 
#it is one type of scalar query but w/ corelation


Select ssn, fname, salary, dno
from employee as outer_table
where salary > (
				select avg(salary)
                from employee
                where dno = outer_table.dno
                group by dno
                );
#to do this w/o corelation , we have done it in view ex.


#returning those super-ssn id who are employee it self---finding managers and they are employee itself   
#inner query we will find those ssn id which exists in super_ssn id as well and that means they are managers
#where exists function will be true if it will return non-null value(thats why random'x' will be count as nonnull), and false if return null values             

Select ssn, fname, lname, dno, super_ssn
from employee as outer_table
where exists (
				select 'x' from employee
                where ssn = outer_table.super_ssn
			);
    

#view
#use when you want to run multiple query on the data set that was output of inner query
#for multiple query either you can use with cte, every time
#view will remain in memory till the session

create view 
male_emp_view as (
					select *
                    from employee
                    where sex = 'M'
				);
                
select avg(salary)
from male_emp_view;

select * 
from male_emp_view
inner join department
	on male_emp_view.dno = department.dnumber;
    
    
    
create view
dept_sal_avg as (
				select dno, avg(salary) as avg_sal
                from employee
                group by dno
                );
                
select *
from dept_sal_avg;

select * 
from employee
inner join dept_sal_avg
	on employee.dno = dept_sal_avg.dno
where employee.salary > dept_sal_avg.avg_sal;

#avoid updating view table bcz it might effect base table or might not
#always update base table and then create view from it

#optimize the last ex
#in above ex. 1st join both tables and then it will filter > avg_dept_sal
#in below ex while joining it will only join those rows which have > avg_dep_sal and save time 
select * 
from employee
inner join dept_sal_avg
	on employee.dno = dept_sal_avg.dno and employee.salary > dept_sal_avg.avg_sal;
    
    
    
#window function
#ex. cumulative sum of salary---row 5 include sum of salary from 1 to 5, row 10 include sum of salary of 1 to 10
#write query for cumulative salary ?????????????????????

select dno, avg(salary)
from employee
group by dno;

select dno, avg(salary) over (), sum(salary) over()
from employee;
#above query give single avg and sum value to all rows

select ssn, salary, sex, dno, avg(salary) over (partition by dno) as avg_sal, sum(salary) over (partition by sex) as sum_sal
from employee; 

select ssn, salary, sex, dno, avg(salary) over (partition by dno, sex)
from employee; 
                
select ssn, dno, sex, count(ssn) over(partition by dno, sex) as total_emp
from employee;



#ranking function
select ssn, salary, rank() over() as salary_rank
from employee;
select ssn, salary, rank() over(order by salary) as salary_rank
from employee; 
select ssn, salary, rank() over(order by salary desc) as salary_rank
from employee; 
    
select ssn, salary,sex,
	rank() over(order by salary desc) as salary_rank,
	rank() over(partition by sex order by salary desc) as _sex_sal_rank
from employee;     
    
#dense rank    
select ssn, salary,sex,
	dense_rank() over(order by salary) as salary_rank
from employee;   
 
select ssn, salary,sex,
	dense_rank() over(partition by sex order by salary) as salary_rank
from employee;  


#row function
select ssn, salary, sex,
	row_number() over() as row_num
from employee;

select ssn, salary, sex,
	row_number() over(partition by sex order by salary) as row_num
from employee;



 
 #alias
 
 #column alias
 
 select ssn, concat(fname,' ', lname)
 from employee;
 select ssn, concat(fname,' ', lname) as full_name
 from employee;
  select ssn, concat(fname,' ', lname) as full_name, avg(salary) over (partition by dno) as avg_sal
 from employee;
 
 
 #lag function
 #returns the value from a previous row to current row in the table, lag2 will return value from last to last row in current row
 
 select
		ssn, fname, salary, 
		lag(salary, 1) over(order by salary) as Prev_salary
from employee;
 
  select
		ssn, fname, salary, 
		lag(salary, 1,0) over(order by salary) as Prev_salary
from employee;

  select
		ssn, fname, salary, dno,
		lag(salary, 1,0) over(order by salary) as Prev_salary,
        lag(salary, 1,0) over(partition by dno order by salary) as dept_Prev_sal
from employee;

#salary increment w.r.t. previous employee salary
select ssn, fname,
		salary - lag(salary, 1) over(order by salary) as diff_sal
from employee;



#lead
#opposite of lag function- look forward row
select ssn, fname,
		salary - lead(salary, 1) over(order by salary desc) as diff_sal
from employee;


#percentile
#it means how many rows have less than or equal to value of particular row we are looking

select ssn, salary
		,round(percent_rank() over(order by salary),2)	as perc_sal
from employee;

select ssn, salary,sex
		,round(percent_rank() over(partition by sex order by salary),2)	as perc_sal
from employee;




#string

select left("HR-001", 2) as dept_id;

select address, left(address, 4) as temp
from employee;
select address, right(address, 2) as temp
from employee;

select address, substr(address, 2,5) as substring, substr(address from 2 for 5)
from employee;

#concate
select fname, lname, concat(fname, lname) as full_name
from employee;
select fname, lname, concat(fname,' ', lname) as full_name
from employee;


#cast
#used to change the datatype of values
select cast('1965-01-10' as date);


#position
#find 1st ocuurance position of particular value
select address, position('houston' in address) as h_pos
from employee;

#coalesce 
#extract 1st non null value from the list of values

select coalesce(null, null, 123, 'jekdf') as c_1;



#non equi join

#list all pair of employees who have the same department
select left_table.ssn, right_table.ssn, left_table.dno, right_table.dno
from employee left_table
join employee right_table
	on left_table.dno = right_table.dno and left_table.ssn <> right_table.ssn;

#above query duplicate the pair ex. pair 1- emp1,emp2 and pair 2- emp2,emp1 -----both are same pair

select left_table.ssn, right_table.ssn, left_table.dno, right_table.dno
from employee left_table
join employee right_table
	on left_table.dno = right_table.dno and left_table.ssn < right_table.ssn;
    
    
    
#print employee and supervisor name 
#from employee table we can get ssn and corresponding super_ssn, but to get the name of manager(who himself an employee) we have to use join

select concat(left_table.fname,' ', left_table.lname) as emp_name,
		concat(right_table.fname,' ', right_table.lname) as sup_name
from employee left_table
left join employee right_table
	on left_table.super_ssn = right_table.ssn;
    
    
#union
#join data set by combining row instead of column(for column we use join)

select dno, sex, avg(salary)
from employee
where sex = 'M'
group by dno

union

select dno, sex, avg(salary)
from employee
where sex = 'F'
group by dno;


#full outer join
#using union between left join and right join to get full outer join
#union will remove duplicates, union all will retain that

select * 
from employee
left join department
	on employee.dno = department.dnumber
    
union

select * 
from employee
right join department
	on employee.dno = department.dnumber;
    
    
    
explain select * 
from employee
left join department
	on employee.dno = department.dnumber
    
union

select * 
from employee
right join department
	on employee.dno = department.dnumber;


    





