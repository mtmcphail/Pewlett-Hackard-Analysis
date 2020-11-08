-- Challenge Queries
-- DELIVERABLE 1
-- 1. Retrieve the emp_no, first_name, and last_name columns from the Employees table.
-- 2. Retrieve the title, from_date, and to_date columns from the Titles table.
-- 3. Create a new table using the INTO clause.
-- 4. Join both tables on the primary key.
-- 5. Filter the data on the birth_date column to retrieve the employees who were born between 1952 and 1955. Then, order by the employee number.
-- 6. Export the Retirement Titles table from the previous step as retirement_titles.csv and save it to your Data folder in the Pewlett-Hackard-Analysis folder.

SELECT e.emp_no, 
	e.first_name, 
	e.last_name,
	tl.title,
	tl.from_date,
	tl.to_date
INTO retirement_titles
FROM employees as e
LEFT JOIN titles as tl
ON e.emp_no = tl.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no;

-- Use Dictinct with Orderby to remove duplicate rows
-- Retrieve the employee number, first and last name, and title columns from the Retirement Titles table.
-- Use the DISTINCT ON statement to retrieve the first occurrence of the employee number for each set of rows defined by the ON () clause.

SELECT DISTINCT ON (emp_no) emp_no,
	first_name,
	last_name,
	title,
	to_date
INTO unique_titles
FROM retirement_titles
ORDER BY emp_no, to_date DESC;

-- A query to retrieve the number of employees by their most recent job title who are about to retire.
-- First, retrieve the number of titles from the Unique Titles table.

-- Lists out the titles included in unique_titles
SELECT DISTINCT ON (title) title
FROM unique_titles
ORDER BY title;

-- Counts the number of different titles included in unique_titles (7)
SELECT COUNT(DISTINCT title)
FROM unique_titles;

-- Then, create a Retiring Titles table to hold the required information.
-- Group the table by title, then sort the count column in descending order.
SELECT COUNT(emp_no), title
INTO retiring_titles
FROM unique_titles
--WHERE to_date = '9999-01-01'
GROUP BY title
ORDER BY COUNT DESC;

-- ADDED QUERY: What are the totals after stripping out terminated employees?
SELECT COUNT(emp_no), title
INTO current_ret_titles
FROM unique_titles
WHERE to_date = '9999-01-01'
GROUP BY title
ORDER BY COUNT DESC;


-- DELIVERABLE 2
-- Retrieve the emp_no, first_name, last_name, and birth_date columns from the Employees table.
-- Retrieve the from_date and to_date columns from the Department Employee table.
-- Retrieve the title column from the Titles table.
-- Use a DISTINCT ON statement to retrieve the first occurrence of the employee number for each set of rows defined by the ON () clause.
-- Create a new table using the INTO clause.
-- Join the Employees and the Department Employee tables on the primary key.
-- Join the Employees and the Titles tables on the primary key.
-- Filter the data on the to_date column to get current employees whose birth dates are between January 1, 1965 and December 31, 1965.
-- Order the table by the employee number.

SELECT DISTINCT ON (e.emp_no) e.emp_no, 
		e.first_name, 
		e.last_name, 
		e.birth_date,
		de.from_date,
		de.to_date,
		tl.title
INTO mentor_eligibility
FROM employees AS e
    INNER JOIN dept_emp AS de
        ON (e.emp_no = de.emp_no)
    INNER JOIN titles AS tl
        ON (e.emp_no = tl.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31') and 
		(de.to_date = '9999-01-01')
ORDER BY e.emp_no;

-- ADDED QUERIES    ADDED QUERIES    ADDED QUERIES --
------------------------------------------------------
-- Summary output of employees eligible for mentorship program by title
SELECT COUNT(emp_no), title
INTO mentoree_titles
FROM mentor_eligibility
GROUP BY title
ORDER BY COUNT DESC;

-- Summary output of retirees by department (not title)
SELECT DISTINCT ON (ut.emp_no) ut.emp_no,
    ut.first_name,
	ut.last_name,
	ut.title,
	ut.to_date,
	de.dept_no,
	d.dept_name
INTO retiree_with_dept
FROM unique_titles AS ut
	LEFT JOIN dept_emp AS de
		ON (ut.emp_no = de.emp_no AND ut.to_date = de.to_date)
	LEFT JOIN departments AS d
		ON (de.dept_no = d.dept_no)
WHERE ut.to_date = '9999-01-01';

SELECT COUNT(rwd.emp_no), rwd.dept_name, rwd.title
INTO retiree_by_dept_title
FROM retiree_with_dept as rwd
GROUP BY rwd.dept_name, rwd.title
ORDER BY rwd.dept_name;

SELECT COUNT(rwd.emp_no), rwd.dept_name
INTO retiree_by_dept
FROM retiree_with_dept as rwd
GROUP BY rwd.dept_name
ORDER BY rwd.dept_name;
-- Summary output of mentorees by department (not title)
SELECT DISTINCT ON (me.emp_no) me.emp_no,
    me.first_name,
	me.last_name,
	me.title,
	me.to_date,
	de.dept_no,
	d.dept_name
INTO mentoree_with_dept
FROM mentor_eligibility AS me
	LEFT JOIN dept_emp AS de
		ON (me.emp_no = de.emp_no AND me.to_date = de.to_date)
	LEFT JOIN departments AS d
		ON (de.dept_no = d.dept_no);

SELECT COUNT(mwd.emp_no), mwd.dept_name, mwd.title
INTO mentoree_by_dept_title
FROM mentoree_with_dept as mwd
GROUP BY mwd.dept_name, mwd.title
ORDER BY mwd.dept_name;

SELECT COUNT(mwd.emp_no), mwd.dept_name
INTO mentoree_by_dept
FROM mentoree_with_dept as mwd
GROUP BY mwd.dept_name
ORDER BY mwd.dept_name;

-- ADDED QUERIES    ADDED QUERIES    ADDED QUERIES --
------------------------------------------------------
-- Potential retirees with tenure: Copy csv file to protect original
SELECT * 
INTO retirees_list
FROM retirement_titles;

-- Potential retirees with tenure: 
-- Copy csv file to protect original
SELECT * 
INTO retirees_list
FROM retirement_titles;

-- Step 1: updating from_date to current date
SELECT emp_no, first_name, last_name, title, from_date, to_date,
  CASE
    WHEN to_date = '9999-01-01' THEN '2020-11-07'
    ELSE to_date
  END 
  AS to_date2
INTO retirees_updt
FROM retirees_list
WHERE to_date = '9999-01-01';

-- Step 2: create tenure variable and calculate days/365 for years of service in current position
ALTER TABLE retirees_updt 
ADD tenure INT;
UPDATE retirees_updt
SET tenure = (to_date2 - from_date)/365;

-- Ouput for query shows lowest number of years of tenure
SELECT * FROM retirees_updt
ORDER BY tenure;

-- ADDED QUERIES    ADDED QUERIES    ADDED QUERIES --
------------------------------------------------------
-- Quick check on total current employees
SELECT COUNT(emp_no) 
FROM dept_emp
WHERE to_date = '9999-01-01'
--Quick check on current employees by department
SELECT COUNT(emp_no) 
FROM dept_emp
WHERE to_date = '9999-01-01'
GROUP BY emp_no
ORDER BY emp_no;
