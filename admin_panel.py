import streamlit as st
import requests

# 1. Page Configuration
st.set_page_config(page_title="Payroll Admin", page_icon="💸", layout="centered")

st.title("💸 Payroll Management Admin")
st.markdown("Upload monthly biometric timesheets to automatically clean data and process payroll.")
st.divider()

# 2. The Drag-and-Drop Uploader
uploaded_file = st.file_uploader("Upload Timesheet (CSV format only)", type=["csv"])

if uploaded_file is not None:
    st.info(f"File selected: **{uploaded_file.name}**")

    # 3. The Execution Button
    if st.button("🚀 Run ETL Pipeline & Generate Payroll", type="primary"):

        # Shows a loading spinner while the pandas script runs
        with st.spinner("Sending to FastAPI and processing data..."):
            try:
                # Package the file to send over the internet
                files = {"file": (uploaded_file.name, uploaded_file.getvalue(), "text/csv")}

                # Hit your FastAPI endpoint
                response = requests.post("http://api:8000/api/v1/timesheets/upload", files=files)

                # Handle the response
                if response.status_code == 200:
                    st.success(response.json().get("message", "Pipeline executed successfully!"))
                    st.balloons()  # A little celebration flair!
                else:
                    st.error(f"❌ API Error: {response.json().get('detail', 'Unknown error')}")

            except requests.exceptions.ConnectionError:
                st.error("🚨 Critical Error: Could not connect to the backend. Is your FastAPI server running?")