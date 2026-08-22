from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.db.session import get_db
from app.models.category import Category
from app.schemas.product import CategoryModel
from app.schemas.common import APIResponse

router = APIRouter()

@router.get("", response_model=APIResponse[List[CategoryModel]])
async def get_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Category))
    categories = result.scalars().all()
    return APIResponse(data=[CategoryModel.model_validate(c) for c in categories])

