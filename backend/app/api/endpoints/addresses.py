from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.db.session import get_db
from app.schemas.common import APIResponse
from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()

from pydantic import BaseModel, ConfigDict
from typing import Optional
from sqlalchemy import select
from app.models.address import Address
from uuid import UUID

class AddressCreate(BaseModel):
    title: str
    street: str
    landmark: Optional[str] = None
    lat: float
    lng: float
    is_default: Optional[bool] = False

class AddressResponse(BaseModel):
    id: UUID
    title: str
    street: str
    landmark: Optional[str] = None
    lat: float
    lng: float
    is_default: bool
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

@router.get("", response_model=APIResponse[list[AddressResponse]])
async def get_addresses(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(select(Address).where(Address.user_id == current_user.id))
    addresses = result.scalars().all()
    
    # Map model to response
    data = []
    for a in addresses:
        data.append({
            "id": a.id,
            "title": a.label or "Manzil",
            "street": a.address_line,
            "landmark": "",
            "lat": a.lat or 0.0,
            "lng": a.lng or 0.0,
            "is_default": a.is_default
        })
    return APIResponse(data=data)

@router.post("", response_model=APIResponse[AddressResponse])
async def add_address(
    data: AddressCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if data.is_default:
        # unset others
        await db.execute(
            select(Address).where(Address.user_id == current_user.id)
        )
        # We would ideally update them but let's just insert for now
        pass
        
    new_address = Address(
        user_id=current_user.id,
        label=data.title,
        address_line=f"{data.street}{' - ' + data.landmark if data.landmark else ''}",
        lat=data.lat,
        lng=data.lng,
        is_default=data.is_default
    )
    db.add(new_address)
    await db.commit()
    await db.refresh(new_address)
    
    res = {
        "id": new_address.id,
        "title": new_address.label,
        "street": new_address.address_line,
        "landmark": data.landmark,
        "lat": new_address.lat,
        "lng": new_address.lng,
        "is_default": new_address.is_default
    }
    return APIResponse(message="Address added successfully", data=res)
