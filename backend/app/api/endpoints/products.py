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

import pandas as pd
from fastapi import UploadFile, File

@router.post("/bulk-upload", response_model=APIResponse[dict])
async def bulk_upload_products(file: UploadFile = File(...), db: AsyncSession = Depends(get_db)):
    if not (file.filename.endswith(".csv") or file.filename.endswith(".xlsx")):
        raise HTTPException(status_code=400, detail="Invalid file format")
    
    import io
    contents = await file.read()
    
    try:
        if file.filename.endswith(".csv"):
            df = pd.read_csv(io.BytesIO(contents))
        else:
            df = pd.read_excel(io.BytesIO(contents))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading file: {str(e)}")
        
    import uuid as _uuid
    imported = 0
    failed = 0
    
    result = await db.execute(select(Category))
    categories = result.scalars().all()
    default_cat_id = categories[0].id if categories else _uuid.uuid4()
    
    for index, row in df.iterrows():
        try:
            name_uz = str(row.get('name_uz', ''))
            if not name_uz or name_uz == 'nan':
                failed += 1
                continue
            
            price = float(row.get('price', 0))
            
            product = Product(
                id=_uuid.uuid4(),
                sku=f"SKU-{_uuid.uuid4().hex[:8].upper()}",
                name={"uz": name_uz, "ru": str(row.get('name_ru', name_uz)), "en": str(row.get('name_en', name_uz))},
                description={"uz": str(row.get('desc_uz', '')), "ru": str(row.get('desc_ru', '')), "en": str(row.get('desc_en', ''))},
                category_id=default_cat_id,
                price=price,
                unit=str(row.get('unit', 'pcs')),
                stock=int(row.get('stock', 100)),
                images=[],
                brand=None,
                currency="UZS",
            )
            db.add(product)
            imported += 1
        except Exception as e:
            failed += 1
            
    await db.commit()
    
    return APIResponse(data={"imported": imported, "failed": failed}, message="Bulk upload complete")
