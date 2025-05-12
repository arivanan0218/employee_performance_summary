from pydantic import BaseModel
from typing import Optional, List

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
    summary: str