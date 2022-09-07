USE employees_mod;

#Active Manager Per Year for Each Departments and Gender
SELECT 
    d.dept_name,
    e.gender,
    m.emp_no,
    m.from_date,
    m.to_date,
    k.calendar_year,
    CASE
        WHEN
            YEAR(m.from_date) <= k.calendar_year
                AND k.calendar_year <= YEAR(m.to_date)
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) AS k
        CROSS JOIN
    t_dept_manager AS m
        JOIN
    t_departments AS d ON d.dept_no = m.dept_no
        JOIN
    t_employees AS e ON m.emp_no = e.emp_no
ORDER BY emp_no , calendar_year;

#Average Wage Every Year for Each Gender
SELECT 
    d.dept_name,
    e.gender,
    ROUND(AVG(s.salary)),
    YEAR(s.from_date) AS calendar_year
FROM
    t_departments AS d
        JOIN
    t_dept_emp AS de ON d.dept_no = de.dept_no
        JOIN
    t_employees AS e ON de.emp_no = e.emp_no
        JOIN
    t_salaries AS s ON e.emp_no = s.emp_no
GROUP BY d.dept_name , calendar_year , e.gender
HAVING calendar_year <= 2002
ORDER BY d.dept_name;

#Male Employment Rate Growth
SELECT 
    q.calendar_year,
    q.increase_in_male_employees,
    w.running_total_male_employees,
    CONCAT(100 * (w.running_total_male_employees - LAG(w.running_total_male_employees,1) OVER (ORDER BY calendar_year)) / LAG(w.running_total_male_employees,1) OVER (ORDER BY calendar_year),'%') AS growth
FROM
	(SELECT 
		YEAR(from_date) AS calendar_year,
		e.gender,
		COUNT(d.emp_no) as increase_in_male_employees
	FROM
		t_dept_emp as d
			JOIN
		t_employees as e ON d.emp_no = e.emp_no
	WHERE
		e.gender = 'M'
	GROUP BY YEAR(from_date) , gender
	HAVING calendar_year >= 1990
	ORDER BY YEAR(from_date) ASC) as q
		JOIN
	(SELECT 
		YEAR(from_date) AS calendar_year,
		SUM(COUNT(t_dept_emp.emp_no)) OVER (ORDER BY YEAR(from_date)) AS running_total_male_employees
	FROM
		t_dept_emp
			JOIN
		t_employees ON t_dept_emp.emp_no = t_employees.emp_no
	WHERE
		t_employees.gender = 'M' and YEAR(from_date) >= 1990
	GROUP BY YEAR(from_date)
	ORDER BY YEAR(from_date) ASC) as w ON q.calendar_year = w.calendar_year

#Female Employment Rate Growth
SELECT 
    q.calendar_year,
    q.increase_in_male_employees,
    w.running_total_male_employees,
    CONCAT(100 * (w.running_total_male_employees - LAG(w.running_total_male_employees,1) OVER (ORDER BY calendar_year)) / LAG(w.running_total_male_employees,1) OVER (ORDER BY calendar_year),'%') AS growth
FROM
	(SELECT 
		YEAR(from_date) AS calendar_year,
		e.gender,
		COUNT(d.emp_no) as increase_in_male_employees
	FROM
		t_dept_emp as d
			JOIN
		t_employees as e ON d.emp_no = e.emp_no
	WHERE
		e.gender = 'M'
	GROUP BY YEAR(from_date) , gender
	HAVING calendar_year >= 1990
	ORDER BY YEAR(from_date) ASC) as q
		JOIN
	(SELECT 
		YEAR(from_date) AS calendar_year,
		SUM(COUNT(t_dept_emp.emp_no)) OVER (ORDER BY YEAR(from_date)) AS running_total_male_employees
	FROM
		t_dept_emp
			JOIN
		t_employees ON t_dept_emp.emp_no = t_employees.emp_no
	WHERE
		t_employees.gender = 'F' and YEAR(from_date) >= 1990
	GROUP BY YEAR(from_date)
	ORDER BY YEAR(from_date) ASC) as w ON q.calendar_year = w.calendar_year
    
#Total Employees by Age
SELECT 
	o.age, COUNT(e.emp_no)
FROM
    (SELECT 
        emp_no, 2002 - YEAR(birth_date) AS age
    FROM
        t_employees) AS o
        JOIN
    t_employees AS e ON e.emp_no = o.emp_no
        JOIN
    t_dept_emp AS de ON e.emp_no = de.emp_no
        JOIN
    t_departments AS d ON de.dept_no = d.dept_no
GROUP BY o.age
ORDER BY o.age;