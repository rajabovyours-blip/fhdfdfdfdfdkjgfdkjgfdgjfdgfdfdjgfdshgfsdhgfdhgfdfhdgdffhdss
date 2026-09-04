from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.extras import Wishlist
from app.models.product import Product
from app.models.user import User
from app.schemas.common import APIResponse
from app.schemas.product import ProductModel

router = APIRouter()


class WishlistItemCreate(BaseModel):
    product_id: UUID


@router.get("", response_model=APIResponse[List[ProductModel]])
async def get_wishlist(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Product)
        .join(Wishlist, Wishlist.product_id == Product.id)
        .where(Wishlist.user_id == current_user.id)
        .order_by(Wishlist.created_at.desc())
    )
    return APIResponse(data=[ProductModel.model_validate(product) for product in result.scalars().all()])


@router.post("", response_model=APIResponse[dict], status_code=status.HTTP_201_CREATED)
async def add_to_wishlist(
    item: WishlistItemCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    product = await db.get(Product, item.product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    existing = await db.get(Wishlist, (current_user.id, item.product_id))
    if existing:
        return APIResponse(data={"product_id": str(item.product_id)}, message="Already in wishlist")

    db.add(Wishlist(user_id=current_user.id, product_id=item.product_id))
    await db.commit()
    return APIResponse(data={"product_id": str(item.product_id)}, message="Added to wishlist")


@router.delete("/{product_id}", response_model=APIResponse[dict])
async def remove_from_wishlist(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    item = await db.get(Wishlist, (current_user.id, product_id))
    if not item or item.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Product not found in wishlist")

    await db.delete(item)
    await db.commit()
    return APIResponse(data={"product_id": str(product_id)}, message="Removed from wishlist")
