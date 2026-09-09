"""Admin dashboard analitikasi.

Barcha hisob-kitob SERVER tomonida bajariladi va bitta so'rovda qaytadi.
Frontend faqat chizadi — matematika bu yerda.
"""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, case, cast, Text
from datetime import datetime, date, timedelta
from typing import Optional

from app.db.session import get_db
from app.models.order import Order, OrderItem
from app.models.user import User, RoleEnum
from app.models.product import Product
from app.models.category import Category
from app.api.dependencies import get_current_admin

router = APIRouter()

PAID = "paid"


def _pct_change(current: float, previous: float) -> Optional[float]:
    """Foizdagi o'zgarish. Oldingi davr 0 bo'lsa None (bo'lish mumkin emas)."""
    if previous == 0:
        return None
    return round(((current - previous) / previous) * 100, 1)


def _localized(name_json, lang: str = "uz") -> str:
    # Postgres json ustuni GROUP BY qila olmagani uchun uni matn sifatida
    # olamiz — shuning uchun bu yerda satrni ham qayta o'girish kerak.
    if isinstance(name_json, str):
        try:
            import json as _json
            name_json = _json.loads(name_json)
        except Exception:
            return name_json
    if isinstance(name_json, dict):
        return name_json.get(lang) or name_json.get("uz") or name_json.get("ru") or next(iter(name_json.values()), "—")
    return str(name_json or "—")


