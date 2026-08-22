from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Body
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Dict, Any, List

from app.db.session import get_db
from app.models.user import User, RoleEnum
from app.api.deps import get_current_user
from app.services.excel_importer import ExcelImporter
from app.schemas.common import APIResponse

router = APIRouter()

def get_admin_user(current_user: User = Depends(get_current_user)):
    if current_user.role != RoleEnum.ADMIN:
        raise HTTPException(status_code=403, detail="Admin permissions required")
    return current_user

@router.post("/import/preview", response_model=APIResponse[Dict[str, Any]])
async def preview_excel_import(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_admin_user)
):
    if not file.filename.endswith(".xlsx"):
        raise HTTPException(status_code=400, detail="Only .xlsx files are supported")
        
    content = await file.read()
    importer = ExcelImporter(db)
    result = await importer.preview_file(content)
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
        
    return APIResponse(data=result)

@router.post("/import", response_model=APIResponse[Dict[str, Any]])
async def execute_excel_import(
    rows: List[Dict[str, Any]] = Body(...),
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_admin_user)
):
    if not rows:
        raise HTTPException(status_code=400, detail="No rows provided for import")
        
    importer = ExcelImporter(db)
    result = await importer.execute_import(rows)
    return APIResponse(data=result)
