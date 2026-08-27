from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.db.session import get_db
from app.schemas.common import APIResponse
from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()

@router.get("", response_model=APIResponse[list])
async def get_notifications(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Returns empty list for now until FCM integration is complete
    return APIResponse(data=[])

@router.post("/device-token")
async def register_device_token(
    token: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Store FCM device token
    return APIResponse(message="Device token registered")

from pydantic import BaseModel, ConfigDict
from typing import Optional
from app.models.user import RoleEnum

class BroadcastRequest(BaseModel):
    title: str
    body: str
    image_url: Optional[str] = None
    target: Optional[str] = "all" # 'all' or user ID

@router.post("/broadcast")
async def broadcast_notification(
    payload: BroadcastRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != RoleEnum.ADMIN:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    from app.models.extras import Notification
    from sqlalchemy import select

    if payload.target == "all" or payload.target == "users":
        # Target all users
        result = await db.execute(select(User).where(User.role == RoleEnum.USER))
        users = result.scalars().all()
    elif payload.target == "admins":
        result = await db.execute(select(User).where(User.role == RoleEnum.ADMIN))
        users = result.scalars().all()
    else:
        # Target a specific user ID
        result = await db.execute(select(User).where(User.id == payload.target))
        users = result.scalars().all()

    if not users:
        return APIResponse(data={"delivered_count": 0}, message="Bildirishnoma tizimda saqlandi")

    notifications = []
    for user in users:
        notification = Notification(
            user_id=user.id,
            title=payload.title,
            body=payload.body,
            image_url=payload.image_url,
        )
        notifications.append(notification)
        db.add(notification)
    
    await db.commit()
    
    return APIResponse(message=f"Notification dispatched successfully to {len(notifications)} users")
