-- ``````````````Functions````````````````````

DELIMITER $$
CREATE FUNCTION fn_calculate_epf(
	p_monthly_basic DECIMAL(12, 2)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
NO SQL
BEGIN
	DECLARE v_epf_deduction DECIMAL(10, 2);
    SET v_epf_deduction = p_monthly_basic * 0.12;
    RETURN v_epf_deduction;
END $$
DELIMITER ;

-- ``````````````````````````````````````````````````

DELIMITER $$
CREATE FUNCTION fn_calculate_tds(
    p_monthly_income DECIMAL(12, 2), 
    p_financial_year VARCHAR(9)
) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_annual_income DECIMAL(12, 2);
    DECLARE v_annual_tax DECIMAL(12, 2);
    SET v_annual_income = p_monthly_income * 12;
    SELECT SUM(
        (LEAST(v_annual_income, COALESCE(max_annual_income, v_annual_income)) - min_annual_income) * tax_rate) INTO v_annual_tax
    FROM income_tax_slabs
    WHERE financial_year = p_financial_year
      AND min_annual_income < v_annual_income;

    -- Return the monthly TDS deduction
    RETURN COALESCE(v_annual_tax, 0) / 12;
END $$
DELIMITER ;

-- `````````````Procedures```````````````````

DELIMITER $$
CREATE PROCEDURE sp_run_payroll(
	IN p_payroll_month DATE,
    IN p_financial_year VARCHAR(9)
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        RESIGNAL;
	END;

	START TRANSACTION;
	DELETE FROM pay_stubs WHERE pay_month = p_payroll_month;
	
    INSERT INTO pay_stubs(
		emp_id, pay_month, monthly_basic, effective_basic, epf_deduction, tds_deduction, net_pay
	)
    WITH attendance_cte AS (
		SELECT emp_id, COUNT(timesheet_id) as days_worked
        FROM timesheets
        WHERE MONTH(work_date) = MONTH(p_payroll_month)
			AND YEAR(work_date) = YEAR (p_payroll_month)
            AND status IN ('APPROVED', 'PROCESSED')
		GROUP BY emp_id
    ),
	salary_cte AS(
		SELECT 
			e.emp_id,
			p_payroll_month AS pay_month,
            c.monthly_basic_salary,
            -- FORMULA: month_basic * (days_worked / standard days). Capped at 100%
			ROUND(c.monthly_basic_salary * LEAST(COALESCE((a.days_worked), 0)/22.0, 1.0)) AS effective_basic
		FROM employees AS e
		LEFT JOIN attendance_cte AS a ON e.emp_id = a.emp_id
        LEFT JOIN employee_compensation AS c ON e.emp_id = c.emp_id
        WHERE e.employment_status= 'ACTIVE' 
			AND p_payroll_month BETWEEN c.effective_start_date AND c.effective_end_date
    )
    SELECT 
		emp_id,
        p_payroll_month,
        monthly_basic_salary,
        effective_basic,
        fn_calculate_epf(effective_basic) AS epf,
        fn_calculate_tds(effective_basic, p_financial_year) AS tds,
        -- net_pay = basic - epf - tds
        (effective_basic - fn_calculate_epf(effective_basic) - fn_calculate_tds(effective_basic, p_financial_year)) AS net_pay
	FROM salary_cte;
    
    UPDATE timesheets
    SET status = 'PROCESSED'
    WHERE MONTH(work_date) = MONTH(p_payroll_month)
		AND YEAR(work_date) = YEAR(p_payroll_month)
        AND status = 'APPROVED';
    
    COMMIT;
END$$
DELIMITER ;

-- 1. Turn off the safety net
SET SQL_SAFE_UPDATES = 0;

-- 2. Run your payroll
CALL sp_run_payroll('2026-06-01', '2026-2027');

-- 3. Turn the safety net back on
SET SQL_SAFE_UPDATES = 1;

SELECT * from pay_stubs;

CREATE OR REPLACE VIEW vw_monthly_payslip AS
SELECT 
ps.stub_id,
e.emp_id,
CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
DATE_FORMAT(ps.pay_month, '%M %Y') AS salary_month,
ps.monthly_basic AS base_salary,
ps.effective_basic AS earned_slary,
ps.epf_deduction AS pf_deduction,
ps.tds_deduction AS income_tax_deduction,
(ps.tds_deduction + ps.epf_deduction) AS total_deduction,
ps.net_pay AS net_salary_transferred,
ps.processed_timestamp AS generated_on
FROM pay_stubs AS ps
JOIN employees AS e ON ps.emp_id = e.emp_id;

-- select * from vw_monthly_payslip;

