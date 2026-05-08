CREATE DATABASE IF NOT EXISTS payroll_management;
USE payroll_management;

-- CREATING employee TABLE

CREATE TABLE IF NOT EXISTS employees(
	emp_id INT AUTO_INCREMENT PRIMARY KEY, 
    first_name VARCHAR(50) NOT NULL, 
    last_name VARCHAR(50) NOT NULL, 
    department VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL, 
	employment_status ENUM('ACTIVE', 'TERMINATED', 'ON_LEAVE') DEFAULT 'ACTIVE'
);

-- CREATING employee_compensation TABLE

CREATE TABLE IF NOT EXISTS employee_compensation(
	comp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    monthly_basic_salary DECIMAL(12, 2) NOT NULL,
    effective_start_date DATE NOT NULL,
    effective_end_date DATE DEFAULT '9999-12-31',
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
	INDEX idx_active_rate (emp_id, is_active)
);

-- CREATING tax_brackets TABLE

CREATE TABLE IF NOT EXISTS income_tax_slabs(
	slab_id INT AUTO_INCREMENT PRIMARY KEY,
    financial_year VARCHAR(9) NOT NULL,
    min_annual_income DECIMAL(12, 2) NOT NULL,
    max_annual_income DECIMAL(12, 2),
    tax_rate DECIMAL(5, 4) NOT NULL,
    UNIQUE INDEX idx_year_min_income (financial_year, min_annual_income)
);

-- CREATING timesheets TABLE

CREATE TABLE IF NOT EXISTS timesheets(
	timesheet_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
	work_date DATE NOT NULL,
    hours_worked DECIMAL(4, 2) NOT NULL,
    status ENUM('PENDING', 'APPROVED', 'PROCESSED') DEFAULT 'PENDING',
    FOREIGN KEY(emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
    CONSTRAINT chk_hours CHECK (hours_worked >= 0 AND hours_worked <= 24),
    UNIQUE INDEX idx_emp_date (emp_id, work_date)
);

-- CREATING pay_stubs TABLE

CREATE TABLE IF NOT EXISTS pay_stubs(
	stub_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    pay_month DATE NOT NULL,
    
    -- Mathematical snapshot records
	monthly_basic DECIMAL(12, 2) NOT NULL,
    effective_basic DECIMAL(12, 2) NOT NULL,
    epf_deduction DECIMAL(10, 2) NOT NULL,
    tds_deduction DECIMAL(10, 2) NOT NULL,
    net_pay DECIMAL(12, 2) NOT NULL,
    
    processed_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(emp_id) REFERENCES employees(emp_id),
    INDEX idx_reporting (emp_id, pay_month)
);

