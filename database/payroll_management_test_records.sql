-- Populating tables with test records

INSERT INTO employees(first_name, last_name, department, hire_date) VALUES
('Priya', 'Natarajan', 'Data Engineering', '2025-06-01'),
('Rahul', 'Verma', 'Backend', '2024-11-15'),
('Vikram', 'Reddy', 'DevOps', '2023-01-05'),
('Meera', 'Subramanian', 'Data Engineering', '2023-03-18'),
('Arjun', 'Menon', 'Backend', '2024-06-12'),
('Divya', 'Shankar', 'Frontend', '2024-08-25');

INSERT INTO employee_compensation(emp_id, monthly_basic_salary, effective_start_date) VALUES
('1', 45000.00, '2025-06-01'),
('2', 60000.00, '2024-11-15'),
('3', 70000.00, '2023-01-05'),   -- Vikram
('4', 90000.00, '2023-03-18'),   -- Meera
('5', 100000.00, '2024-06-12'),   -- Arjun
('6', 275000.00, '2024-08-25');   


INSERT INTO income_tax_slabs(financial_year, min_annual_income, max_annual_income, tax_rate) VALUES
('2026-2027', 0.00, 300000.00, 0.0000),
('2026-2027', 300000.01, 600000.00, 0.0500),
('2026-2027', 600000.01, 900000.00, 0.1000),
('2026-2027', 900000.01, 1200000.00, 0.1500),
('2026-2027', 1200000.00, NULL, 0.2000),
('2024-2025', 0.00, 300000.00, 0.0000),
('2024-2025', 300000.01, 600000.00, 0.0500),
('2024-2025', 600000.01, 900000.00, 0.1000),
('2024-2025', 900000.01, 1200000.00, 0.1500),
('2024-2025', 1200000.00, NULL, 0.2000),
('2025-2026', 0.00, 300000.00, 0.0000),
('2025-2026', 300000.01, 600000.00, 0.0500),
('2025-2026', 600000.01, 900000.00, 0.1000),
('2025-2026', 900000.01, 1200000.00, 0.1500),
('2025-2026', 1200000.00, NULL, 0.2000);

INSERT INTO timesheets(
	emp_id,
    work_date,
    hours_worked,
    status
)
WITH RECURSIVE generated_date AS(
	SELECT '2026-06-01' as work_date
    UNION ALL
    SELECT DATE_ADD(work_date, INTERVAL 1 DAY)
    FROM generated_date
    WHERE work_date < '2026-06-30'
)
SELECT 
	e.emp_id,
    d.work_date,
    ROUND(8 + (2*RAND()), 2) AS hours_worked,
    'APPROVED' AS status
FROM generated_date as d
CROSS JOIN (SELECT emp_id FROM employees) AS e 
WHERE DAYOFWEEK(d.work_date) NOT IN (1, 7);

-- select * from employees;

-- select * from timesheets;

-- select * from employee_compensation;



    