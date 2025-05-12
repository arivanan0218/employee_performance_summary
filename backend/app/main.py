from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pandas as pd
import io
from .services import generate_summary_with_gemini
from typing import List, Optional
import os
import json
from dotenv import load_dotenv

load_dotenv()  # Load environment variables

app = FastAPI(title="Employee Performance Summary API")

# Configure CORS with more permissive settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

class EmployeeData(BaseModel):
    employee_name: str
    employee_id: str
    department: str
    month: str
    tasks_completed: str
    goals_met: float
    peer_feedback: Optional[str] = None
    manager_comments: Optional[str] = None

class SummaryResponse(BaseModel):
    employee_name: str
    employee_id: str
    department: str
    month: str
    tasks_completed: str  # Added to ensure tasks are returned
    goals_met: float  # Added to ensure goals are returned
    peer_feedback: Optional[str] = None  # Added optional fields
    manager_comments: Optional[str] = None  # Added optional fields
    summary: str

@app.get("/")
def read_root():
    return {"message": "Employee Performance Summary API"}

@app.get("/test-connection/")
def test_connection():
    """Test endpoint to verify the server is accessible"""
    return {"status": "ok", "message": "Connection successful"}

@app.post("/upload-csv/", response_model=List[SummaryResponse])
async def upload_csv(file: UploadFile = File(...)):
    # Check if file is CSV
    if not file.filename.endswith('.csv'):
        raise HTTPException(status_code=400, detail="Only CSV files are allowed")
    
    try:
        # Read CSV file
        contents = await file.read()
        df = pd.read_csv(io.StringIO(contents.decode('utf-8')))
        
        # Print the first few rows of the DataFrame for debugging
        print("CSV Contents (First 5 rows):")
        print(df.head())
        
        # Validate required columns
        required_columns = ['employee_name', 'employee_id', 'department', 'month', 
                           'tasks_completed', 'goals_met']
        
        missing_columns = [col for col in required_columns if col not in df.columns]
        if missing_columns:
            raise HTTPException(
                status_code=400, 
                detail=f"Missing required columns: {', '.join(missing_columns)}"
            )
        
        # Generate summaries for each employee
        summaries = []
        
        for idx, row in df.iterrows():
            # Ensure proper data types
            try:
                goals_met = float(row['goals_met'])
            except (ValueError, TypeError):
                print(f"Warning: Invalid goals_met value: {row['goals_met']} for employee {row['employee_name']}")
                goals_met = 0.0
                
            # Create employee object
            employee = EmployeeData(
                employee_name=str(row['employee_name']),
                employee_id=str(row['employee_id']),
                department=str(row['department']),
                month=str(row['month']),
                tasks_completed=str(row['tasks_completed']),
                goals_met=goals_met,
                peer_feedback=str(row['peer_feedback']) if 'peer_feedback' in row and pd.notna(row['peer_feedback']) else None,
                manager_comments=str(row['manager_comments']) if 'manager_comments' in row and pd.notna(row['manager_comments']) else None
            )
            
            # Generate summary using Gemini
            try:
                summary = generate_summary_with_gemini(employee)
            except Exception as e:
                print(f"Error generating summary: {e}")
                summary = f"Error generating summary: {str(e)}"
            
            # Create response object
            response_item = SummaryResponse(
                employee_name=employee.employee_name,
                employee_id=employee.employee_id,
                department=employee.department,
                month=employee.month,
                tasks_completed=employee.tasks_completed,
                goals_met=employee.goals_met,
                peer_feedback=employee.peer_feedback,
                manager_comments=employee.manager_comments,
                summary=summary
            )
            
            # Print the response object for debugging
            print(f"Response item {idx}:")
            print(response_item.dict())
            
            summaries.append(response_item)
        
        return summaries
    
    except Exception as e:
        print(f"Error processing CSV: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)