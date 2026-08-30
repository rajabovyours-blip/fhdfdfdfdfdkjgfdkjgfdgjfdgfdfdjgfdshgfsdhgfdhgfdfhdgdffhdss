from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
import uuid

from app.db.session import get_db
from app.models.user import User, RoleEnum
from app.schemas.common import APIResponse
from app.api.dependencies import get_current_owner
from app.security.hashing import get_password_hash
from pydantic import BaseModel, Field

router = APIRouter()

class AdminUserResponse(BaseModel):
    id: uuid.UUID
    username: str
    full_name: str
    role: RoleEnum
    is_active: bool

class AdminUserCreate(BaseModel):
    username: str
    full_name: str
    password: str = Field(..., min_length=6)
    role: RoleEnum = RoleEnum.ADMIN

class AdminUserUpdate(BaseModel):
    full_name: str | None = None
    password: str | None = Field(None, min_length=6)
    role: RoleEnum | None = None

class AdminUserStatusUpdate(BaseModel):
    is_active: bool

@router.get("/", response_model=APIResponse[List[AdminUserResponse]])
async def list_admins(
    db: AsyncSession = Depends(get_db),
    owner: User = Depends(get_current_owner)
):
    result = await db.execute(
        select(User).where(User.role.in_([RoleEnum.ADMIN, RoleEnum.OWNER]))
    )
    users = result.scalars().all()
    
    data = [
        AdminUserResponse(
            id=u.id,
            username=u.username or "",
            full_name=u.full_name,
            role=u.role,
            is_active=u.is_active
        )
        for u in users
    ]
    return APIResponse(data=data)

@router.post("/", response_model=APIResponse[AdminUserResponse])
async def create_admin(
    payload: AdminUserCreate,
    db: AsyncSession = Depends(get_db),
    owner: User = Depends(get_current_owner)
):
    # Check if username exists
    existing = await db.execute(select(User).where(User.username == payload.username))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Username already exists")

    new_admin = User(
        id=uuid.uuid4(),
        username=payload.username,
        full_name=payload.full_name,
        hashed_password=get_password_hash(payload.password),
        role=payload.role,
        is_active=True
    )
    db.add(new_admin)
    await db.commit()
    await db.refresh(new_admin)
    
    res = AdminUserResponse(
        id=new_admin.id,
        username=new_admin.username or "",
        full_name=new_admin.full_name,
        role=new_admin.role,
        is_active=new_admin.is_active
    )
    return APIResponse(data=res, message="Administrator created successfully")

@router.put("/{admin_id}", response_model=APIResponse[AdminUserResponse])
async def update_admin(
    admin_id: uuid.UUID,
    payload: AdminUserUpdate,
    db: AsyncSession = Depends(get_db),
    owner: User = Depends(get_current_owner)
):
    result = await db.execute(select(User).where(User.id == admin_id))
    admin_user = result.scalar_one_or_none()
    
    if not admin_user:
        raise HTTPException(status_code=404, detail="Admin not found")
        
    if payload.full_name is not None:
        admin_user.full_name = payload.full_name
    if payload.password is not None and len(payload.password) >= 6:
        admin_user.hashed_password = get_password_hash(payload.password)
    if payload.role is not None:
        admin_user.role = payload.role
        
    await db.commit()
    await db.refresh(admin_user)
    
    res = AdminUserResponse(
        id=admin_user.id,
        username=admin_user.username or "",
        full_name=admin_user.full_name,
        role=admin_user.role,
        is_active=admin_user.is_active
    )
    return APIResponse(data=res, message="Administrator updated successfully")

@router.patch("/{admin_id}/status", response_model=APIResponse[dict])
async def change_admin_status(
    admin_id: uuid.UUID,
    payload: AdminUserStatusUpdate,
    db: AsyncSession = Depends(get_db),
    owner: User = Depends(get_current_owner)
):
    result = await db.execute(select(User).where(User.id == admin_id))
    admin_user = result.scalar_one_or_none()
    
    if not admin_user:
        raise HTTPException(status_code=404, detail="Admin not found")
        
    if admin_user.id == owner.id and not payload.is_active:
        raise HTTPException(status_code=400, detail="Cannot deactivate yourself")
        
    if admin_user.role == RoleEnum.OWNER and not payload.is_active:
        # Prevent deactivating the last active OWNER
        owners = await db.execute(select(User).where(User.role == RoleEnum.OWNER, User.is_active == True))
        active_owners = owners.scalars().all()
        if len(active_owners) <= 1:
            raise HTTPException(status_code=400, detail="Cannot deactivate the last active OWNER")
            
    admin_user.is_active = payload.is_active
    await db.commit()
    
    status_text = "activated" if payload.is_active else "deactivated"
    return APIResponse(message=f"Administrator {status_text} successfully")
