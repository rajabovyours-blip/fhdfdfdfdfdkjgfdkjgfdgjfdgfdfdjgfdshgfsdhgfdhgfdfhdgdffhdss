from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.db.session import get_db
from app.models.user import User
from app.schemas.user import UserModel
from app.schemas.common import APIResponse
from app.api.deps import get_current_user
from app.models.user import RoleEnum

router = APIRouter()

@router.get("/", response_model=APIResponse[List[UserModel]])
async def get_users(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != RoleEnum.ADMIN:
        raise HTTPException(status_code=403, detail="Not enough permissions")
        
    result = await db.execute(select(User))
    users = result.scalars().all()
    return APIResponse(data=[UserModel.model_validate(u) for u in users])
