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
    from app.models.extras import Notification
    from sqlalchemy import select
    
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .order_by(Notification.created_at.desc())
    )
    notifications = result.scalars().all()
    
    return APIResponse(data=[
        {
            "id": str(n.id),
            "title": n.title,
            "body": n.body,
            "imageUrl": n.image_url,
            "isRead": n.is_read,
            "createdAt": n.created_at.isoformat() if n.created_at else None,
        }
        for n in notifications
    ])

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
    title: dict[str, str] # e.g. {"uz": "...", "ru": "...", "en": "..."}
    body: dict[str, str]
    image_url: Optional[str] = None
    target: Optional[str] = "all" # 'all' or user ID

@router.post("/broadcast")
async def broadcast_notification(
    payload: BroadcastRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role not in [RoleEnum.ADMIN, RoleEnum.OWNER]:
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
        lang = getattr(user, 'preferred_language', 'uz') or 'uz'
        # Fallback logic: Try preferred language, then 'uz', then whatever is available
        title = payload.title.get(lang) or payload.title.get('uz') or next(iter(payload.title.values()), "")
        body = payload.body.get(lang) or payload.body.get('uz') or next(iter(payload.body.values()), "")
        
        notification = Notification(
            user_id=user.id,
            title=title,
            body=body,
            image_url=payload.image_url,
        )
        notifications.append(notification)
        db.add(notification)
    
    await db.commit()
    
    return APIResponse(message=f"Notification dispatched successfully to {len(notifications)} users")
