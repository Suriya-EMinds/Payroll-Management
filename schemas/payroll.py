from pydantic import BaseModel

class PayrollRunRequest(BaseModel):
    payroll_month: str      # Format: 'YYYY-MM-DD'
    financial_year: str     # Format: 'YYYY-YYYY'