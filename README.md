# DB_access_PostgreSQL/Tailscale
Documentation for assignment 04b for Software integration course
# PostgreSQL Database Access Guide

## Table of Contents
1. Download and Install PostgreSQL 17
2. Download Tailscale
3. Connect to the Database via CLI
4. Perform Queries as `regular_user`
5. Log Out and Log In as `hr_user`
6. Commands for `hr_user`

## 1. Download and Install PostgreSQL 17

1. **Download PostgreSQL 17**:
   - Visit the official PostgreSQL website to download PostgreSQL 17: [PostgreSQL Downloads](https://www.postgresql.org/download/)
   - Follow the installation instructions for your operating system.
   - Remember to add bin to path (for Windows systems)
  
## 2. Download and install Tailscale

1. **Download Tailscale**
   - Go to [Tailscale](https://tailscale.com/download), and download & install
   - Join the admins tailnetwork

## 3. Connect to the Database via CLI

1. **Obtain the URL**:
   - You will be provided with a local URL visible in the Tailscale admin console by the tailnetwork admin.

2. **Connect Using `psql`**:
   - Use the `psql` command-line tool to connect to the database (e.g. Git Bash). The command will look something like this:
     psql -h URL -p 5432 -U regular_user -d postgres
   - Replace `URL` with the actual URL provided without https.

## 4. Perform Queries as `regular_user`

1. **Log In as `regular_user`**.
   - Password: password

2. **Allowed Queries**:
   - Select data from permitted columns:
     SELECT id, name, department, manager_id FROM employee_db.employees;
   - Except where the manager_id = 1, since that policy was inforced by the row-level security

3. **Disallowed Queries**:
   - Attempting to select restricted columns (`ssn`, `address`, `salary`) will result in an error:
     SELECT ssn, address, salary FROM employee_db.employees;
   - Except where the manager_id = 1, since that policy was inforced by the row-level security
   - Attempting to insert data will result in an error:
     INSERT INTO employee_db.employees (name, department, ssn, address, manager_id) VALUES ('Test', 'IT', '123-45-6789', '123 Test St', NULL);

## 5. Log Out and Log In as `hr_user`

1. **Log Out**:
   - Exit the `psql` session:
     \q

2. **Log In as `hr_user`**.
   - Password: hr_password

## 6. Commands for `hr_user`

1. **Allowed Queries**:
   - Select data from all columns:
     SELECT * FROM employee_db.employees;
   - Insert data into all columns except `salary`:
     INSERT INTO employee_db.employees (name, department, ssn, address, manager_id) VALUES ('Test', 'IT', '123-45-6789', '123 Test St', NULL);

2. **Disallowed Queries**:
   - Attempting to insert data into the `salary` column will result in an error:
     INSERT INTO employee_db.employees (name, department, ssn, address, salary, manager_id) VALUES ('Test', 'IT', '123-45-6789', '123 Test St', 50000, NULL);
