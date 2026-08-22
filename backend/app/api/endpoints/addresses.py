from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.db.session import get_db
from app.schemas.common import APIResponse
from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()

@router.get("", response_model=APIResponse[list])
async def get_addresses(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return APIResponse(data=[])

@router.post("", response_model=APIResponse[dict])
async def add_address(
    data: dict,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return APIResponse(message="Address added successfully")
