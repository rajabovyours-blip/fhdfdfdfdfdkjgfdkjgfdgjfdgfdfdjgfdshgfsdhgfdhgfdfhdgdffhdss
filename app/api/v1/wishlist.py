from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
import uuid
from app.core.database import get_db
from app.schemas.marketplace import ProductSummary
from app.services.marketplace_service import MarketplaceService
from app.api.dependencies import get_current_user
from app.models.users import User

router = APIRouter()

class WishlistRequest(BaseModel):
    product_id: uuid.UUID

@router.get("", response_model=dict)
async def get_wishlist(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = MarketplaceService(db)
    products = await service.get_wishlist(current_user.id)
    res = [ProductSummary.model_validate(p).model_dump(mode='json') for p in products]
    return {"data": res}

@router.post("", response_model=dict)
async def add_to_wishlist(payload: WishlistRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = MarketplaceService(db)
    await service.add_to_wishlist(current_user.id, payload.product_id)
    return {"data": {"message": "Added to wishlist"}}

@router.delete("/{product_id}", response_model=dict)
async def remove_from_wishlist(product_id: uuid.UUID, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = MarketplaceService(db)
    await service.remove_from_wishlist(current_user.id, product_id)
    return {"data": {"message": "Removed from wishlist"}}
