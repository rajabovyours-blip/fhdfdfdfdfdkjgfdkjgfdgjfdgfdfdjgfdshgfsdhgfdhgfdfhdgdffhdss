from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from sqlalchemy.orm import joinedload
from typing import List
from uuid import UUID
import uuid

from app.db.session import get_db
from app.models.order import Order, OrderItem
from app.models.product import Product
from app.models.user import User
from app.schemas.order import OrderModel
from app.schemas.order_create import OrderCreate
from app.schemas.common import APIResponse
from app.api.deps import get_current_user

router = APIRouter()

@router.post("", response_model=APIResponse[dict])
async def create_order(
    order_in: OrderCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Phase 8: Verify products and calculate totals server-side
    subtotal = 0.0
    items_to_create = []
    
    for item in order_in.items:
        result = await db.execute(select(Product).where(Product.id == item.product_id))
        product = result.scalar_one_or_none()
        
        if not product:
            raise HTTPException(status_code=404, detail=f"Product {item.product_id} not found")
        stmt = (
            update(Product)
            .where(Product.id == item.product_id)
            .where(Product.stock >= item.quantity)
            .values(stock=Product.stock - item.quantity)
        )
        res = await db.execute(stmt)
        if res.rowcount == 0:
            raise HTTPException(status_code=400, detail=f"Insufficient stock for {product.name.get('uz', product.name.get('en', 'product'))}")
        
        price = float(product.price)
        subtotal += price * item.quantity
        
        items_to_create.append({
            "product_id": product.id,
            "quantity": item.quantity,
            "price_at_time": price
        })
        
    shipping_fee = 15000.0 if subtotal < 500000 else 0.0
    total = subtotal + shipping_fee
    
    order = Order(
        user_id=current_user.id,
        order_number=f"ORD-{uuid.uuid4().hex[:8].upper()}",
        subtotal=subtotal,
        shipping_fee=shipping_fee,
        total=total,
        delivery_address=order_in.delivery_address,
        payment_method=order_in.payment_method,
        delivery_method=order_in.delivery_method,
        customer_notes=order_in.customer_notes
    )
    db.add(order)
    await db.flush() # Get order ID
    
    for item_data in items_to_create:
        order_item = OrderItem(
            order_id=order.id,
            product_id=item_data["product_id"],
            quantity=item_data["quantity"],
            price_at_time=item_data["price_at_time"]
        )
        db.add(order_item)
        
    await db.commit()
    
    return APIResponse(message="Order created successfully", data={"order_id": str(order.id)})

@router.get("", response_model=APIResponse[List[OrderModel]])
@router.get("/my", response_model=APIResponse[List[OrderModel]])
async def get_orders(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from app.models.user import RoleEnum
    if current_user.role in [RoleEnum.ADMIN, RoleEnum.OWNER]:
        result = await db.execute(
            select(Order)
            .options(joinedload(Order.user), joinedload(Order.items).joinedload(OrderItem.product))
            .order_by(Order.created_at.desc())
        )
    else:
        result = await db.execute(
            select(Order)
            .options(joinedload(Order.user), joinedload(Order.items).joinedload(OrderItem.product))
            .where(Order.user_id == current_user.id)
            .order_by(Order.created_at.desc())
        )
    orders = result.scalars().all()
    return APIResponse(data=[OrderModel.model_validate(o) for o in orders])

@router.get("/{id}", response_model=APIResponse[OrderModel])
async def get_order(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(Order)
        .options(joinedload(Order.user), joinedload(Order.items).joinedload(OrderItem.product))
        .where(Order.id == id, Order.user_id == current_user.id)
    )
    order = result.scalar_one_or_none()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    return APIResponse(data=OrderModel.model_validate(order))

from pydantic import BaseModel as PydanticBaseModel
class OrderStatusUpdate(PydanticBaseModel):
    status: str

@router.patch("/{id}/status", response_model=APIResponse[dict])
async def update_order_status(
    id: UUID,
    payload: OrderStatusUpdate,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Order).where(Order.id == id))
    order = result.scalar_one_or_none()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    order.status = payload.status
    await db.commit()
    
    return APIResponse(message="Order status updated", data={"status": order.status})

@router.put("/{id}/cancel", response_model=APIResponse[dict])
async def cancel_order(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(Order).where(Order.id == id, Order.user_id == current_user.id)
    )
    order = result.scalar_one_or_none()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    if order.status.lower() != 'pending':
        raise HTTPException(status_code=400, detail="Only pending orders can be cancelled")
        
    order.status = "Cancelled"
    
    # We should restore stock if needed, but for now just update status
    
    await db.commit()
    
    return APIResponse(message="Order cancelled successfully", data={"status": order.status})
