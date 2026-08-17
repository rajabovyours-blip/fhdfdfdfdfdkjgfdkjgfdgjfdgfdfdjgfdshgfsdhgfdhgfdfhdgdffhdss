from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.schemas.common import APIResponse
from app.schemas.order_create import OrderCreate
from app.api.deps import get_current_user
from app.models.user import User
from app.api.endpoints.orders import create_order

router = APIRouter()

@router.post("/order", response_model=APIResponse[dict])
async def place_order(
    order_in: OrderCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await create_order(order_in, db, current_user)
