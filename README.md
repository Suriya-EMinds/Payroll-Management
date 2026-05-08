# 💸 End-to-End Payroll Data Pipeline & API

### What is this?
This is a complete, containerized data engineering and backend architecture for processing company payroll. Instead of a basic CRUD app, I built a system that handles the entire data lifecycle from raw CSV ingestion to serving financial data via REST API, all orchestrated with Docker.

1. **Extract & Transform (Pandas):** Ingests messy, real-world timesheet CSVs, cleans the data (handles missing values, catches impossible hours), and prepares it for the database.
2. **Process (MySQL):** Uses an idempotent Stored Procedure (`sp_run_payroll`) to handle the heavy lifting—calculating taxes, deductions, and net pay natively in the database.
3. **Serve (FastAPI):** A modern REST API that triggers the batch payroll runs and serves the final formatted payslips as JSON.
4. **Interact (Streamlit):** A "Single Pane of Glass" admin dashboard that allows HR to upload timesheets and run the pipeline with a single click.

### The Tech Stack
* **Infrastructure:** Docker & Docker Compose
* **Database Engine:** MySQL 8.0 (Stored Procedures, Views)
* **ETL Pipeline:** Python, Pandas, SQLAlchemy
* **Backend API:** FastAPI, PyMySQL, Pydantic
* **Frontend UI:** Streamlit, Requests

---

### 🚀 How to Run It (Zero Setup Required)

Because this entire architecture is containerized, you do not need to install Python, MySQL, or configure any local environments. 

#### Prerequisites
* [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running.
* Git installed.

#### Step 1: Clone the Repository
```bash
git clone https://github.com/Suriya-EMinds/Payroll-Management.git
cd Payroll-Management
```

#### Step 2: Spin Up the Architecture
Run this single command to download the images, build the database, and start the servers:
```bash
docker-compose up --build
```
*Note: On the very first run, MySQL will automatically execute the SQL files in the `/database` folder sequentially to build the tables, views, and stored procedures.*

#### Step 3: Access the Application
Once the terminal shows that all containers are running, you can access the services:

* **🖥️ Admin Dashboard (Streamlit):** [http://localhost:8501](http://localhost:8501)
  * *Use this to upload a timesheet CSV (e.g., from the `etl/raw_data` folder) and trigger the pipeline.*
* **⚙️ API Documentation (FastAPI Swagger):** [http://localhost:8000/docs](http://localhost:8000/docs)
  * *Use this to directly test endpoints like `GET /api/v1/payslip/{emp_id}`.*

---

### 🛑 Troubleshooting & Database Reset
Docker only runs the database initialization scripts **once** when the volume is first created. If you alter the SQL files in the `database/` folder and want to rebuild the database from scratch, you must destroy the old volume first:

```bash
# 1. Shut down and wipe the database volume
docker-compose down -v

# 2. Rebuild and restart
docker-compose up --build
```
