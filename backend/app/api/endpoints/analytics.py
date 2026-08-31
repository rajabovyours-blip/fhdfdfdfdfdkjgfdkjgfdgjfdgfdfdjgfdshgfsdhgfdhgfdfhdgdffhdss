from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, date, timedelta
from typing import Dict, Any

from app.db.session import get_db
from app.models.order import Order
from app.models.user import User, RoleEnum
from app.models.product import Product

router = APIRouter()

@router.get("/dashboard")
async def get_dashboard_analytics(db: AsyncSession = Depends(get_db)):
    try:
        # 1. Total Revenue (DELIVERED or PAID)
        revenue_query = select(func.sum(Order.total)).where(Order.status.in_(["DELIVERED", "PAID"]))
        revenue_result = await db.execute(revenue_query)
        total_revenue = revenue_result.scalar() or 0
        
        # 2. Today's orders count
        today = date.today()
        today_start = datetime.combine(today, datetime.min.time())
        today_orders_query = select(func.count(Order.id)).where(Order.created_at >= today_start)
        today_orders_result = await db.execute(today_orders_query)
        today_orders_count = today_orders_result.scalar() or 0
        
        # 3. Active customers count
        customers_query = select(func.count(User.id)).where(User.role == RoleEnum.USER)
        customers_result = await db.execute(customers_query)
        active_customers_count = customers_result.scalar() or 0
        
        # 4. Total products count
        products_query = select(func.count(Product.id))
        products_result = await db.execute(products_query)
        total_products_count = products_result.scalar() or 0
        
        # 5. Order status distribution
        status_query = select(Order.status, func.count(Order.id)).group_by(Order.status)
        status_result = await db.execute(status_query)
        status_distribution = [{"status": row[0], "count": row[1]} for row in status_result.all()]
        
        # 6. Recent Orders (Last 10)
        recent_orders_query = select(Order).order_by(Order.created_at.desc()).limit(10)
        recent_orders_result = await db.execute(recent_orders_query)
        recent_orders = []
        for order in recent_orders_result.scalars().all():
            user_result = await db.execute(select(User).where(User.id == order.user_id))
            user = user_result.scalar_one_or_none()
            recent_orders.append({
                "id": str(order.id),
                "user_name": user.full_name if user and user.full_name else "Noma'lum Mijoz",
                "user_phone": user.phone if user else "",
                "total_amount": float(order.total) if order.total else 0,
                "status": order.status,
                "created_at": order.created_at.isoformat() if order.created_at else None
            })
            
        # 7. Monthly sales data
        current_year = date.today().year
        year_start = datetime(current_year, 1, 1)
        
        orders_this_year_query = select(Order.created_at, Order.total).where(
            Order.created_at >= year_start,
            Order.status.in_(["DELIVERED", "PAID"])
        )
        orders_this_year_result = await db.execute(orders_this_year_query)
        
        monthly_revenue = {i: 0 for i in range(1, 13)}
        for created_at, amount in orders_this_year_result.all():
            if created_at:
                monthly_revenue[created_at.month] += (amount or 0)
                
        month_names = ["Yan", "Fev", "Mar", "Apr", "May", "Iyun", "Iyul", "Avg", "Sen", "Okt", "Noy", "Dek"]
        
        monthly_sales = [
            {"month": month_names[i-1], "revenue": float(monthly_revenue[i])}
            for i in range(1, 13)
        ]

        return {
            "data": {
                "total_revenue": total_revenue,
                "today_orders_count": today_orders_count,
                "active_customers_count": active_customers_count,
                "total_products_count": total_products_count,
                "monthly_sales": monthly_sales,
                "order_status_distribution": status_distribution,
                "recent_orders": recent_orders
            }
        }
    except Exception:
        # Return structured fallback so the admin dashboard never crashes
        return {
            "data": {
                "total_revenue": 0,
                "today_orders_count": 0,
                "active_customers_count": 0,
                "total_products_count": 0,
                "monthly_sales": [],
                "order_status_distribution": [],
                "recent_orders": []
            }
        }

