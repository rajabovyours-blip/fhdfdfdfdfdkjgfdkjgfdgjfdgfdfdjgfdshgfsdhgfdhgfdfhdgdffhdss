from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from uuid import UUID

from app.db.session import get_db
from app.models.product import Product
from app.models.category import Category
from app.schemas.product import ProductModel, CategoryModel
from app.schemas.common import APIResponse

router = APIRouter()

@router.get("", response_model=APIResponse[List[ProductModel]])
async def get_products(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product))
    products = result.scalars().all()
    return APIResponse(data=[ProductModel.model_validate(p) for p in products])

@router.get("/{id}", response_model=APIResponse[ProductModel])
async def get_product(id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product).where(Product.id == id))
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    return APIResponse(data=ProductModel.model_validate(product))
