from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List

from app.db.session import get_db
from app.models.user import User, RoleEnum
from app.models.product import Product
from app.models.category import Category
from app.schemas.common import APIResponse
from app.api.dependencies import get_current_admin

router = APIRouter()

@router.get("/dashboard", response_model=APIResponse[dict])
async def get_admin_dashboard(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    # Real aggregated data from database
    user_count = (await db.execute(select(func.count()).select_from(User))).scalar() or 0
    product_count = (await db.execute(select(func.count()).select_from(Product))).scalar() or 0
    category_count = (await db.execute(select(func.count()).select_from(Category))).scalar() or 0
    
    return APIResponse(data={
        "total_users": user_count,
        "total_products": product_count,
        "total_categories": category_count,
    })

@router.get("/reports", response_model=APIResponse[list])
async def get_admin_reports(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    return APIResponse(data=[])
