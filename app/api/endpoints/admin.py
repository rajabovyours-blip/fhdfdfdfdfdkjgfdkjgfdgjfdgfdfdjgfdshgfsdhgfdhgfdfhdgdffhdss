from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.db.session import get_db
from app.models.user import User, RoleEnum
from app.schemas.common import APIResponse
from app.api.deps import get_current_user

router = APIRouter()

def get_admin_user(current_user: User = Depends(get_current_user)):
    if current_user.role != RoleEnum.ADMIN:
        raise HTTPException(status_code=403, detail="Admin permissions required")
    return current_user

@router.get("/dashboard", response_model=APIResponse[dict])
async def get_admin_dashboard(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_admin_user)
):
    # This would aggregate data from various tables
    return APIResponse(data={
        "total_users": 100,
        "total_orders": 500,
        "revenue": 50000000.0
    })

@router.get("/reports", response_model=APIResponse[list])
async def get_admin_reports(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_admin_user)
):
    return APIResponse(data=[])
