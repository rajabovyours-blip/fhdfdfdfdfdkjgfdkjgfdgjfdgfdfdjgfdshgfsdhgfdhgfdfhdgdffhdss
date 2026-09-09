from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, or_, cast, String, func
from sqlalchemy.orm import joinedload
from pydantic import BaseModel as PydanticBaseModel
from typing import List, Literal, Optional
from datetime import datetime
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
from app.api.endpoints.settings import load_shipping_settings

router = APIRouter()

ALLOWED_ORDER_STATUSES = {"pending", "processing", "confirmed", "completed", "delivered", "cancelled"}


def calculate_shipping_fee(products_in_order, subtotal: float, cfg: dict) -> float:
    """Yetkazib berish narxini hisoblaydi.

    Qoida (kodda hech qanday narx qattiq yozilmagan):
      1. Yetkazib berish o'chirilgan bo'lsa                 -> 0
      2. Summa bepul yetkazish chegarasidan katta bo'lsa     -> 0
      3. Aks holda mahsulotlar ichidagi ENG KATTA delivery_price
         (bitta kuryer bir marta boradi). has_delivery=False
         bo'lgan mahsulot hisobga olinmaydi.

    cfg — admin panelda belgilangan sozlamalar (settings.load_shipping_settings).
    """
    if not cfg.get("delivery_enabled", True):
        return 0.0

    threshold = float(cfg.get("free_shipping_threshold") or 0)
    if threshold > 0 and subtotal >= threshold:
        return 0.0

    fees = [
        float(p.delivery_price or 0)
        for p in products_in_order
        if getattr(p, "has_delivery", True)
    ]
    if not fees:
        return 0.0

    max_fee = max(fees)
    if max_fee <= 0:
        return float(cfg.get("shipping_fee") or 0)
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
            raise HTTPException(
                status_code=400,
                detail=f"Insufficient stock for {product.name.get('uz', product.name.get('en', 'product'))}"
            )

        price = float(product.price)
        subtotal += price * item.quantity
        products_in_order.append(product)

        items_to_create.append({
            "product_id": product.id,
            "quantity": item.quantity,
            "price_at_time": price
        })

    cfg = await load_shipping_settings(db)
    shipping_fee = calculate_shipping_fee(products_in_order, subtotal, cfg)
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
    await db.flush()

    for item_data in items_to_create:
        db.add(OrderItem(
            order_id=order.id,
            product_id=item_data["product_id"],
            quantity=item_data["quantity"],
            price_at_time=item_data["price_at_time"]
        ))

    await db.commit()
    return APIResponse(message="Order created successfully", data={"order_id": str(order.id)})


@router.post("/shipping-quote", response_model=APIResponse[dict])
async def shipping_quote(
    payload: ShippingQuoteRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Ilova checkout ekranida KO'RSATADIGAN narxni serverdan so'raydi."""
    subtotal = 0.0
    products_in_order = []

    for item in payload.items:
        result = await db.execute(select(Product).where(Product.id == item.product_id))
        product = result.scalar_one_or_none()
        if not product:
            continue
        subtotal += float(product.price) * item.quantity
        products_in_order.append(product)

    cfg = await load_shipping_settings(db)
    shipping_fee = calculate_shipping_fee(products_in_order, subtotal, cfg)

    return APIResponse(data={
        "subtotal": subtotal,
        "shipping_fee": shipping_fee,
        "total": subtotal + shipping_fee,
        "free_shipping_threshold": cfg["free_shipping_threshold"],
        "delivery_enabled": cfg["delivery_enabled"],
    })


@router.get("", response_model=APIResponse[List[OrderModel]])
@router.get("/my", response_model=APIResponse[List[OrderModel]])
async def get_orders(
    status: Optional[str] = Query(None, description="Holat bo'yicha filtr"),
    payment_status: Optional[str] = Query(None, description="To'lov holati bo'yicha filtr"),
    date_from: Optional[str] = Query(None, description="YYYY-MM-DD"),
    date_to: Optional[str] = Query(None, description="YYYY-MM-DD"),
    search: Optional[str] = Query(None, description="Buyurtma raqami yoki mijoz"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from app.models.user import RoleEnum
    is_admin = current_user.role in [RoleEnum.ADMIN, RoleEnum.OWNER]

    query = (
        select(Order)
        .options(joinedload(Order.user), joinedload(Order.items).joinedload(OrderItem.product))
    )

    if not is_admin:
        query = query.where(Order.user_id == current_user.id)
    else:
        # Filtrlar faqat admin uchun ma'noga ega
        if status:
            query = query.where(func.lower(Order.status) == status.lower())
        if payment_status:
            query = query.where(func.lower(Order.payment_status) == payment_status.lower())
        if date_from:
            try:
                query = query.where(Order.created_at >= datetime.fromisoformat(date_from))
            except ValueError:
                pass
        if date_to:
            try:
                end = datetime.fromisoformat(date_to).replace(hour=23, minute=59, second=59)
                query = query.where(Order.created_at <= end)
            except ValueError:
                pass
        if search:
            term = f"%{search.strip()}%"
            query = query.outerjoin(User, User.id == Order.user_id).where(
                or_(
                    Order.order_number.ilike(term),
                    cast(Order.id, String).ilike(term),
                    User.full_name.ilike(term),
                    User.phone.ilike(term),
                )
            )

    query = query.order_by(Order.created_at.desc())

    result = await db.execute(query)
    orders = result.unique().scalars().all()
    return APIResponse(data=[OrderModel.model_validate(o) for o in orders])


@router.get("/{id}", response_model=APIResponse[OrderModel])
async def get_order(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from app.models.user import RoleEnum
    base = (
        select(Order)
        .options(joinedload(Order.user), joinedload(Order.items).joinedload(OrderItem.product))
    )
    if current_user.role in [RoleEnum.ADMIN, RoleEnum.OWNER]:
        result = await db.execute(base.where(Order.id == id))
    else:
        result = await db.execute(base.where(Order.id == id, Order.user_id == current_user.id))

    order = result.unique().scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    return APIResponse(data=OrderModel.model_validate(order))


@router.patch("/{id}/status", response_model=APIResponse[dict])
async def update_order_status(
    id: UUID,
    payload: OrderStatusUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    result = await db.execute(
        select(Order).options(joinedload(Order.items)).where(Order.id == id)
    )
    order = result.unique().scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    old_status = order.status
    order.status = payload.status

    if payload.status.lower() == "cancelled" and (old_status or "").lower() != "cancelled":
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
        select(Order).options(joinedload(Order.items))
        .where(Order.id == id, Order.user_id == current_user.id)
    )
    order = result.unique().scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if (order.status or "").lower() != 'pending':
        raise HTTPException(status_code=400, detail="Only pending orders can be cancelled")

    order.status = "Cancelled"
    await _restore_order_stock(order, db)
    await db.commit()

    return APIResponse(message="Order cancelled successfully", data={"status": order.status})


async def _restore_order_stock(order: Order, db: AsyncSession):
    """Buyurtma bekor qilinganda mahsulot zaxirasini qaytaradi."""
    for item in order.items:
        await db.execute(
            update(Product)
            .where(Product.id == item.product_id)
            .values(stock=Product.stock + item.quantity)
        )