@router.get("/dashboard")
async def get_dashboard_analytics(
    days: int = Query(30, ge=7, le=365, description="Taqqoslash davri (kun)"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    now = datetime.utcnow()
    period_start = now - timedelta(days=days)
    prev_period_start = now - timedelta(days=days * 2)

    paid_filter = func.lower(Order.payment_status) == PAID

    # ── 1. KPI: joriy davr va oldingi davr (taqqoslash uchun) ──────────
    async def period_stats(start: datetime, end: datetime):
        q = select(
            func.coalesce(func.sum(case((paid_filter, Order.total), else_=0)), 0).label("revenue"),
            func.count(Order.id).label("orders"),
            func.count(Order.id).filter(paid_filter).label("paid_orders"),
        ).where(and_(Order.created_at >= start, Order.created_at < end))
        row = (await db.execute(q)).one()
        return {
            "revenue": float(row.revenue or 0),
            "orders": int(row.orders or 0),
            "paid_orders": int(row.paid_orders or 0),
        }

    current = await period_stats(period_start, now)
    previous = await period_stats(prev_period_start, period_start)

    # O'rtacha chek — faqat to'langan buyurtmalar bo'yicha
    aov_current = (current["revenue"] / current["paid_orders"]) if current["paid_orders"] else 0.0
    aov_previous = (previous["revenue"] / previous["paid_orders"]) if previous["paid_orders"] else 0.0

    # To'lov konversiyasi: yaratilgan buyurtmalarning necha foizi to'langan
    conversion = (current["paid_orders"] / current["orders"] * 100) if current["orders"] else 0.0
    conversion_prev = (previous["paid_orders"] / previous["orders"] * 100) if previous["orders"] else 0.0

    # ── 2. Umumiy (all-time) ko'rsatkichlar ────────────────────────────
    total_revenue = float((await db.execute(
        select(func.coalesce(func.sum(Order.total), 0)).where(paid_filter)
    )).scalar() or 0)

    total_orders = int((await db.execute(select(func.count(Order.id)))).scalar() or 0)

    total_customers = int((await db.execute(
        select(func.count(User.id)).where(User.role == RoleEnum.USER)
    )).scalar() or 0)

    total_products = int((await db.execute(select(func.count(Product.id)))).scalar() or 0)

    # Bugungi buyurtmalar
    today_start = datetime.combine(date.today(), datetime.min.time())
    today_orders = int((await db.execute(
        select(func.count(Order.id)).where(Order.created_at >= today_start)
    )).scalar() or 0)

    # ── 3. Kunlik daromad (tanlangan davr) — asosiy chiziqli grafik ────
    daily_q = select(
        func.date(Order.created_at).label("d"),
        func.coalesce(func.sum(case((paid_filter, Order.total), else_=0)), 0).label("revenue"),
        func.count(Order.id).label("orders"),
    ).where(Order.created_at >= period_start).group_by(func.date(Order.created_at)).order_by(func.date(Order.created_at))

    daily_rows = {str(r.d): {"revenue": float(r.revenue or 0), "orders": int(r.orders or 0)}
                  for r in (await db.execute(daily_q)).all()}

    daily_series = []
    for i in range(days):
        d = (period_start + timedelta(days=i)).date()
        key = str(d)
        item = daily_rows.get(key, {"revenue": 0.0, "orders": 0})
        daily_series.append({
            "date": key,
            "label": d.strftime("%d.%m"),
            "revenue": item["revenue"],
            "orders": item["orders"],
        })

    # ── 4. Oylik daromad (12 oy) ──────────────────────────────────────
    year_ago = now - timedelta(days=365)
    monthly_q = select(
        func.date_trunc("month", Order.created_at).label("m"),
        func.coalesce(func.sum(case((paid_filter, Order.total), else_=0)), 0).label("revenue"),
        func.count(Order.id).filter(paid_filter).label("orders"),
    ).where(Order.created_at >= year_ago).group_by("m").order_by("m")

    monthly_sales = []
    for r in (await db.execute(monthly_q)).all():
        monthly_sales.append({
            "month": r.m.strftime("%Y-%m") if r.m else None,
            "label": r.m.strftime("%m.%Y") if r.m else "—",
            "revenue": float(r.revenue or 0),
            "orders": int(r.orders or 0),
        })

    # ── 5. Buyurtma holatlari ─────────────────────────────────────────
    status_rows = (await db.execute(
        select(func.lower(Order.status), func.count(Order.id)).group_by(func.lower(Order.status))
    )).all()
    status_distribution = [{"status": r[0] or "unknown", "count": int(r[1])} for r in status_rows]

    # ── 6. To'lov usullari bo'yicha daromad ───────────────────────────
    pay_rows = (await db.execute(
        select(
            func.lower(Order.payment_method),
            func.coalesce(func.sum(Order.total), 0),
            func.count(Order.id),
        ).where(paid_filter).group_by(func.lower(Order.payment_method))
    )).all()
    payment_breakdown = [
        {"method": r[0] or "unknown", "revenue": float(r[1] or 0), "orders": int(r[2])}
        for r in pay_rows
    ]

    # ── 7. Eng ko'p daromad keltirgan mahsulotlar (90 kun) ────────────
    # DIQQAT: Postgres `json` ustuni bo'yicha GROUP BY qila olmaydi
    # (tenglik operatori yo'q), shuning uchun nomni matnga o'giramiz.
    top_start = now - timedelta(days=90)
    top_q = (
        select(
            Product.id,
            func.min(cast(Product.name, Text)).label("name"),
            func.sum(OrderItem.quantity).label("qty"),
            func.sum(OrderItem.quantity * OrderItem.price_at_time).label("revenue"),
        )
        .join(OrderItem, OrderItem.product_id == Product.id)
        .join(Order, Order.id == OrderItem.order_id)
        .where(and_(Order.created_at >= top_start, paid_filter))
        .group_by(Product.id)
        .order_by(func.sum(OrderItem.quantity * OrderItem.price_at_time).desc())
        .limit(10)
    )
    top_products = [
        {
            "id": str(r.id),
            "name": _localized(r.name),
            "quantity": int(r.qty or 0),
            "revenue": float(r.revenue or 0),
        }
        for r in (await db.execute(top_q)).all()
    ]

    # ── 8. Kategoriyalar bo'yicha savdo (90 kun) ──────────────────────
    cat_q = (
        select(
            Category.id,
            func.min(cast(Category.name, Text)).label("name"),
            func.sum(OrderItem.quantity * OrderItem.price_at_time).label("revenue"),
        )
        .join(Product, Product.category_id == Category.id)
        .join(OrderItem, OrderItem.product_id == Product.id)
        .join(Order, Order.id == OrderItem.order_id)
        .where(and_(Order.created_at >= top_start, paid_filter))
        .group_by(Category.id)
        .order_by(func.sum(OrderItem.quantity * OrderItem.price_at_time).desc())
        .limit(8)
    )
    category_sales = [
        {"id": str(r.id), "name": _localized(r.name), "revenue": float(r.revenue or 0)}
        for r in (await db.execute(cat_q)).all()
    ]

    # ── 9. Yangi mijozlar (12 oy) ─────────────────────────────────────
    cust_q = select(
        func.date_trunc("month", User.created_at).label("m"),
        func.count(User.id),
    ).where(and_(User.created_at >= year_ago, User.role == RoleEnum.USER)).group_by("m").order_by("m")

    new_customers = [
        {"label": r[0].strftime("%m.%Y") if r[0] else "—", "count": int(r[1])}
        for r in (await db.execute(cust_q)).all()
    ]

    # ── 10. Kam qolgan mahsulotlar ────────────────────────────────────
    low_stock_q = select(Product.id, Product.name, Product.stock).where(
        Product.stock <= 10
    ).order_by(Product.stock.asc()).limit(15)
    low_stock = [
        {"id": str(r.id), "name": _localized(r.name), "stock": int(r.stock or 0)}
        for r in (await db.execute(low_stock_q)).all()
    ]

    # ── 11. So'nggi buyurtmalar ───────────────────────────────────────
    recent_q = (
        select(Order, User)
        .outerjoin(User, User.id == Order.user_id)
        .order_by(Order.created_at.desc())
        .limit(10)
    )
    recent_orders = []
    for order, user in (await db.execute(recent_q)).all():
        recent_orders.append({
            "id": str(order.id),
            "orderNumber": order.order_number,
            "customerName": (user.full_name if user else None) or "—",
            "customerPhone": (user.phone if user else None) or "",
            "total": float(order.total or 0),
            "status": (order.status or "").lower(),
            "paymentStatus": (order.payment_status or "").lower(),
            "createdAt": order.created_at.isoformat() if order.created_at else None,
        })

    return {
        "data": {
            "period": {"days": days, "from": period_start.isoformat(), "to": now.isoformat()},

            "kpi": {
                "revenue": {
                    "value": current["revenue"],
                    "previous": previous["revenue"],
                    "changePct": _pct_change(current["revenue"], previous["revenue"]),
                },
                "orders": {
                    "value": current["orders"],
                    "previous": previous["orders"],
                    "changePct": _pct_change(current["orders"], previous["orders"]),
                },
                "aov": {
                    "value": round(aov_current, 2),
                    "previous": round(aov_previous, 2),
                    "changePct": _pct_change(aov_current, aov_previous),
                },
                "conversion": {
                    "value": round(conversion, 1),
                    "previous": round(conversion_prev, 1),
                    "changePct": _pct_change(conversion, conversion_prev),
                },
            },

            "totals": {
                "revenue": total_revenue,
                "orders": total_orders,
                "customers": total_customers,
                "products": total_products,
                "todayOrders": today_orders,
            },

            "dailySeries": daily_series,
            "monthlySales": monthly_sales,
            "statusDistribution": status_distribution,
            "paymentBreakdown": payment_breakdown,
            "topProducts": top_products,
            "categorySales": category_sales,
            "newCustomers": new_customers,
            "lowStock": low_stock,
            "recentOrders": recent_orders,
        }
    }
