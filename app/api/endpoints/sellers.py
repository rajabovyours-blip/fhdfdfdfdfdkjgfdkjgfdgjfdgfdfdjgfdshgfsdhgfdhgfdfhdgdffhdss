from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from uuid import UUID

from app.db.session import get_db
from app.models.user import User, RoleEnum
from app.models.product import Product
from app.models.review import Review
from app.schemas.product import ProductModel
from app.schemas.common import APIResponse
from app.api.deps import get_current_user

router = APIRouter()

@router.get("/{seller_id}/products", response_model=APIResponse[List[ProductModel]])
async def get_seller_products(
    seller_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Product).where(Product.seller_id == seller_id))
    products = result.scalars().all()
    return APIResponse(data=[ProductModel.model_validate(p) for p in products])

@router.get("/{seller_id}/reviews", response_model=APIResponse[list])
async def get_seller_reviews(
    seller_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    # Join products and reviews where product.seller_id == seller_id
    result = await db.execute(
        select(Review).join(Product).where(Product.seller_id == seller_id)
    )
    reviews = result.scalars().all()
    # Assuming we create a StoreReview schema later, returning list of dicts for now
    return APIResponse(data=[])
