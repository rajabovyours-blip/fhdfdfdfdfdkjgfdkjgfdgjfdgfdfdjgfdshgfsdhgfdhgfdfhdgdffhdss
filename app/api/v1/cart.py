from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from pydantic import BaseModel
import uuid
from app.core.database import get_db
from app.schemas.orders import CartResponse, CartItemRequest, AddressRequest, AddressResponse
from app.services.orders_service import OrdersService
from app.api.dependencies import get_current_user
from app.models.users import User

cart_router = APIRouter()

@cart_router.get("", response_model=dict)
async def get_cart(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    cart = await service.get_or_create_cart(current_user.id)
    return {"data": CartResponse.model_validate(cart).model_dump(mode='json')}

@cart_router.post("/add", response_model=dict)
async def add_to_cart(payload: CartItemRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    await service.add_to_cart(current_user.id, payload)
    return {"data": {"message": "Item added to cart"}}

@cart_router.post("/update", response_model=dict)
async def update_cart(payload: CartItemRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    await service.update_cart_item(current_user.id, payload)
    return {"data": {"message": "Cart updated"}}

class RemoveCartRequest(BaseModel):
    product_id: uuid.UUID

@cart_router.delete("/remove", response_model=dict)
async def remove_from_cart(payload: RemoveCartRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    await service.remove_from_cart(current_user.id, payload.product_id)
    return {"data": {"message": "Item removed from cart"}}


address_router = APIRouter()

@address_router.get("", response_model=dict)
async def get_addresses(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    addresses = await service.get_addresses(current_user.id)
    res = [AddressResponse.model_validate(a).model_dump(mode='json') for a in addresses]
    return {"data": res}

@address_router.post("", response_model=dict)
async def add_address(payload: AddressRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    addr = await service.add_address(current_user.id, payload)
    return {"data": AddressResponse.model_validate(addr).model_dump(mode='json')}
