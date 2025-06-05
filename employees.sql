-- ==============================================
-- Create a new schema called employee_db
-- ==============================================
CREATE SCHEMA employee_db;

-- ==============================================
-- Create the employees table within the employee_db schema
-- ==============================================
CREATE TABLE employee_db.employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    department VARCHAR(255),
    ssn VARCHAR(11),  -- Social Security Number
    address VARCHAR(255),  -- Employee address
    salary DECIMAL(10, 2),  -- Employee salary
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES employee_db.employees (id)
);

-- ==============================================
-- Insert sample data into the employees table
-- ==============================================
INSERT INTO employee_db.employees (name, department, ssn, address, salary, manager_id) VALUES
('Alice', 'HR', '123-45-6789', '123 HR St, City', 60000.00, NULL),
('Bob', 'HR', '987-65-4321', '456 HR Rd, City', 55000.00, 1),
('Charlie', 'IT', '111-22-3333', '789 IT Ave, City', 70000.00, NULL),
('David', 'IT', '444-55-6666', '321 IT Blvd, City', 65000.00, 3),
('Eve', 'IT', '777-88-9999', '654 IT Dr, City', 62000.00, 3),
('Faythe', 'Finance', '000-11-2222', '987 Fin St, City', 58000.00, NULL),
('Grace', 'Finance', '333-44-5555', '123 Fin Ave, City', 60000.00, 6);

-- ==============================================
-- Create roles for users
-- ==============================================
CREATE ROLE regular_user WITH LOGIN PASSWORD 'password';
CREATE ROLE hr_user WITH LOGIN PASSWORD 'hr_password';

-- ==============================================
-- Grant access to the employees table
-- ==============================================
GRANT USAGE ON SCHEMA employee_db TO regular_user;
GRANT USAGE ON SCHEMA employee_db TO hr_user;

-- Grant SELECT on all columns to hr_user
GRANT SELECT ON ALL TABLES IN SCHEMA employee_db TO hr_user;

-- Revoke SELECT on restricted columns for regular_user
REVOKE SELECT ON employee_db.employees FROM regular_user;
GRANT SELECT (id, name, department, manager_id) ON employee_db.employees TO regular_user;

-- Grant INSERT on all columns except salary to hr_user
GRANT INSERT (id, name, department, ssn, address, manager_id) ON employee_db.employees TO hr_user;

-- Grant USAGE and SELECT on the sequence to hr_user
GRANT USAGE, SELECT ON SEQUENCE employee_db.employees_id_seq TO hr_user;

-- Ensure regular_user cannot INSERT
REVOKE INSERT ON employee_db.employees FROM regular_user;

-- ==============================================
-- Enable row-level security
-- ==============================================
ALTER TABLE employee_db.employees ENABLE ROW LEVEL SECURITY;

-- ==============================================
-- Create policies for security
-- ==============================================
-- Policy for regular user: Allow access to all rows but restrict columns
CREATE POLICY regular_user_policy ON employee_db.employees
FOR SELECT
USING (TRUE);  -- Allow selection of all rows

-- Policy for HR user: Allow access to all columns and rows
CREATE POLICY hr_user_policy ON employee_db.employees
FOR SELECT
USING (TRUE);  -- Allow all access for HR

-- Policy for HR user: Allow INSERT on all columns except salary
CREATE POLICY hr_user_insert_policy ON employee_db.employees
FOR INSERT
WITH CHECK (salary IS NULL);  -- Allow insertion only if salary is NULL

-- Create policy for row level security

-- Policy for regular user: Allow only access where manager id = 1
CREATE POLICY actor_rls_policy
  ON employee_db.employees
  FOR SELECT
  TO regular_user
  USING (manager_id = 2);

-- Ensure policies are enforced
ALTER TABLE employee_db.employees FORCE ROW LEVEL SECURITY;

-- ==============================================
-- Test roles and policies
-- ==============================================
-- Test as regular user
-- SET ROLE regular_user;
-- SELECT id, name, department, manager_id FROM employee_db.employees;  -- Should show only the allowed columns/rows
-- INSERT INTO employee_db.employees (name, department, ssn, address, manager_id) VALUES ('Test', 'IT', '123-45-6789', '123 Test St', NULL);  -- Should fail

-- Test as HR user
-- SET ROLE hr_user;
-- SELECT * FROM employee_db.employees;  -- Should show everything
-- INSERT INTO employee_db.employees (name, department, ssn, address, manager_id) VALUES ('Test', 'IT', '123-45-6789', '123 Test St', NULL);  -- Should succeed
-- INSERT INTO employee_db.employees (name, department, ssn, address, salary, manager_id) VALUES ('Test', 'IT', '123-45-6789', '123 Test St', 50000, NULL);  -- Should fail
