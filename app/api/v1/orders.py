from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
import uuid
from app.core.database import get_db
from app.schemas.orders import CheckoutRequest, OrderSummary, OrderDetail
from app.services.orders_service import OrdersService
from app.api.dependencies import get_current_user
from app.models.users import User

checkout_router = APIRouter()

@checkout_router.post("/order", response_model=dict)
async def checkout_order(payload: CheckoutRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    order = await service.checkout(current_user.id, payload)
    return {"data": OrderSummary.model_validate(order).model_dump(mode='json')}


orders_router = APIRouter()

@orders_router.get("", response_model=dict)
async def get_orders(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    orders = await service.get_orders(current_user.id)
    res = [OrderSummary.model_validate(o).model_dump(mode='json') for o in orders]
    return {"data": res}

@orders_router.get("/{order_id}", response_model=dict)
async def get_order_detail(order_id: uuid.UUID, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    service = OrdersService(db)
    order = await service.get_order_detail(current_user.id, order_id)
    return {"data": OrderDetail.model_validate(order).model_dump(mode='json')}
