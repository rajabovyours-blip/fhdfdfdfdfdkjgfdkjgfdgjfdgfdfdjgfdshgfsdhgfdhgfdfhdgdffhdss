from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional
from uuid import UUID

from app.db.session import get_db
from app.models.product import Product
from app.models.category import Category
from app.schemas.product import ProductModel, CategoryModel
from app.schemas.common import APIResponse

router = APIRouter()

@router.get("", response_model=APIResponse[List[ProductModel]])
async def get_products(category_id: Optional[UUID] = None, db: AsyncSession = Depends(get_db)):
    query = select(Product)
    if category_id:
        query = query.where(Product.category_id == category_id)
    result = await db.execute(query)
    products = result.scalars().all()
    return APIResponse(data=[ProductModel.model_validate(p) for p in products])

from sqlalchemy.orm import selectinload

@router.get("/{id}", response_model=APIResponse[ProductModel])
async def get_product(id: str, db: AsyncSession = Depends(get_db)):
    try:
        product_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(
        select(Product)
        .where(Product.id == product_id)
        .options(selectinload(Product.reviews), selectinload(Product.category))
    )
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    return APIResponse(data=ProductModel.model_validate(product))
