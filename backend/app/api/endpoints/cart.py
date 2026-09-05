from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete as sa_delete
from sqlalchemy.orm import selectinload
from sqlalchemy.exc import IntegrityError
from typing import List
from uuid import UUID

from app.db.session import get_db
from app.models.cart import CartItem
from app.models.user import User
from app.schemas.cart import CartItemModel, CartItemCreate, CartItemUpdate
from app.schemas.common import APIResponse
from app.api.deps import get_current_user

router = APIRouter()

@router.get("", response_model=APIResponse[List[CartItemModel]])
async def get_cart(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(CartItem)
        .options(selectinload(CartItem.product))
        .where(CartItem.user_id == current_user.id)
    )
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
        select(CartItem)
        .options(selectinload(CartItem.product))
        .where(
            CartItem.user_id == current_user.id,
            CartItem.product_id == item_in.product_id
        )
    )
    existing_item = result.scalar_one_or_none()
    
    if existing_item:
        existing_item.quantity += item_in.quantity
        await db.commit()
        # Re-fetch with relationships loaded
        result = await db.execute(
            select(CartItem)
            .options(selectinload(CartItem.product))
            .where(CartItem.id == existing_item.id)
        )
        existing_item = result.scalar_one()
        return APIResponse(data=CartItemModel.model_validate(existing_item))
        
    new_item = CartItem(
        user_id=current_user.id,
        product_id=item_in.product_id,
        quantity=item_in.quantity
    )
    db.add(new_item)
    try:
        await db.commit()
    except IntegrityError:
        # Race condition: another request created the row between our SELECT and INSERT
        await db.rollback()
        result = await db.execute(
            select(CartItem)
            .options(selectinload(CartItem.product))
            .where(
                CartItem.user_id == current_user.id,
                CartItem.product_id == item_in.product_id
            )
        )
        existing_item = result.scalar_one()
        existing_item.quantity += item_in.quantity
        await db.commit()
        result = await db.execute(
            select(CartItem)
            .options(selectinload(CartItem.product))
            .where(CartItem.id == existing_item.id)
        )
        existing_item = result.scalar_one()
        return APIResponse(data=CartItemModel.model_validate(existing_item))

    # Fetch with product loaded
    result = await db.execute(
        select(CartItem)
        .options(selectinload(CartItem.product))
        .where(CartItem.id == new_item.id)
    )
    new_item_loaded = result.scalar_one()
    return APIResponse(data=CartItemModel.model_validate(new_item_loaded))

@router.post("/ensure", response_model=APIResponse[CartItemModel])
async def ensure_in_cart(
    item_in: CartItemCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Idempotent add: ensures product is in cart with at least the given quantity.
    If already present, does NOT increment. Used by Buy Now.
    """
    result = await db.execute(
        select(CartItem)
        .options(selectinload(CartItem.product))
        .where(
            CartItem.user_id == current_user.id,
            CartItem.product_id == item_in.product_id
        )
    )
    existing_item = result.scalar_one_or_none()
    
    if existing_item:
        # Already in cart — do not modify quantity. Just return existing.
        return APIResponse(data=CartItemModel.model_validate(existing_item))
    
    # Not in cart — create with requested quantity
    new_item = CartItem(
        user_id=current_user.id,
        product_id=item_in.product_id,
        quantity=item_in.quantity
    )
    db.add(new_item)
    try:
        await db.commit()
    except IntegrityError:
        # Race condition: another concurrent request just added the same product
        await db.rollback()
        result = await db.execute(
            select(CartItem)
            .options(selectinload(CartItem.product))
            .where(
                CartItem.user_id == current_user.id,
                CartItem.product_id == item_in.product_id
            )
        )
        existing_item = result.scalar_one()
        return APIResponse(data=CartItemModel.model_validate(existing_item))
    
    result = await db.execute(
        select(CartItem)
        .options(selectinload(CartItem.product))
        .where(CartItem.id == new_item.id)
    )
    new_item_loaded = result.scalar_one()
    return APIResponse(data=CartItemModel.model_validate(new_item_loaded))

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

@router.delete("", response_model=APIResponse[dict])
async def clear_cart(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    await db.execute(
        sa_delete(CartItem).where(CartItem.user_id == current_user.id)
    )
    await db.commit()
    return APIResponse(message="Cart cleared successfully")

@router.put("/items/{id}", response_model=APIResponse[CartItemModel])
async def update_cart_item(
    id: UUID,
    item_in: CartItemUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(CartItem).options(selectinload(CartItem.product)).where(CartItem.id == id, CartItem.user_id == current_user.id)
    )
    item = result.scalar_one_or_none()
    
    if not item:
        raise HTTPException(status_code=404, detail="Item not found in cart")
        
    item.quantity = item_in.quantity
    await db.commit()
    
    # Refresh drops relationships so let's fetch again
    result = await db.execute(
        select(CartItem).options(selectinload(CartItem.product)).where(CartItem.id == id)
    )
    item_loaded = result.scalar_one()
    
    return APIResponse(data=CartItemModel.model_validate(item_loaded))
