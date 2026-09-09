from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from sqlalchemy.orm import joinedload
from pydantic import BaseModel as PydanticBaseModel
from typing import List, Literal
from uuid import UUID
import uuid

from app.db.session import get_db
from app.models.order import Order, OrderItem
from app.models.product import Product
from app.models.user import User
from app.schemas.order import OrderModel
from app.schemas.order_create import OrderCreate
from app.schemas.common import APIResponse
from app.api.deps import get_current_user, get_current_admin
from app.core.config import settings

router = APIRouter()

# Allowed order statuses
ALLOWED_ORDER_STATUSES = {"pending", "processing", "confirmed", "completed", "delivered", "cancelled"}


def calculate_shipping_fee(products_in_order, subtotal: float) -> float:
    """Yetkazib berish narxini hisoblaydi.

    Qoida (hech qanday narx kodda qattiq yozilmagan):
      1. Butun tizimda yetkazib berish o'chirilgan bo'lsa    -> 0
      2. Buyurtma summasi bepul yetkazish chegarasidan katta -> 0
      3. Aks holda: buyurtmadagi mahsulotlar ichidagi ENG KATTA
         delivery_price olinadi (bitta kuryer bir marta boradi).
         has_delivery=False bo'lgan mahsulot narxga qo'shilmaydi.

    Har bir mahsulotning has_delivery va delivery_price qiymatlari
    admin panel orqali belgilanadi.
    """
    if not settings.DELIVERY_ENABLED:
        return 0.0

    if settings.FREE_SHIPPING_THRESHOLD > 0 and subtotal >= settings.FREE_SHIPPING_THRESHOLD:
        return 0.0

    fees = [
        float(p.delivery_price or 0)
        for p in products_in_order
        if getattr(p, "has_delivery", True)
    ]

    if not fees:
        return 0.0

    max_fee = max(fees)
    # Agar hech bir mahsulotga narx belgilanmagan bo'lsa, zaxira qiymatdan foydalanamiz
    if max_fee <= 0:
        return float(settings.SHIPPING_FEE or 0)
    return max_fee


class QuoteItem(PydanticBaseModel):
    product_id: UUID
    quantity: int = 1


class ShippingQuoteRequest(PydanticBaseModel):
    items: List[QuoteItem]


class OrderStatusUpdate(PydanticBaseModel):
    status: Literal["pending", "processing", "confirmed", "completed", "delivered", "cancelled"]


@router.post("", response_model=APIResponse[dict])
async def create_order(
    order_in: OrderCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Verify products and calculate totals server-side
    subtotal = 0.0
    items_to_create = []
    products_in_order = []

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
        products_in_order.append(product)

        items_to_create.append({
            "product_id": product.id,
            "quantity": item.quantity,
            "price_at_time": price
        })

    shipping_fee = calculate_shipping_fee(products_in_order, subtotal)
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
    await db.flush()  # Get order ID

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


@router.post("/shipping-quote", response_model=APIResponse[dict])
async def shipping_quote(
    payload: ShippingQuoteRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Ilova checkout ekranida KO'RSATADIGAN yetkazib berish narxini
    serverdan so'raydi. Shu tufayli ilovada hech qanday narx qattiq
    yozilmaydi va admin o'zgartirishi darhol ilovada ko'rinadi."""
    subtotal = 0.0
    products_in_order = []

    for item in payload.items:
        result = await db.execute(select(Product).where(Product.id == item.product_id))
        product = result.scalar_one_or_none()
        if not product:
            continue
        subtotal += float(product.price) * item.quantity
        products_in_order.append(product)

    shipping_fee = calculate_shipping_fee(products_in_order, subtotal)

    return APIResponse(data={
        "subtotal": subtotal,
        "shipping_fee": shipping_fee,
        "total": subtotal + shipping_fee,
        "free_shipping_threshold": settings.FREE_SHIPPING_THRESHOLD,
        "delivery_enabled": settings.DELIVERY_ENABLED,
    })


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
    orders = result.unique().scalars().all()
    return APIResponse(data=[OrderModel.model_validate(o) for o in orders])


@router.get("/{id}", response_model=APIResponse[OrderModel])
async def get_order(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from app.models.user import RoleEnum
    if current_user.role in [RoleEnum.ADMIN, RoleEnum.OWNER]:
        result = await db.execute(
            select(Order)
            .options(joinedload(Order.user), joinedload(Order.items).joinedload(OrderItem.product))
            .where(Order.id == id)
        )
    else:
        result = await db.execute(
            select(Order)
            .options(joinedload(Order.user), joinedload(Order.items).joinedload(OrderItem.product))
            .where(Order.id == id, Order.user_id == current_user.id)
        )
    order = result.unique().scalar_one_or_none()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    return APIResponse(data=OrderModel.model_validate(order))


@router.patch("/{id}/status", response_model=APIResponse[dict])
async def update_order_status(
    id: UUID,
    payload: OrderStatusUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),  # Only admin/owner
):
    result = await db.execute(
        select(Order)
        .options(joinedload(Order.items))
        .where(Order.id == id)
    )
    order = result.unique().scalar_one_or_none()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    old_status = order.status
    order.status = payload.status

    # If cancelling, restore stock
    if payload.status.lower() == "cancelled" and old_status.lower() != "cancelled":
        await _restore_order_stock(order, db)

    await db.commit()

    return APIResponse(message="Order status updated", data={"status": order.status})


@router.put("/{id}/cancel", response_model=APIResponse[dict])
async def cancel_order(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(Order)
        .options(joinedload(Order.items))
        .where(Order.id == id, Order.user_id == current_user.id)
    )
    order = result.unique().scalar_one_or_none()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if order.status.lower() != 'pending':
        raise HTTPException(status_code=400, detail="Only pending orders can be cancelled")

    order.status = "Cancelled"

    # Restore stock for cancelled order
    await _restore_order_stock(order, db)

    await db.commit()

    return APIResponse(message="Order cancelled successfully", data={"status": order.status})


async def _restore_order_stock(order: Order, db: AsyncSession):
    """Restore product stock when an order is cancelled."""
    for item in order.items:
        await db.execute(
            update(Product)
            .where(Product.id == item.product_id)
            .values(stock=Product.stock + item.quantity)
        )
