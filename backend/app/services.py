import google.generativeai as genai
import os
from dotenv import load_dotenv
from .models import EmployeeData

load_dotenv()  # Load environment variables

# Configure the Gemini API
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

def generate_summary_with_gemini(employee: EmployeeData) -> str:
    """Generate a performance summary using Google's Gemini AI."""
    
    # Create the model
    model = genai.GenerativeModel('gemini-2.0-flash')
    
    # Create the prompt
    prompt = f"""
    Generate a professional, concise performance summary for this employee based on the following data:
    
    Employee Name: {employee.employee_name}
    Employee ID: {employee.employee_id}
    Department: {employee.department}
    Month: {employee.month}
    Tasks Completed: {employee.tasks_completed}
    Goals Met: {employee.goals_met}%
    """
    
    if employee.peer_feedback:
        prompt += f"\nPeer Feedback: {employee.peer_feedback}"
    
    if employee.manager_comments:
        prompt += f"\nManager Comments: {employee.manager_comments}"
    
    prompt += """
    
    Write a professional performance summary paragraph (around 3-5 sentences) that highlights:
    - Overall performance based on goals met percentage
    - Specific achievements from tasks completed
    - Areas of strength and opportunities for growth
    - Tone should be constructive and balanced
    
    The summary should be suitable for inclusion in a formal performance review document.
    """
    
    try:
        # Generate content
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        print(f"Error generating summary: {str(e)}")
        return f"Error generating summary: {str(e)}"