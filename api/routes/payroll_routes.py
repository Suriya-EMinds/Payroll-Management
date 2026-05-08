from fastapi import APIRouter, HTTPException, UploadFile, File
import shutil
import os
import pymysql
from core.database import get_db_connection
from schemas.payroll import PayrollRunRequest
from etl.ingest_timesheets import run_pipeline

router = APIRouter()


@router.get("/payslip/{emp_id}")
def get_employee_payslips(emp_id: int):
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            sql = "SELECT * FROM vw_monthly_payslip WHERE emp_id = %s"
            cursor.execute(sql, (emp_id,))
            result = cursor.fetchall()

            if not result:
                raise HTTPException(status_code=404, detail="No payslips found for this employee.")
            return {"status": "success", "employee_id": emp_id, "data": result}

    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"Database connection error: {str(e)}")
    finally:
        if 'connection' in locals() and connection.open:
            connection.close()


@router.post("/payroll/run")
def trigger_payroll_run(request: PayrollRunRequest):
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.callproc('sp_run_payroll', (request.payroll_month, request.financial_year))
            connection.commit()

            return {
                "status": "success",
                "message": f"Payroll successfully generated for month {request.payroll_month}.",
                "financial_year": request.financial_year
            }

    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"Database execution error: {str(e)}")
    finally:
        if 'connection' in locals() and connection.open:
            connection.close()


@router.post("/timesheets/upload")
async def upload_timesheet(file: UploadFile = File(...)):
    """
    Accepts a CSV file from the user, saves it temporarily, and runs the Pandas ETL pipeline.
    """
    if not file.filename.endswith('.csv'):
        raise HTTPException(status_code=400, detail="Only CSV files are allowed.")

    try:
        # Temporary path to save the uploaded file
        temp_file_path = f"temp_{file.filename}"

        # Save the uploaded file to the server's hard drive
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Trigger Pandas script
        run_pipeline(temp_file_path)

        # Clean up
        os.remove(temp_file_path)

        return {"status": "success", "message": f"Successfully ingested {file.filename} into database."}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"ETL Pipeline failed: {str(e)}")