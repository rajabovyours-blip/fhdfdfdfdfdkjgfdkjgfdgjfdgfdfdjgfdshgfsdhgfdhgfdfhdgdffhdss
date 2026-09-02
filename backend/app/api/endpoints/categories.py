from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from uuid import UUID

from app.db.session import get_db
from app.models.category import Category
from app.models.user import User
from app.schemas.product import CategoryModel, CategoryCreate, CategoryUpdate
from app.schemas.common import APIResponse
from app.api.dependencies import get_current_admin

router = APIRouter()

@router.get("", response_model=APIResponse[List[CategoryModel]])
async def get_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Category))
    categories = result.scalars().all()
    return APIResponse(data=[CategoryModel.model_validate(c) for c in categories])

@router.post("", response_model=APIResponse[CategoryModel])
async def create_category(category_in: CategoryCreate, db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    from uuid import uuid4
    new_cat = Category(
        id=uuid4(),
        name=category_in.name,
        description=category_in.description or {"uz": "", "ru": "", "en": ""},
        icon_url=category_in.icon_url,
        image_url=category_in.image_url,
        parent_id=category_in.parent_id,
        is_featured=category_in.is_featured
    )
    db.add(new_cat)
    await db.commit()
    await db.refresh(new_cat)
    return APIResponse(data=CategoryModel.model_validate(new_cat))

@router.put("/{id}", response_model=APIResponse[CategoryModel])
async def update_category(id: UUID, category_in: CategoryUpdate, db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    result = await db.execute(select(Category).where(Category.id == id))
    category = result.scalar_one_or_none()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    update_data = category_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(category, field, value)
        
    await db.commit()
    await db.refresh(category)
    return APIResponse(data=CategoryModel.model_validate(category))

@router.delete("/{id}", response_model=APIResponse[dict])
async def delete_category(id: UUID, db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    from sqlalchemy.orm import selectinload
    result = await db.execute(select(Category).where(Category.id == id).options(selectinload(Category.products)))
    category = result.scalar_one_or_none()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
        
    if category.products:
        raise HTTPException(status_code=400, detail="Ushbu kategoriyada mahsulotlar mavjud. Avval mahsulotlarni o'chiring yoki boshqa kategoriyaga o'tkazing.")
    
    await db.delete(category)
    await db.commit()
    return APIResponse(data={"message": "Category deleted successfully"})

