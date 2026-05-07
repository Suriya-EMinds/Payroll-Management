import pandas as pd
from sqlalchemy import create_engine
import os

DB_URL = "mysql+pymysql://root:root@localhost/payroll_management"


def run_pipeline(file_path: str):
    print(f"Starting Extraction: Reading {file_path}")

    # --- EXTRACT ---
    try:
        df = pd.read_csv(file_path)
        print(f"Extracted {len(df)} rows.")
    except FileNotFoundError:
        print("Error: File not found.")
        return

    # --- TRANSFORM ---
    print("Starting Transformation: Cleaning data...")

    df.dropna(how='all', inplace=True)

    df['hours_worked'] = df['hours_worked'].fillna(0)

    df.loc[df['hours_worked'] >= 24, 'hours_worked'] = 24

    # Convert work_date to actual DateTime objects
    df['work_date'] = pd.to_datetime(df['work_date'])

    # Add the 'status' column
    df['status'] = 'APPROVED'

    print(f"Transformation complete. {len(df)} valid rows ready for loading.")

    # --- LOAD ---
    print("Starting Load: Pushing to MySQL...")
    try:
        engine = create_engine(DB_URL)

        # index=False ensures not to insert the pandas row numbers.
        df.to_sql(name='timesheets', con=engine, if_exists='append', index=False)

        print("Data successfully loaded into 'timesheets' table.")
    except Exception as e:
        print(f"Database Load Failed: {e}")


if __name__ == "__main__":
    # Point the script to the messy CSV we created
    target_file = os.path.join(os.path.dirname(__file__), 'raw_data', 'timesheets_july.csv')
    run_pipeline(target_file)

