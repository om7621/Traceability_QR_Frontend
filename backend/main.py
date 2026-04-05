import os
from fastapi import FastAPI, HTTPException, Depends
from typing import Optional, List
import pyodbc
from pydantic import BaseModel

app = FastAPI()

# --- Configuration ---
# Updated with your actual Azure SQL details
DB_CONNECTION_STRING = (
    "Driver={ODBC Driver 18 for SQL Server};"
    "Server=tcp:newen-server.database.windows.net,1433;"
    "Database=newen_traceability_db;"
    "Uid=omsingh;"
    "Pwd=Singhisblink7621;"
    "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
)

# --- Models ---
class Component(BaseModel):
    id: int
    section_name: str
    component_name: str
    make: str
    serial_number: str

class PanelResponse(BaseModel):
    panel_serial: str
    product_type: str
    prepared_by: Optional[str]
    start_date: Optional[str]
    project_name: Optional[str]
    reference_document: Optional[str]
    verified_by: Optional[str]
    remarks: Optional[str]
    status: str
    components: Optional[List[Component]] = None

# --- Helper Functions ---
def get_db_connection():
    try:
        return pyodbc.connect(DB_CONNECTION_STRING)
    except Exception as e:
        print(f"DB Connection Error: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")

# --- Endpoints ---

@app.get("/get_panel_details", response_model=PanelResponse)
def get_panel_details(id: str, authenticated: bool = False):
    conn = get_db_connection()
    cursor = conn.cursor()

    # 1. Fetch Panel Data from [dbo].[Panels]
    cursor.execute("""
        SELECT panel_serial, product_type, prepared_by, start_date,
               project_name, reference_document, verified_by, remarks, status
        FROM [dbo].[Panels]
        WHERE panel_serial = ?
    """, id)
    row = cursor.fetchone()

    if not row:
        conn.close()
        raise HTTPException(status_code=404, detail="Panel not registered in system")

    response = PanelResponse(
        panel_serial=row.panel_serial,
        product_type=row.product_type,
        prepared_by=row.prepared_by,
        start_date=str(row.start_date) if row.start_date else None,
        project_name=row.project_name,
        reference_document=row.reference_document,
        verified_by=row.verified_by,
        remarks=row.remarks,
        status=row.status
    )

    # 2. Fetch Components Data from [dbo].[Components] if authenticated
    if authenticated:
        cursor.execute("""
            SELECT id, section_name, component_name, make, serial_number
            FROM [dbo].[Components]
            WHERE panel_serial = ?
        """, id)

        components = []
        for c_row in cursor.fetchall():
            components.append(Component(
                id=c_row.id,
                section_name=c_row.section_name,
                component_name=c_row.component_name,
                make=c_row.make,
                serial_number=c_row.serial_number
            ))
        response.components = components

    conn.close()
    return response

@app.post("/raise_ticket")
def raise_ticket(ticket: dict):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # Assuming a Tickets table exists or you want to create one
        # For now, we'll just log it or you can specify the table structure
        cursor.execute(
            "INSERT INTO Tickets (panel_serial, description, contact_info, status) VALUES (?, ?, ?, 'Open')",
            (ticket['panelId'], ticket['description'], ticket['contactInfo'])
        )
        conn.commit()
        return {"status": "success"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
