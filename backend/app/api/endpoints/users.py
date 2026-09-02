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

from typing import Optional

@router.get("", response_model=APIResponse[List[dict]])
async def get_users(role: Optional[str] = None, db: AsyncSession = Depends(get_db)):
    query = select(User)
    if role:
        try:
            role_enum = RoleEnum[role.upper()]
            query = query.where(User.role == role_enum)
        except KeyError:
            pass # ignore invalid roles
            
    result = await db.execute(query)
    users = result.scalars().all()
    
    # We need to add orders_count manually if it's not a hybrid property
    from app.models.order import Order
    from sqlalchemy import func
    
    user_data_list = []
    for u in users:
        count_res = await db.execute(select(func.count(Order.id)).where(Order.user_id == u.id))
        orders_count = count_res.scalar() or 0
        u_dict = UserModel.model_validate(u).model_dump(by_alias=True)
        u_dict["ordersCount"] = orders_count
        u_dict["role"] = u.role.value if hasattr(u.role, 'value') else str(u.role)
        
        provider = getattr(u, 'provider', None)
        if provider == 'google':
            u_dict["authProvider"] = "Google orqali"
        elif provider == 'apple':
            u_dict["authProvider"] = "Apple ID"
        else:
            u_dict["authProvider"] = "SMS orqali"
        user_data_list.append(u_dict)
        
    return APIResponse(data=user_data_list)

from pydantic import BaseModel as PydanticBaseModel

class UserMeUpdate(PydanticBaseModel):
    full_name: Optional[str] = None
    email: Optional[str] = None
    avatar_url: Optional[str] = None
    preferred_language: Optional[str] = None

@router.put("/me", response_model=APIResponse[UserModel])
async def update_me(payload: UserMeUpdate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    if payload.full_name is not None:
        current_user.full_name = payload.full_name
    if payload.email is not None:
        current_user.email = payload.email
    if payload.avatar_url is not None:
        current_user.avatar_url = payload.avatar_url
    if payload.preferred_language is not None:
        current_user.preferred_language = payload.preferred_language
        
    await db.commit()
    await db.refresh(current_user)
    return APIResponse(data=UserModel.model_validate(current_user))

class UserUpdate(PydanticBaseModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    is_active: Optional[bool] = None

from app.api.dependencies import get_current_admin

@router.put("/{id}", response_model=APIResponse[UserModel])
async def update_user(id: str, payload: UserUpdate, db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    from uuid import UUID
    try:
        user_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    if payload.full_name is not None:
        user.full_name = payload.full_name
    if payload.phone_number is not None:
        user.phone = payload.phone_number
    if payload.is_active is not None:
        user.is_active = payload.is_active
        
    await db.commit()
    await db.refresh(user)
    
    return APIResponse(data=UserModel.model_validate(user))

@router.delete("/me", response_model=APIResponse[dict])
async def delete_me(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Delete the user. Orders associated with the user might need to be anonymized or cascade deleted depending on DB schema.
    # Assuming SQLAlchemy relationships handle the cascading or nullifying.
    await db.delete(current_user)
    await db.commit()
    return APIResponse(data={"message": "Hisobingiz muvaffaqiyatli o'chirildi"})
