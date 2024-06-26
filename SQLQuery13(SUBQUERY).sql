 

 --TOPIC SUBQUERIES (IN THE SELECT, FROM, AND WHERE STATEMENT)

 SELECT *
 FROM Employeesalary


 --SUBQUERY IN SELECT

 SELECT EMPLOYEEID, SALARY, (SELECT AVG(SALARY) FROM Employeesalary) AS ALLAVGSALARY
FROM Employeesalary

--HOW TO DO IT WITH PARTITION BY (IF YOU DONT WRITE ANYTHING AFTER OVER FUNCTION, BY DEFAULT IT WILL )

 SELECT EMPLOYEEID, JOBTITLE, SALARY, AVG(SALARY) OVER () AS ALLAVGSALARY
FROM Employeesalary

--WHY DOESN'T WORK WITH GROUP BY

 SELECT EMPLOYEEID, SALARY, AVG(SALARY) AS ALLAVGSALARY
FROM Employeesalary
GROUP BY EMPLOYEEID, SALARY
ORDER BY 1,2

--SUBQUERY IN FORM

SELECT A.EMPLOYEEID, A.ALLAVGSALARY
FROM (SELECT EMPLOYEEID, SALARY, AVG(SALARY) OVER () AS ALLAVGSALARY
		FROM Employeesalary) A

--SUBQUERY IN WHERE (USE WHEN WE WANT TO FILTER OUT SOME PARAMETER BUT THAT DATA FILTER BASED ON ANOTHER TABLE
--HERE WE WANT AGE > 30 IN EMPLOYEESALARY TABLE BUT THIS ATBLE DOESN'T CONTAIN AGE COLUMN
--SO WE FILTER WITH SUBQUERY FROM DEMOGRAPHICS TABLE)

SELECT EMPLOYEEID, JOBTITLE, SALARY
FROM EMPLOYEESALARY
WHERE EMPLOYEEID IN (
						SELECT EMPLOYEEID
						FROM EMPLOYEEDEMOGRAPHICS
						WHERE AGE > 30)