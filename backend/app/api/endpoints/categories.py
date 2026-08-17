from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.db.session import get_db
from app.models.marketplace import Category
from app.schemas.product import CategoryModel
from app.schemas.common import APIResponse

router = APIRouter()

@router.get("/", response_model=APIResponse[List[CategoryModel]])
async def get_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Category))
    categories = result.scalars().all()
    
    category_models = []
    for c in categories:
        category_models.append(CategoryModel(
            id=c.id,
            name={"uz": c.name_uz, "ru": c.name_ru, "en": c.name_en},
            description={"uz": "", "ru": "", "en": ""},
            icon_url=c.icon_url,
            image_url=None,
            parent_id=c.parent_id,
            is_featured=False
        ))
        
    return APIResponse(data=category_models)
