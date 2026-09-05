from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, timedelta
from typing import List

from app.db.session import get_db
from app.models.user import User, RoleEnum
from app.models.product import Product
from app.models.category import Category
from app.models.order import Order, OrderItem
from app.schemas.common import APIResponse
from app.api.dependencies import get_current_admin

router = APIRouter()

COMPLETED_STATUSES = ["delivered", "paid", "completed"]
MONTH_NAMES_UZ = ["Yan", "Fev", "Mar", "Apr", "May", "Iyun", "Iyul", "Avg", "Sen", "Okt", "Noy", "Dek"]


def _localized_name(name_field) -> str:
    """Product/Category name is stored as a JSON dict like {"uz": "...", "ru": "..."}."""
    if isinstance(name_field, dict):
        return name_field.get("uz") or name_field.get("ru") or name_field.get("en") or "Noma'lum"
    return str(name_field) if name_field else "Noma'lum"


def _last_12_months() -> List[tuple]:
    """List of 12 (year, month) tuples, oldest first, ending with the current month."""
    now = datetime.utcnow()
    months = []
    y, m = now.year, now.month
    for _ in range(12):
        months.append((y, m))
        m -= 1
        if m == 0:
            m = 12
            y -= 1
    return list(reversed(months))


@router.get("/dashboard", response_model=APIResponse[dict])
async def get_admin_dashboard(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    twelve_months_ago = datetime.utcnow() - timedelta(days=365)
    ninety_days_ago = datetime.utcnow() - timedelta(days=90)
    months = _last_12_months()

    # ---- Basic counts ----
    total_users = (await db.execute(
        select(func.count()).select_from(User).where(User.role == RoleEnum.USER)
    )).scalar() or 0
    total_products = (await db.execute(select(func.count()).select_from(Product))).scalar() or 0
    total_categories = (await db.execute(select(func.count()).select_from(Category))).scalar() or 0
    total_orders = (await db.execute(select(func.count()).select_from(Order))).scalar() or 0

    # ---- Revenue & average order value (completed orders only) ----
    completed_totals = [
        row[0] or 0 for row in
        (await db.execute(select(Order.total).where(func.lower(Order.status).in_(COMPLETED_STATUSES)))).all()
    ]
    total_revenue = float(sum(completed_totals))
    completed_orders_count = len(completed_totals)
    average_order_value = float(total_revenue / completed_orders_count) if completed_orders_count else 0.0

    # ---- Today's orders ----
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_orders_count = (await db.execute(
        select(func.count()).select_from(Order).where(Order.created_at >= today_start)
    )).scalar() or 0

    # ---- Order status distribution ----
    status_rows = (await db.execute(select(Order.status, func.count(Order.id)).group_by(Order.status))).all()
    order_status_distribution = [{"status": s or "Noma'lum", "count": c} for s, c in status_rows]

    # ---- Revenue trend: rolling last 12 months ----
    revenue_by_month = {(y, m): 0.0 for y, m in months}
    for created_at, amount in (await db.execute(
        select(Order.created_at, Order.total).where(
            Order.created_at >= twelve_months_ago,
            func.lower(Order.status).in_(COMPLETED_STATUSES)
        )
    )).all():
        if created_at and (created_at.year, created_at.month) in revenue_by_month:
            revenue_by_month[(created_at.year, created_at.month)] += float(amount or 0)
    monthly_sales = [
        {"month": f"{MONTH_NAMES_UZ[m-1]} {y}", "revenue": revenue_by_month[(y, m)]}
        for y, m in months
    ]

    # ---- New customers trend: rolling last 12 months ----
    customers_by_month = {(y, m): 0 for y, m in months}
    for (created_at,) in (await db.execute(
        select(User.created_at).where(User.role == RoleEnum.USER, User.created_at >= twelve_months_ago)
    )).all():
        if created_at and (created_at.year, created_at.month) in customers_by_month:
            customers_by_month[(created_at.year, created_at.month)] += 1
    new_customers_trend = [
        {"month": f"{MONTH_NAMES_UZ[m-1]} {y}", "count": customers_by_month[(y, m)]}
        for y, m in months
    ]

    # ---- Top 10 products by quantity sold (last 90 days) ----
    top_products = [
        {
            "product_id": str(pid), "name": _localized_name(name),
            "quantity_sold": int(qty or 0), "revenue": float(rev or 0),
        }
        for pid, name, qty, rev in (await db.execute(
            select(
                Product.id, Product.name,
                func.sum(OrderItem.quantity).label("qty"),
                func.sum(OrderItem.quantity * OrderItem.price_at_time).label("rev"),
            )
            .join(OrderItem, OrderItem.product_id == Product.id)
            .join(Order, Order.id == OrderItem.order_id)
            .where(func.lower(Order.status).in_(COMPLETED_STATUSES), Order.created_at >= ninety_days_ago)
            .group_by(Product.id, Product.name)
            .order_by(func.sum(OrderItem.quantity).desc())
            .limit(10)
        )).all()
    ]

    # ---- Sales by category (last 90 days) ----
    sales_by_category = [
        {"category_id": str(cid), "name": _localized_name(name), "revenue": float(rev or 0)}
        for cid, name, rev in (await db.execute(
            select(
                Category.id, Category.name,
                func.sum(OrderItem.quantity * OrderItem.price_at_time).label("rev"),
            )
            .join(Product, Product.category_id == Category.id)
            .join(OrderItem, OrderItem.product_id == Product.id)
            .join(Order, Order.id == OrderItem.order_id)
            .where(func.lower(Order.status).in_(COMPLETED_STATUSES), Order.created_at >= ninety_days_ago)
            .group_by(Category.id, Category.name)
            .order_by(func.sum(OrderItem.quantity * OrderItem.price_at_time).desc())
            .limit(10)
        )).all()
    ]

    # ---- Payment method breakdown (completed orders) ----
    payment_method_breakdown = [
        {"method": method or "Noma'lum", "count": count, "revenue": float(revenue or 0)}
        for method, count, revenue in (await db.execute(
            select(Order.payment_method, func.count(Order.id), func.sum(Order.total))
            .where(func.lower(Order.status).in_(COMPLETED_STATUSES))
            .group_by(Order.payment_method)
        )).all()
    ]

    # ---- Low stock products (stock <= 5) ----
    low_stock_products = [
        {"product_id": str(pid), "name": _localized_name(name), "stock": stock}
        for pid, name, stock in (await db.execute(
            select(Product.id, Product.name, Product.stock)
            .where(Product.stock <= 5)
            .order_by(Product.stock.asc())
            .limit(20)
        )).all()
    ]

    return APIResponse(data={
        "total_users": total_users,
        "total_products": total_products,
        "total_categories": total_categories,
        "total_orders": total_orders,
        "total_revenue": total_revenue,
        "average_order_value": average_order_value,
        "today_orders_count": today_orders_count,
        "order_status_distribution": order_status_distribution,
        "monthly_sales": monthly_sales,
        "new_customers_trend": new_customers_trend,
        "top_products": top_products,
        "sales_by_category": sales_by_category,
        "payment_method_breakdown": payment_method_breakdown,
        "low_stock_products": low_stock_products,
    })


@router.get("/reports", response_model=APIResponse[list])
async def get_admin_reports(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    return APIResponse(data=[])
