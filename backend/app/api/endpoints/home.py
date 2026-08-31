from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from app.db.session import get_db
from app.schemas.common import APIResponse
from app.models.category import Category
from app.models.product import Product

router = APIRouter()

from app.models.extras import Banner

@router.get("/banners", response_model=APIResponse[list])
async def get_banners(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Banner).where(Banner.is_active == True).order_by(Banner.order_index))
    banners = result.scalars().all()
    data = []
    for b in banners:
        data.append({
            "id": str(b.id),
            "imageUrl": b.image_url,
            "linkUrl": b.link_url if b.link_url else "",
            "title": {"uz": b.title or "", "ru": b.title or "", "en": b.title or ""},
            "subtitle": {"uz": "", "ru": "", "en": ""},
            "cta": {"uz": "", "ru": "", "en": ""}
        })
    return APIResponse(data=data)

@router.get("/popular-categories", response_model=APIResponse[list])
async def get_popular_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Category).order_by(Category.order_index).limit(10))
    categories = result.scalars().all()
    data = []
    for c in categories:
        data.append({
            "id": str(c.id),
            "name": c.name,
            "icon_url": c.icon_url,
            "is_active": True
        })
    return APIResponse(data=data)

@router.get("/featured-products", response_model=APIResponse[list])
async def get_featured_products(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product).order_by(desc(Product.created_at)).limit(10))
    products = result.scalars().all()
    data = []
    for p in products:
        images_list = p.images if isinstance(p.images, list) else []
        formatted_images = [{"image_url": img} for img in images_list]
        
        data.append({
            "id": str(p.id),
            "name": p.name,
            "description": p.description,
            "categoryId": str(p.category_id) if p.category_id else "",
            "price": float(p.price) if p.price else 0.0,
            "currency": p.currency,
            "unit": p.unit,
            "moq": p.moq,
            "stock": p.stock,
            "stockStatus": p.stock_status,
            "rating": float(p.rating) if p.rating else 0.0,
            "reviewCount": p.review_count,
            "location": p.location,
            "images": formatted_images,
            "videos": []
        })
    return APIResponse(data=data)
