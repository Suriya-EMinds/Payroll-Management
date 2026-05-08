from fastapi import FastAPI
from api.routes import payroll_routes

app = FastAPI(
    title="Indian Payroll API",
    description="API for managing automated payroll batch processing.",
    version="1.0.0"
)

# Attach the routes built in the api folder
app.include_router(payroll_routes.router, prefix="/api/v1", tags=["Payroll Operations"])