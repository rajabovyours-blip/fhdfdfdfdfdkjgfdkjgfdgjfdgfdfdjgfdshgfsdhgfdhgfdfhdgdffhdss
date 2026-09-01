from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from pydantic import BaseModel
from typing import List, Optional
from uuid import UUID
import uuid

from app.db.session import get_db
from app.models.extras import Banner
from app.schemas.common import APIResponse
from app.api.dependencies import get_current_admin
from app.models.user import User

router = APIRouter()

class BannerCreate(BaseModel):
    title: Optional[str] = None
    image_url: str
    link_url: Optional[str] = None
    is_active: bool = True
    order_index: int = 0

class BannerUpdate(BaseModel):
    title: Optional[str] = None
    image_url: Optional[str] = None
    link_url: Optional[str] = None
    is_active: Optional[bool] = None
    order_index: Optional[int] = None

class BannerResponse(BaseModel):
    id: UUID
    title: Optional[str] = None
    image_url: str
    link_url: Optional[str] = None
    is_active: bool
    order_index: int
    
    class Config:
        from_attributes = True

@router.get("", response_model=APIResponse[List[BannerResponse]])
async def get_banners(active_only: bool = False, db: AsyncSession = Depends(get_db)):
    query = select(Banner).order_by(Banner.order_index)
    if active_only:
        query = query.where(Banner.is_active == True)
        
    result = await db.execute(query)
    banners = result.scalars().all()
    return APIResponse(data=[BannerResponse.model_validate(b) for b in banners])

@router.post("", response_model=APIResponse[BannerResponse])
async def create_banner(payload: BannerCreate, db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    banner = Banner(
        id=uuid.uuid4(),
        title=payload.title,
        image_url=payload.image_url,
        link_url=payload.link_url,
        is_active=payload.is_active,
        order_index=payload.order_index
    )
    db.add(banner)
    await db.commit()
    await db.refresh(banner)
    return APIResponse(data=BannerResponse.model_validate(banner))

@router.put("/{id}", response_model=APIResponse[BannerResponse])
async def update_banner(id: str, payload: BannerUpdate, db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    try:
        banner_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(select(Banner).where(Banner.id == banner_id))
    banner = result.scalar_one_or_none()
    
    if not banner:
        raise HTTPException(status_code=404, detail="Banner not found")
    
    if payload.title is not None:
        banner.title = payload.title
    if payload.image_url is not None:
        banner.image_url = payload.image_url
    if payload.link_url is not None:
        banner.link_url = payload.link_url
    if payload.is_active is not None:
        banner.is_active = payload.is_active
    if payload.order_index is not None:
        banner.order_index = payload.order_index
        
    await db.commit()
    await db.refresh(banner)
    return APIResponse(data=BannerResponse.model_validate(banner))

@router.delete("/{id}", response_model=APIResponse[dict])
async def delete_banner(id: str, db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    try:
        banner_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(select(Banner).where(Banner.id == banner_id))
    banner = result.scalar_one_or_none()
    
    if not banner:
        raise HTTPException(status_code=404, detail="Banner not found")
        
    await db.delete(banner)
    await db.commit()
    
    return APIResponse(data={"success": True, "message": "Banner deleted successfully"})

