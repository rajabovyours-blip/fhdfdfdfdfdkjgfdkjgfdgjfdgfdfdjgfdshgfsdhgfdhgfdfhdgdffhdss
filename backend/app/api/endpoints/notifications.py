from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional
from pydantic import BaseModel

from app.db.session import get_db
from app.schemas.common import APIResponse
from app.api.deps import get_current_user, get_current_admin
from app.models.user import User, RoleEnum
from app.models.extras import Notification, NotificationBroadcast

router = APIRouter()


@router.get("", response_model=APIResponse[list])
async def get_notifications(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Foydalanuvchining O'ZIGA kelgan bildirishnomalar (mijoz ilovasi uchun)."""
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


@router.get("/admin/history", response_model=APIResponse[list])
async def get_broadcast_history(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    """Admin panel uchun: yuborilgan PUSH xabarlar tarixi (har bir broadcast — bitta qator)."""
    result = await db.execute(
        select(NotificationBroadcast).order_by(NotificationBroadcast.created_at.desc())
    )
    rows = result.scalars().all()

    return APIResponse(data=[
        {
            "id": str(b.id),
            "title": b.title,
            "body": b.body,
            "image_url": b.image_url,
            "target": b.target,
            "recipient_count": b.recipient_count,
            "created_at": b.created_at.isoformat() if b.created_at else None,
        }
        for b in rows
    ])


@router.post("/device-token")
async def register_device_token(
    token: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Store FCM device token
    return APIResponse(message="Device token registered")


class BroadcastRequest(BaseModel):
    """Admin panel oddiy matn yuboradi (ko'p tilli dict emas)."""
    title: str
    body: str
    image_url: Optional[str] = None
    target: Optional[str] = "all"  # 'all' | 'admins' | <user_id>


@router.post("/broadcast")
async def broadcast_notification(
    payload: BroadcastRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    if payload.target == "admins":
        result = await db.execute(select(User).where(User.role == RoleEnum.ADMIN))
        users = result.scalars().all()
    elif payload.target in (None, "all", "users", "customers", "sellers"):
        result = await db.execute(select(User).where(User.role == RoleEnum.USER))
        users = result.scalars().all()
    else:
        # Aniq bitta foydalanuvchi ID
        result = await db.execute(select(User).where(User.id == payload.target))
        users = result.scalars().all()

    for user in users:
        db.add(Notification(
            user_id=user.id,
            title=payload.title,
            body=payload.body,
            image_url=payload.image_url,
        ))

    # Broadcast tarixiga BITTA yozuv — admin panelida shu ko'rinadi
    db.add(NotificationBroadcast(
        title=payload.title,
        body=payload.body,
        image_url=payload.image_url,
        target=payload.target or "all",
        recipient_count=len(users),
        sent_by=current_user.id,
    ))

    await db.commit()

    return APIResponse(message=f"Xabar {len(users)} foydalanuvchiga yuborildi", data={"delivered_count": len(users)})
