from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from uuid import UUID

from app.db.session import get_db
from app.models.cart import CartItem
from app.models.user import User
from app.schemas.cart import CartItemModel, CartItemCreate
from app.schemas.common import APIResponse
from app.api.deps import get_current_user

router = APIRouter()

@router.get("/", response_model=APIResponse[List[CartItemModel]])
async def get_cart(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(select(CartItem).where(CartItem.user_id == current_user.id))
    items = result.scalars().all()
    return APIResponse(data=[CartItemModel.model_validate(item) for item in items])

@router.post("/items", response_model=APIResponse[CartItemModel])
async def add_to_cart(
    item_in: CartItemCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Check if product exists and if it's already in the cart
    result = await db.execute(
        select(CartItem).where(
            CartItem.user_id == current_user.id,
            CartItem.product_id == item_in.product_id
        )
    )
    existing_item = result.scalar_one_or_none()
    
    if existing_item:
        existing_item.quantity += item_in.quantity
        await db.commit()
        await db.refresh(existing_item)
        return APIResponse(data=CartItemModel.model_validate(existing_item))
        
    new_item = CartItem(
        user_id=current_user.id,
        product_id=item_in.product_id,
        quantity=item_in.quantity
    )
    db.add(new_item)
    await db.commit()
    await db.refresh(new_item)
    return APIResponse(data=CartItemModel.model_validate(new_item))

@router.delete("/items/{id}", response_model=APIResponse[dict])
async def remove_from_cart(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(CartItem).where(CartItem.id == id, CartItem.user_id == current_user.id)
    )
    item = result.scalar_one_or_none()
    
    if not item:
        raise HTTPException(status_code=404, detail="Item not found in cart")
        
    await db.delete(item)
    await db.commit()
    
    return APIResponse(message="Item removed successfully")
