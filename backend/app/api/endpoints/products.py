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

from pydantic import BaseModel as PydanticBaseModel
from typing import Dict

class ProductCreateRequest(PydanticBaseModel):
    name: Dict[str, str]
    description: Dict[str, str]
    category_id: UUID
    price: float
    unit: str = "pcs"
    stock: int = 0
    images: list = []
    brand: str | None = None

@router.post("", response_model=APIResponse[ProductModel])
async def create_product(payload: ProductCreateRequest, db: AsyncSession = Depends(get_db)):
    import uuid as _uuid
    product = Product(
        id=_uuid.uuid4(),
        sku=f"SKU-{_uuid.uuid4().hex[:8].upper()}",
        name=payload.name,
        description=payload.description,
        category_id=payload.category_id,
        price=payload.price,
        unit=payload.unit,
        stock=payload.stock,
        images=payload.images,
        brand=payload.brand,
        currency="UZS",
    )
    db.add(product)
    await db.commit()
    await db.refresh(product)
    return APIResponse(data=ProductModel.model_validate(product))

@router.put("/{id}", response_model=APIResponse[ProductModel])
async def update_product(id: str, payload: ProductCreateRequest, db: AsyncSession = Depends(get_db)):
    try:
        product_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    product.name = payload.name
    product.description = payload.description
    product.category_id = payload.category_id
    product.price = payload.price
    product.unit = payload.unit
    product.stock = payload.stock
    if payload.images:
        product.images = payload.images
    if payload.brand:
        product.brand = payload.brand
        
    await db.commit()
    await db.refresh(product)
    
    return APIResponse(data=ProductModel.model_validate(product))

@router.delete("/{id}", response_model=APIResponse[dict])
async def delete_product(id: str, db: AsyncSession = Depends(get_db)):
    try:
        product_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    await db.delete(product)
    await db.commit()
    
    return APIResponse(data={"success": True, "message": "Product deleted successfully"})
